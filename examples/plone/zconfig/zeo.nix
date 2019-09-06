{ pkgs ? import <nixpkgs> {}
, generators ? import ./generators.nix {}
, var ? "/tmp"
}:

let configuration = generators.toZConfig {

  zeo = {
    address = "127.0.0.1:8660";
    read-only = false;
    invalidation-queue-size = 100;
    pid-filename = "${var}/zeoserver.pid";
  };

  filestorage = {
    "1" = {
      path = "${var}/filestorage/Data.fs";
      blob-dir = "${var}/blostorage";
    };
  };

  eventlog = {
    level = "DEBUG";
    logfile = {
      stdout = {
        path = "STDOUT";
        format = "%(levelname)s %(asctime)s %(message)s";
      };
      file = {
        path = "${var}/zeoserver.log";
        format = "%(levelname)s %(asctime)s %(message)s";
      };
    };
  };

}; in

pkgs.stdenv.mkDerivation {
  name = "zeo.conf";
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup
    cat > $out << EOF
    $configuration
    EOF
  '';
  inherit configuration;
}
