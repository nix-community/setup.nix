{ pkgs ? import <nixpkgs> {}
, pythonPackages ? pkgs.pythonPackages

# project path, usually ./., without cleanSource, which is added later
, src

# nix path to pip2nix built requirements file (or empty for ./requirements.nix)
, requirements ? null

# custom post install script
, postInstall ? ""

# enable tests on package
, doCheck ? false

# requirements overrides fix building packages with undetected inputs
, overrides ? self: super: {}

# non-Python inputs
, buildInputs ? []
, propagatedBuildInputs ? []
, shellHook ? ""

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
with pkgs.lib.attrsets;
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

  # List package names in requirements
  requirementsNames = attrNames (requirementsFunc {} {});

  # Merge named input list from nixpkgs drv with input list from requirements drv
  mergedInputs = old: new: inputsName: self: super:
    (attrByPath [ inputsName ] [] new) ++ map
    (x: attrByPath [ (nameFromDrvName x.name) ] x self)
    (filter (x: !isNull x) (attrByPath [ inputsName ] [] old));

  # Merge package drf from nixpkgs drv with requirements drv
  mergedPackage = old: new: self: super:
    if !isNull (match ".*\.whl" new.src) && new.pname != "wheel"
    then new.overridePythonAttrs(old: rec {
      propagatedBuildInputs =
        mergedInputs old new "propagatedBuildInputs" self super;
    })
    else old.overridePythonAttrs(old: rec {
      inherit (new) pname version src;
      name = "${pname}-${version}";
      checkInputs =
        mergedInputs old new "checkInputs" self super;
      buildInputs =
        mergedInputs old new "buildInputs" self super;
      nativeBuildInputs =
        mergedInputs old new "nativeBuildInputs" self super;
      propagatedBuildInputs =
        mergedInputs old new "propagatedBuildInputs" self super;
      doCheck = false;
    });

  # Return base name form derivation name
  nameFromDrvName = name:
    let parts = tail (split "([0-9]-)" (parseDrvName name).name);
    in if length parts > 0 then elemAt parts 1 else name;

  # Build final pythonPackages with all generated & customized requirements
  python = (pythonPackages.python.override {
    packageOverrides = self: super:
      # 1) Merge packages already in pythonPackages
      let super_ = (requirementsFunc self super);  # from requirements
          results = (listToAttrs (map (name: let new = getAttr name super_; in {
        inherit name;
        value = mergedPackage (getAttr name super) new self super_;
      })
      (filter (name: hasAttr "overridePythonAttrs"
                     (if (tryEval (attrByPath [ name ] {} pythonPackages)).success
                      then (attrByPath [ name ] {} pythonPackages) else {}))
       requirementsNames)))
      // # 2) with packages only in requirements
      (listToAttrs (map (name: { inherit name; value = (getAttr name super_); })
      (filter (name: ! hasAttr name pythonPackages) requirementsNames)));
      in # 3) with also nixpkgs normalized names of packages
      (results // (listToAttrs (map (name: {
        name = replaceStrings ["-"] ["_"] name;
        value = attrByPath [ name ] {} results;
      }) (attrNames results))))
      // (overrides self (super // results));
    self = pythonPackages.python;
  });

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


# Common targets
in {

  # Known good version of pip2nix environment
  pip2nix = (pythonPackages.python.withPackages (ps: [
    (getAttr
      ("python" + replaceStrings ["."] [""] pythonPackages.python.pythonVersion)
      ( import (fetchTarball {
          url = "https://github.com/nix-community/pip2nix/archive/ed6905c746f578120537fe0466415672c58703f5.tar.gz";
          sha256 = "0nzcwy7vzmz876v4x5dyhd965ncw00m36bsnx15vbdfl4jpaq90f";
      } + "/release.nix") { inherit pkgs; }).pip2nix
    )
#   ( import ../pip2nix/release.nix { inherit pkgs; }).pip2nix )
  ])).env;

  # Alias for the final set of Python packages
  pythonPackages = python.pkgs;

} //

# Define environment build targets
(if isNull package then rec {

  # Requirements build as attribute set
  build = genAttrs requirementsNames (name: getAttr name python.pkgs);

  develop = shell;

  # Build env with all requirements
  env = pkgs.buildEnv {
    name = "env";
    paths = buildInputs ++ propagatedBuildInputs ++ [
      (python.withPackages(ps: map (name: getAttr name ps) requirementsNames))
    ];
  };

  install = env;

  # nix-shell
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

# Package build targets
} else rec {

  build = python.pkgs.buildPythonPackage ({
    name = "${package.metadata.name}-${package.metadata.version}";
    src = cleanSource src;
    nativeBuildInputs = map
      (name: getAttr name python.pkgs) (list "setup_requires" package.options);
    buildInputs = buildInputs;
    checkInputs = map
      (name: getAttr name python.pkgs) (list "tests_require" package.options);
    propagatedBuildInputs = propagatedBuildInputs ++ map
      (name: getAttr name python.pkgs) (list "install_requires" package.options);
    inherit doCheck;
  } // (if isFunction postInstall then {
    postInstall = (postInstall python.pkgs);
  } else {
    inherit postInstall;
  }));

  develop = shell;

  env = pkgs.buildEnv {
    name = "${package.metadata.name}-${package.metadata.version}-env";
    paths = buildInputs ++ propagatedBuildInputs ++ [
      (python.withPackages(ps: map (name: getAttr name ps) requirementsNames))
    ];
  };

  install = python.withPackages (ps: [ build ]);

  shell = build.overrideDerivation(old: {
    name = "${old.name}-shell";
    nativeBuildInputs = buildInputs ++ propagatedBuildInputs ++ map
      (name: getAttr name python.pkgs) requirementsNames;
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
