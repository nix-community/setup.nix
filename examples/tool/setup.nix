{ pkgs ? import <nixpkgs> {}
, python ? "python3"
, pythonPackages ? builtins.getAttr (python + "Packages") pkgs
, setup ? import ../..
}:

let

  "manifest_python" = pythonPackages.python.withPackages(ps: [
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
    nativeBuildInputs =  [ pythonPackages.toml ];
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
}
