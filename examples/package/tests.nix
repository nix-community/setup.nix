{ pkgs, pythonPackages, make-test, build, ... }:

make-test ({ pkgs,  ... }: {
  name = "test";
  machine = { config, pkgs, lib, ... }: {
    environment.systemPackages = [ build ];
  };
  testScript = ''
    $machine->waitForUnit("multi-user.target");

    subtest "prints hello", sub {
      $machine->succeed("hello-world") =~ /Hello World!/;
    };
  '';
  makeCoverageReport = false;
})
