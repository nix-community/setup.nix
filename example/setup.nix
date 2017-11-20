{ pkgs ? import <nixpkgs> {}
, python ? "python3"
, pythonPackages ? builtins.getAttr (python + "Packages") pkgs
, setup ? import ../default.nix
}:

let overrides = self: super: {
  setuptools = pythonPackages.setuptools;

  pytest = super.pytest.overrideDerivation (old: {
    buildInputs = old.buildInputs ++ [ self.setuptools_scm ];
  });

  pytest-runner = super.pytest-runner.overrideDerivation (old: {
    buildInputs = old.buildInputs ++ [ self.setuptools_scm ];
  });

};

in setup {
  inherit pkgs pythonPackages overrides;
  src = ./.;
}
