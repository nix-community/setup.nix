{ pkgs ? import ((import <nixpkgs> {}).pkgs.fetchFromGitHub {
  owner = "NixOS";
  repo = "nixpkgs";
  rev = "4759056cf1290057845c7aa748c516be6a7e41d4";
  sha256 = "1169qavgxspnb74j30gkjbf1fxp46q96d97r56n69dmg35nfy2r9";
}) {}
, pythonPackages ? pkgs.pythonPackages
, setup ? import ../..
}:

setup {
  inherit pkgs pythonPackages;
  src = ./requirements.nix;
  force = true;
}
