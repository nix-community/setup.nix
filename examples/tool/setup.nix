{ pkgs ? import <nixpkgs> {}
, python ? "python3"
, pythonPackages ? builtins.getAttr (python + "Packages") pkgs
, setup ? import ../..
}:

let

overrides = self: super: {

  "check-manifest" = super."check-manifest".overridePythonAttrs(old: {
    # check-manifest requires Python interpreter able to import setup.py
    propagatedBuildInputs = old.propagatedBuildInputs ++ [ self.setuptools self.wheel ];
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
