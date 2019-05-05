{ pkgs ? import <nixpkgs> {}
, pythonPackages ? pkgs.pythonPackages

# project path, usually ./., without cleanSource, which is added later
, src
, requirements ? null

# custom post install script
, postInstall ? ""

# enable tests on build
, doCheck ? false

# requirements overrides fix building packages with undetected inputs
, overrides ? self: super: {}
, defaultOverrides ? true
, implicitOverrides ? true

# force to build environments without package level dependency checks
, force ? false
, ignoreCollisions ? false

# non-Python inputs
, buildInputs ? []
, propagatedBuildInputs ? []
, shellHook ? ""

# DEPRECATED (because there should not be any):
# known list of "broken" as in non-installable Python packages
, nonInstallablePackages ? []

# very dedicated bdist_docker
, image_author ? null
, image_name ? null
, image_tag ? "latest"
, image_entrypoint ? "/bin/sh"
, image_cmd ? null
, image_features ? [ "busybox" "tmpdir" ]
, image_labels ? {}
, image_extras ? []
, image_created ? "1970-01-01T00:00:01Z"
, image_user ? { name = "nobody"; uid = "65534"; gid = "65534"; }
, image_keepContentsDirlinks ? false
, image_runAsRoot ? ""
, image_extraCommands ? ""
, image_extraConfig ? {}
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
      import configparser, json, re, os
      parser = configparser.ConfigParser()
      with open(os.environ.get("input"), errors="ignore",
                encoding="ascii") as fp:  # fromJSON supports ASCII only
         parser.read_file(fp)
      with open(os.environ.get("out"), "w") as fp:
        fp.write(json.dumps(dict(
          [(k, dict([(K, "\n" in V and [re.findall(r"[\w\.-]+", i)[0] for i in
                                        filter(bool, V.split("\n"))] or V)
                     for K, V in v.items()]))
           for k, v in parser._sections.items()]
        ), indent=4, sort_keys=True))
      fp.close()
      EOF
    ''
  )) else null;

  # Load generated requirements
  requirementsFunc = import (
    if isNull requirements then (
      if hasSuffix ".nix" (baseNameOf src)
      then src else src + "/requirements.nix"
    ) else requirements) {
    inherit pkgs;
    inherit (builtins) fetchurl;
    inherit (pkgs) fetchgit fetchhg;
  };

  # Load default overrides
  commonOverrides = import ./overrides.nix { inherit pkgs pythonPackages; };

  # List package names in requirements
  requirementsNames = attrNames (requirementsFunc {} {});

  # Define optional overlay for force building requirements without overrides
  forcedRequirements = self: super: (listToAttrs (map
    (name: {
      inherit name;
      value = (getAttr name super).overridePythonAttrs(old: {
        installFlags = [ "--no-dependencies" ];
        propagatedBuildInputs = [];
      });
    })
    requirementsNames
  ));

  nameFromDrvName = name:
    let parts = tail (split "([0-9]-)" (parseDrvName name).name);
    in if length parts > 0 then elemAt parts 1 else name;

  # Define implicit overrides overlay to implictly reuse nixpkgs derivations
  nixpkgsOverrides = self: super: (listToAttrs (map
    (name: {
      inherit name;
      value = (getAttr name pythonPackages).overridePythonAttrs(old: {
        inherit name;
        src = (getAttr name super).src;
        nativeBuildInputs = map
          (x: if hasAttr (nameFromDrvName x.name) super
              then getAttr (nameFromDrvName x.name) self
              else x)
          (if hasAttr "nativeBuildInputs" old then old.nativeBuildInputs else []);
        buildInputs = map
          (x: if hasAttr (nameFromDrvName x.name) super
              then getAttr (nameFromDrvName x.name) self
              else x)
          (if hasAttr "buildInputs" old then old.buildInputs else []);
        propagatedBuildInputs = (getAttr name super).propagatedBuildInputs;
        doCheck = false;  # already tested at nixpkgs
      });
    })
    (filter (name: (hasAttr name pythonPackages)) requirementsNames)
  ));

  # Build final pythonPackages with all generated & customized requirements
  packages =
    (fix
    (extends overrides
    (extends (if defaultOverrides then commonOverrides else self: super: {})
    (extends (if force then forcedRequirements else self: super: {})
    (extends (if implicitOverrides then nixpkgsOverrides else self: super: {})
    (extends requirementsFunc pythonPackages.__unfix__)
    )))));

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
    created = image_created;
    contents = [ build ] ++ image_extras ++
      optional (elem "busybox" image_features) pkgs.busybox;
    runAsRoot = if isLinux then ''
      #!${pkgs.stdenv.shell}
      ${pkgs.dockerTools.shadowSetup}
      if [ "${image_user.name}" != "root" ]; then
        groupadd --system --gid ${image_user.gid} ${image_user.name}
        useradd --system --uid ${image_user.uid} --gid ${image_user.gid} -d / -s /sbin/nologin ${image_user.name}
      fi
      echo "hosts: files dns" > /etc/nsswitch.conf
    '' + optionalString (elem "busybox" image_features) ''
      mkdir -p /usr/bin && ln -s /bin/env /usr/bin
    '' + optionalString (elem "tmpdir" image_features) ''
      mkdir -p /tmp && chmod a+rxwt /tmp
    '' + image_runAsRoot else null;
    config = {}
    // (if isNull image_cmd then {
      EntryPoint = if isList image_entrypoint then image_entrypoint else [ image_entrypoint ];
    } else {
      Cmd = if isList image_cmd then image_cmd else [ image_cmd ];
    }) // optionalAttrs isLinux {
      User = "${image_user.name}";
    } // optionalAttrs (elem "tmpdir" image_features) {
      Env = [ "TMPDIR=/tmp" "HOME=/tmp" ];
    } // {
      Labels = image_labels;
    } // image_extraConfig;
    keepContentsDirlinks = image_keepContentsDirlinks;
    extraCommands = image_extraCommands;
  };


# Define commmon targets
in {

  # Define known good version of pip2nix environment
  pip2nix = (pythonPackages.python.withPackages (ps: [
    (getAttr
      ("python" + replaceStrings ["."] [""] pythonPackages.python.pythonVersion)
      ( import (fetchTarball {
          url = "https://github.com/datakurre/pip2nix/archive/c49ba4c0644af8e65191575c4aad1bf23135f543.tar.gz";
          sha256 = "0hxsl8cgb4c057dbj94zbd9zn6xzkf26hghs9mhfq06vn99q1vzc";
        } + "/release.nix") { inherit pkgs; }).pip2nix
      )
#     ( import ../pip2nix/release.nix { inherit pkgs; }).pip2nix )
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
    inherit shellHook;
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

  build = packages.buildPythonPackage ({
    name = "${package.metadata.name}-${package.metadata.version}";
    src = cleanSource src;
    nativeBuildInputs = map
      (name: getAttr name packages) (list "setup_requires" package.options);
    buildInputs = buildInputs;
    checkInputs = map
      (name: getAttr name packages) (list "tests_require" package.options);
    propagatedBuildInputs = if force == true then propagatedBuildInputs ++ map
      (name: getAttr name packages)
      (foldl' (x: y: remove y x)
       requirementsNames (nonInstallablePackages ++ [ package.metadata.name ]))
    else propagatedBuildInputs ++ map
      (name: getAttr name packages) (list "install_requires" package.options);
    inherit doCheck;
  } // (if isFunction postInstall then {
    postInstall = (postInstall packages);
  } else {
    inherit postInstall;
  }));

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
    nativeBuildInputs = buildInputs ++ propagatedBuildInputs ++ map
      (name: getAttr name packages)
      (foldl' (x: y: remove y x)
       requirementsNames nonInstallablePackages);
    shellHook = old.shellHook + shellHook;
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
