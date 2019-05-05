{ pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs-channels/archive/6e29f22551d08974bd68e17db307d1f002152433.tar.gz";
    sha256 = "1czsqcx1mynij379wk5h9i15r51awwjc1rnrrqkff5wll9irjx52";
  }) {}
 , setup ? import (fetchTarball {
    url = "https://github.com/datakurre/setup.nix/archive/v2.0.tar.gz";
    sha256 = "14nffpbqfx64wrc5rhsy6hn5az7r8gkqd8zv0hvfcdk2hnq396nb";
  })
, pythonPackages ? pkgs.python3Packages
}:

let overrides = self: super: {
};

in setup {
  inherit pkgs pythonPackages overrides;
  src = ./.;
}
