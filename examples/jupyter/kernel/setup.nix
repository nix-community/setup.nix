{ pkgs ? import <nixpkgs> {}
, pythonPackages ? pkgs.python36Packages
, setup ? import ../../..
}:

setup {
  inherit pkgs pythonPackages;
  src = ./requirements.nix;
}
