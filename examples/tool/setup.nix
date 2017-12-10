{ pkgs ? import ((import <nixpkgs> {}).pkgs.fetchFromGitHub {
  owner = "NixOS";
  repo = "nixpkgs";
  rev = "11d0cccf56979f621a2e513bf3a921b46972615b";
  sha256 = "1il0r3xnmml71arg1f5kds0ds4ymmcljdmxrk8i8w3y1jw2mqgj6";
}) {}
, pythonPackages ? pkgs.pythonPackages
, setup ? import ../..
}:

setup {
  inherit pkgs pythonPackages;
  src = ./requirements.nix;
  force = true;
}
