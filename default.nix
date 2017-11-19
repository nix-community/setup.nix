{ pkgs ? import <nixpkgs> {}
, pythonPackages ? pkgs.pythonPackages
, overrides
, src
}:

with builtins;
with pkgs.lib;

let

  package = fromJSON(readFile(
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
  ));

  requirements = import (src + "/requirements.nix") {
    inherit pkgs;
    inherit (pkgs) fetchurl fetchgit fetchhg;
  };

  packages =
    (fix
    (extends overrides
    (extends requirements
             pythonPackages.__unfix__)));

in rec {

  pythonPackages = packages;

  build = packages.buildPythonPackage {
    name = "${package.metadata.name}-${package.metadata.version}";
    src = cleanSource src;
    buildInputs = map
      (name: getAttr name packages) (package.options.setup_requires ++
                                     package.options.tests_require);
    propagatedBuildInputs = map
      (name: getAttr name packages) package.options.install_requires;
    doCheck = false;
  };

  develop = build.overrideDerivation(old: {
    name = "${old.name}-shell";
    buildInputs = map
      (name: getAttr name packages) (attrNames (requirements {} {}));
  });

  install = packages.python.withPackages (ps: [ build ]);

  env = packages.python.withPackages (ps: map
    (name: getAttr name packages) (attrNames (requirements {} {})));

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

  pip2nix = (pkgs.python3.withPackages (ps: [
    (import (pkgs.fetchFromGitHub {
      owner = "johbo";
      repo = "pip2nix";
      rev = "714b51eb69711474a9a2fbddf144e5e66b36986b";
      sha256 = "0h7hg95p1v392h4a310ng2kri9r59ailpj3r4mkr6x1dhq6l4fic";
    } + "/release.nix") {}).pip2nix.python36
  ])).env;

}
