{ pkgs ? import <nixpkgs> {}
, python ? "python3"
, pythonPackages ? builtins.getAttr (python + "Packages") pkgs
, setup ? import ../../default.nix
}:

let overrides = self: super: {
  "flake8" = super."flake8".overrideDerivation(old: {
    patches = [];
  });
};

in setup {
  inherit pkgs pythonPackages overrides;
  src = ./.;
  buildInputs = [ pkgs.lolcat ];
}
