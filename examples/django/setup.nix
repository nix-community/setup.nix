{ pkgs ? import <nixpkgs> {}
, pythonPackages ? pkgs.python3Packages
, setup ? import ../../default.nix
}:

let overrides = self: super: {
};

in setup {
  inherit pkgs pythonPackages overrides;
  src = ./.;
}
