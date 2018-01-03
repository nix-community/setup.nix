{ pkgs ? import ((import <nixpkgs> {}).pkgs.fetchFromGitHub {
  owner = "NixOS";
  repo = "nixpkgs";
  rev = "4759056cf1290057845c7aa748c516be6a7e41d4";
  sha256 = "1169qavgxspnb74j30gkjbf1fxp46q96d97r56n69dmg35nfy2r9";
}) {}
, python ? "python3"
, pythonPackages ? builtins.getAttr (python + "Packages") pkgs
, setup ? import ../..
}:

let

  manifest_python = pythonPackages.python.withPackages(ps: [
    ps.setuptools ps.wheel
  ]);

  overrides = self: super: {

  # check-manifest requires Python interpreter able to import setup.py
  "check-manifest" = super."check-manifest".overridePythonAttrs(old: {
    postPatch = ''
      substituteInPlace check_manifest.py \
        --replace "os.path.abspath(python)" \
                  "\"${manifest_python.interpreter}\""
    '';
    propagatedBuildInputs = [ manifest_python ];
  });

  # building wheels require SOURCE_DATE_EPOCH
  "zest.releaser" = super."zest.releaser".overridePythonAttrs(old: {
    postInstall = ''
      for prog in $out/bin/*; do
        wrapProgram $prog --set SOURCE_DATE_EPOCH 315532800
        mv $prog $prog-${python}
      done
    '';
  });
};

in setup {
  inherit pkgs pythonPackages overrides;
  src = ./requirements.nix;
  force = true;
}
