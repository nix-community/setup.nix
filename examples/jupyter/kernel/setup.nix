{ pkgs ? import <nixpkgs> {}
, pythonPackages ? pkgs.python36Packages
, setup ? import (builtins.fetchTarball {
    url = "https://github.com/datakurre/setup.nix/archive/506afc61cd923d90ef1910337ccf87ee9786d736.tar.gz";
    sha256 = "057g8vbz9knvlbs94dlxsb5jii9x3p2cx5xzrx09cicq2227fqnz";
  })
}:

let overrides = self: super: {
  "fiona" = pythonPackages."fiona".overridePythonAttrs(old:
    with super."fiona"; { inherit name src propagatedBuildInputs; }
  );
  "shapely" = pythonPackages."shapely".overridePythonAttrs(old:
    with super."shapely"; { inherit name src propagatedBuildInputs; }
  );
  "ipykernel" = pythonPackages."ipykernel".overridePythonAttrs(old:
    with super."ipykernel"; { inherit name src propagatedBuildInputs; }
  );
}; in

setup {
  inherit pkgs pythonPackages overrides;
  src = ./requirements.nix;
}
