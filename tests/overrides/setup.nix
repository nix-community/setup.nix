{ pkgs ? import <nixpkgs> {}
, python ? "python3"
, pythonPackages ? builtins.getAttr (python + "Packages") pkgs
, setup ? import ../../default.nix
}:

setup {
  inherit pkgs pythonPackages;
  src = ./.;
}
