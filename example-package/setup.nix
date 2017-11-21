{ pkgs ? import <nixpkgs> {}
, python ? "python3"
, pythonPackages ? builtins.getAttr (python + "Packages") pkgs
, setup ? import ../default.nix
}:

let overrides = self: super: {

  setuptools = pythonPackages.setuptools;

  flake8 = super.flake8.overrideDerivation (old: {
    buildInputs = old.buildInputs ++ [self.pytest-runner];
  });

  flake8-debugger = super.flake8-debugger.overrideDerivation (old: {
    buildInputs = old.buildInputs ++ [self.pytest-runner];
  });

  mccabe = super.mccabe.overrideDerivation (old: {
    buildInputs = old.buildInputs ++ [self.pytest-runner];
  });

  pytest = super.pytest.overrideDerivation (old: {
    buildInputs = old.buildInputs ++ [ self.setuptools-scm ];
  });

  pytest-runner = super.pytest-runner.overrideDerivation (old: {
    buildInputs = old.buildInputs ++ [ self.setuptools-scm ];
  });

};

in setup {
  inherit pkgs pythonPackages overrides;
  src = ./.;
  propagatedBuildInputs = [ pkgs.lolcat ];
  image_entrypoint = "/bin/hello-world";
}
