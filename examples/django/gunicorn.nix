{ pkgs ? import <nixpkgs> {}
, pythonPackages ? pkgs.python3Packages
}:

pythonPackages.python.withPackages (ps: with ps; [
  gunicorn
  (import ./setup.nix {
    inherit pkgs pythonPackages;
  }).build
])
