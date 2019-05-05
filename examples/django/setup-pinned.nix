{ pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs-channels/archive/6e29f22551d08974bd68e17db307d1f002152433.tar.gz";
    sha256 = "1czsqcx1mynij379wk5h9i15r51awwjc1rnrrqkff5wll9irjx52";
  }) {}
 , setup ? import (fetchTarball {
    url = "https://github.com/datakurre/setup.nix/archive/f685d6f8063488dff77e3a672d4e6058c81ffc8b.tar.gz";
    sha256 = "1b2j5hrx3p38nd0685r0mdnkcx7k1pk15x87nkkn6d876gbfnq8f";
  })
, pythonPackages ? pkgs.python3Packages
}:

let overrides = self: super: {
};

in setup {
  inherit pkgs pythonPackages overrides;
  src = ./.;
}
