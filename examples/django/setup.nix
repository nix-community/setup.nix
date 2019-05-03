{ pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs-channels/archive/1233c8d9e9bc463899ed6a8cf0232e6bf36475ee.tar.gz";
    sha256 = "0gs8vqw7kc2f35l8wdg7ass06s1lynf7qdx1a10lrll8vv3gl5am";
  }) {}
, pythonPackages ? pkgs.python3Packages
, setup ? import ../../default.nix
}:

let overrides = self: super: {
};

in setup {
  inherit pkgs pythonPackages overrides;
  src = ./.;
}
