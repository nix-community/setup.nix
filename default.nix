{ pkgs ? import <nixpkgs> {}
, pythonPackages ? pkgs.pythonPackages

# project path, usually ./.
, src

# enable tests on build
, doCheck ? false

# requirements overrides
, overrides ? self: super: {}
, defaultOverrides ? true

# force to build environment packages with empty requirements
, force ? false
, ignoreCollisions ? false

# non-Python inputs
, buildInputs ? []
, propagatedBuildInputs ? []

# known list of "broken" as in non-installable Python packages
, nonInstallablePackages ? [ "zc.recipe.egg" ]

# bdist_docker
, image_author ? null
, image_name ? null
, image_tag  ? "latest"
, image_entrypoint ? "/bin/sh"
, image_cmd ? null
, image_features ? [ "busybox" "tmpdir" ]
, image_labels ? {}
, image_extras ? []
}:

with builtins;
with pkgs.lib;
with pkgs.stdenv;

let
  dockerTools = pkgs.callPackage ./docker {};

  # Parse setup.cfg into Nix via JSON (strings with \n are parsed into lists)
  package = if pathExists (src + "/setup.cfg") then fromJSON(readFile(
    pkgs.runCommand "setup.json" { input=src + "/setup.cfg"; } ''
      ${pkgs.python3}/bin/python << EOF
      import configparser, json, os
      parser = configparser.ConfigParser()
      parser.read(os.environ.get("input"))
      with open(os.environ.get("out"), "w") as fp:
        fp.write(json.dumps(dict(
          [(k, dict([(K, "\n" in V and list(filter(bool, V.split("\n"))) or V)
                     for K, V in v.items()]))
           for k, v in parser._sections.items()]
        ), indent=4, sort_keys=True))
      fp.close()
      EOF
    ''
  )) else null;

  # Load generated requirements
  requirements = import (if baseNameOf src == "requirements.nix"
                         then src else src + "/requirements.nix") {
    inherit pkgs;
    inherit (pkgs) fetchurl fetchgit fetchhg;
  };

  # Load default overrides
  commonOverrides = import ./overrides.nix { inherit pkgs pythonPackages; };

  # List package names in requirements
  requirementsNames = attrNames (requirements {} {});

  # List union of package names in overrides and defaultOverrides
  overridesNames = if defaultOverrides then
    attrNames ((commonOverrides {} {}) // (overrides {} {}))
  else
    attrNames (overrides {} {});

  # Define overlay for force building requirements without overrides
  forcedRequirements = self: super: (listToAttrs (map
    (name: {
      inherit name;
      value = (getAttr name super).overridePythonAttrs(old: {
        installFlags = [ "--no-dependencies" ];
        propagatedBuildInputs = [];
      });
    })
    (filter (name: !(elem name overridesNames)) requirementsNames)
  ));

  # Build final pythonPackages with all generated & customized requirements
  packages =
    (fix
    (extends overrides
    (extends (if defaultOverrides then commonOverrides else self: super: {})
    (extends (if force then forcedRequirements else self: super: {})
    (extends requirements
             pythonPackages.__unfix__)))));

  # Helper to always return a list
  list = name: attrs:
    if hasAttr name attrs then
      let candidate = getAttr name attrs; in
      if isList candidate then candidate else []
    else [];

  # Docker image
  bdist_docker_factory = build: dockerTools.buildImage {
    author = if isNull image_author then (
      if (hasAttr "metadata" package &&
          hasAttr "author" package.metadata &&
          hasAttr "author_email" package.metadata &&
          package.metadata.author != "" &&
          package.metadata.author_email != "") then
        "${package.metadata.author} <${package.metadata.author_email}>"
        else null
      ) else image_author;
    name = if isNull image_name then package.metadata.name else image_name;
    tag = image_tag;
    contents = [ build ] ++ image_extras ++
      optional (elem "busybox" image_features) pkgs.busybox;
    runAsRoot = if isLinux then ''
      #!${pkgs.stdenv.shell}
      ${pkgs.dockerTools.shadowSetup}
      groupadd --system --gid 65534 nobody
      useradd --system --uid 65534 --gid 65534 -d / -s /sbin/nologin nobody
      echo "hosts: files dns" > /etc/nsswitch.conf
    '' + optionalString (elem "busybox" image_features) ''
      mkdir -p /usr/bin && ln -s /bin/env /usr/bin
    '' + optionalString (elem "tmpdir" image_features) ''
      mkdir -p /tmp && chmod a+rxwt /tmp
    '' else null;
    config = {}
    // (if isNull image_cmd then {
      EntryPoint = if isList image_entrypoint then image_entrypoint else [ image_entrypoint ];
    } else {
      Cmd = if isList image_cmd then image_cmd else [ image_cmd ];
    }) // optionalAttrs isLinux {
      User = "nobody";
    } // optionalAttrs (elem "tmpdir" image_features) {
      Env = [ "TMPDIR=/tmp" "HOME=/tmp" ];
    } // {
      Labels = image_labels;
    };
  };


# Define commmon targets
in {

  # Define known good version of pip2nix environment
  pip2nix = (pythonPackages.python.withPackages (ps: [
    (getAttr
      ("python" + replaceStrings ["."] [""] pythonPackages.python.majorVersion)
      (import (pkgs.fetchFromGitHub {
        owner = "datakurre";
        repo = "pip2nix";
        rev = "0eff2793fb760b5dd3a7c0b9145d11840222fd0e";
        sha256 = "0cm7pkg1sz0vrk9hihwxbk0nl6qh0yd8h4dmsp669m4pzkpff3zd";
      } + "/release.nix") { inherit pkgs; }).pip2nix
    )
  ])).env;

  # Define convenient alias for the final set of packages
  pythonPackages = packages;

} //

# Define environment build targets
(if isNull package then rec {

  # Make all packages available for build with all requirements
  build = genAttrs requirementsNames (name:
    if force == true then
      (getAttr name packages).overridePythonAttrs(old: {
        propagatedBuildInputs =
          map (name: getAttr name packages)
              (foldl' (x: y: remove y x)
               requirementsNames (nonInstallablePackages ++ [ name ]));
      })
    else
      getAttr name packages
  );

  # Setup.py alias
  develop = shell;

  # Build env with all requirements
  env = pkgs.buildEnv {
    name = "env";
    paths = buildInputs ++ propagatedBuildInputs ++ [
      (packages.python.buildEnv.override {
        extraLibs = map
          (name: getAttr name packages)
          (foldl' (x: y: remove y x)
           requirementsNames nonInstallablePackages);
        inherit ignoreCollisions;
      })
    ];
  };

  # Setup.py alias
  install = env;

  # Make full environment available for nix-shell
  shell = pkgs.stdenv.mkDerivation {
    name = "env";
    nativeBuildInputs = [ env ];
    buildCommand = "";
  };

  # Docker image
  bdist_docker = bdist_docker_factory env;

  # NixOS functional tests
  tests = if pathExists (src + "/tests.nix") then (
    let make-test = import (pkgs.path + "/nixos/tests/make-test.nix");
    in import (src + "/tests.nix") {
      inherit pkgs pythonPackages make-test build env;
    }
  ) else null;

# Define package build targets
} else rec {

  build = packages.buildPythonPackage {
    name = "${package.metadata.name}-${package.metadata.version}";
    src = cleanSource src;
    buildInputs = buildInputs ++ map
      (name: getAttr name packages) ((list "setup_requires" package.options) ++
                                     (list "tests_require" package.options));
    propagatedBuildInputs = if force == true then propagatedBuildInputs ++ map
      (name: getAttr name packages)
      (foldl' (x: y: remove y x)
       requirementsNames (nonInstallablePackages ++ [ package.metadata.name ]))
    else propagatedBuildInputs ++ map
      (name: getAttr name packages) (list "install_requires" package.options);
    inherit doCheck;
  };

  develop = shell;

  env = pkgs.buildEnv {
    name = "${package.metadata.name}-${package.metadata.version}-env";
    paths = buildInputs ++ propagatedBuildInputs ++ [
      (packages.python.buildEnv.override {
        extraLibs = map
          (name: getAttr name packages)
          (foldl' (x: y: remove y x)
           requirementsNames nonInstallablePackages);
        inherit ignoreCollisions;
      })
    ];
  };

  install = packages.python.withPackages (ps: [ build ]);

  shell = build.overrideDerivation(old: {
    name = "${old.name}-shell";
    buildInputs = buildInputs ++ propagatedBuildInputs ++ map
      (name: getAttr name packages)
      (foldl' (x: y: remove y x)
       requirementsNames nonInstallablePackages);
  });

  sdist = build.overrideDerivation(old: {
    name = "${old.name}-sdist";
    phases = [ "unpackPhase" "buildPhase" ];
    buildPhase = ''
      ${env}/bin/python setup.py sdist --formats=gztar
      mkdir -p $out/dist $out/nix-support
      mv dist/*.tar.gz $out/dist
      for file in `ls -1 $out/dist`; do
        echo "file source-dist $out/dist/$file" >> \
             $out/nix-support/hydra-build-products
      done
      echo ${old.name} > $out/nix-support/hydra-release-name
    '';
  });

  bdist_wheel = build.overrideDerivation(old: {
    name = "${old.name}-bdist_wheel";
    phases = [ "unpackPhase" "buildPhase" ];
    buildPhase = ''
      ${env}/bin/python setup.py bdist_wheel
      mkdir -p $out/dist $out/nix-support
      mv dist/*.whl $out/dist
      for file in `ls -1 $out/dist`; do
        echo "file binary-dist $out/dist/$file" >> \
             $out/nix-support/hydra-build-products
      done
      echo ${old.name} > $out/nix-support/hydra-release-name
    '';
  });

  # Docker image
  bdist_docker = bdist_docker_factory build;

  # NixOS functional tests
  tests = if pathExists (src + "/tests.nix") then (
    let make-test = import (pkgs.path + "/nixos/tests/make-test.nix");
    in import (src + "/tests.nix") {
      inherit pkgs pythonPackages make-test build env;
    }
  ) else null;

})
