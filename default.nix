{ pkgs ? import <nixpkgs> {}
, pythonPackages ? pkgs.pythonPackages

# project path, usually ./.
, src

# enable tests on build
, doCheck ? false

# requirements overrides
, overrides ? self: super: {}
, defaultOverrides ? true

# non-Python inputs
, buildInputs ? []
, propagatedBuildInputs ? []

# bdist_docker
, image_name ? null
, image_tag  ? "latest"
, image_entrypoint ? "/bin/sh"
, image_features ? [ "busybox" "tmpdir" ]
, image_labels ? {}
}:

with builtins;
with pkgs.lib;
with pkgs.stdenv;

let

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

  requirements = import (src + "/requirements.nix") {
    inherit pkgs;
    inherit (pkgs) fetchurl fetchgit fetchhg;
  };

  packages = if defaultOverrides then
    (fix
    (extends overrides
    (extends (import ./overrides.nix { inherit pkgs pythonPackages; })
    (extends requirements
             pythonPackages.__unfix__))))
  else
    (fix
    (extends overrides
    (extends requirements
             pythonPackages.__unfix__)));

  list = candidate:
    if isList candidate then candidate else [];

in {

  pip2nix = (pkgs.python3.withPackages (ps: [
    (import (pkgs.fetchFromGitHub {
      owner = "datakurre";
      repo = "pip2nix";
      rev = "ad25deaa4584ea4dc24cd7c595b17e39a05cd2df";
      sha256 = "051za8r1v76pkg6n407qmmy2m1w12pbrifbn9rccaday8z7rvpsk";
    } + "/release.nix") { inherit pkgs; }).pip2nix.python36
  ])).env;

} //

(if isNull package then rec {

  develop = shell;

  env = pkgs.buildEnv {
    name = "env";
    paths = buildInputs ++ propagatedBuildInputs ++ [
      (packages.python.withPackages (ps: map
        (name: getAttr name packages) (attrNames (requirements {} {}))))
    ];
  };

  shell = pkgs.stdenv.mkDerivation {
    name = "env";
    nativeBuildInputs = [ env ];
    buildCommand = "";
  };

} else rec {

  pythonPackages = packages;

  build = packages.buildPythonPackage {
    name = "${package.metadata.name}-${package.metadata.version}";
    src = cleanSource src;
    buildInputs = buildInputs ++ map
      (name: getAttr name packages) ((list package.options.setup_requires) ++
                                     (list package.options.tests_require));
    propagatedBuildInputs = propagatedBuildInputs ++ map
      (name: getAttr name packages) (list package.options.install_requires);
    inherit doCheck;
  };

  develop = shell;

  install = packages.python.withPackages (ps: [ build ]);

  env = pkgs.buildEnv {
    name = "${package.metadata.name}-${package.metadata.version}-env";
    paths = buildInputs ++ propagatedBuildInputs ++ [
      (packages.python.withPackages (ps: map
        (name: getAttr name packages) (attrNames (requirements {} {}))))
    ];
  };

  shell = build.overrideDerivation(old: {
    name = "${old.name}-shell";
    buildInputs = buildInputs ++ propagatedBuildInputs ++ map
      (name: getAttr name packages) (attrNames (requirements {} {}));
  });

  tests = if pathExists (src + "/tests.nix") then (
    let make-test = import (pkgs.path + "/nixos/tests/make-test.nix");
    in import (src + "/tests.nix") {
      inherit pkgs pythonPackages make-test build;
    }
  ) else null;

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

  bdist_docker = pkgs.dockerTools.buildImage {
    name = if isNull image_name then package.metadata.name else image_name;
    tag = image_tag;
    contents = [ build ] ++
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
    config = {
      EntryPoint = [ image_entrypoint ];
    } // optionalAttrs isLinux {
      User = "nobody";
    } // optionalAttrs (elem "tmpdir" image_features) {
      Env = [ "TMPDIR=/tmp" "HOME=/tmp" ];
    } // {
      Labels = image_labels;
    };
  };

})
