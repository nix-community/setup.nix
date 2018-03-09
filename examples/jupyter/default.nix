{ pkgs ? import <nixpkgs> {}
, pythonPackages ? pkgs.python36Packages
}:

with pkgs;

let self = rec {

  # kernels

  python36_with_packages =
    (import ./kernel/setup.nix { inherit pkgs pythonPackages; }).env;

  python36_kernel = stdenv.mkDerivation rec {
    name = "python36";
    buildInputs = [ python36_with_packages ];
    json = builtins.toJSON {
      argv = [ "${python36_with_packages}/bin/python3.6"
               "-m" "ipykernel" "-f" "{connection_file}" ];
      display_name = "Python 3.6";
      language = "python";
      env = { PYTHONPATH = ""; };
    };
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      mkdir -p $out
      cat > $out/kernel.json << EOF
      $json
      EOF
    '';
  };

  # notebook

  jupyter = pythonPackages.jupyter.overridePythonAttrs (old: {
    postInstall = with pythonPackages; ''
      mkdir -p $out/bin
      ln -s ${jupyter_core}/bin/jupyter $out/bin
      wrapProgram $out/bin/jupyter \
        --prefix PYTHONPATH : "${notebook}/${python.sitePackages}:$PYTHONPATH" \
        --prefix PATH : "${notebook}/bin:$PATH"
    '';
  });

  jupyter_config_dir = stdenv.mkDerivation {
    name = "jupyter";
    buildInputs = [
      python36_kernel
    ];
    builder = writeText "builder.sh" ''
      source $stdenv/setup
      mkdir -p $out/etc/jupyter/kernels $out/etc/jupyter/migrated
      ln -s ${python36_kernel} $out/etc/jupyter/kernels/${python36_kernel.name}
      cat > $out/etc/jupyter/jupyter_notebook_config.py << EOF
      import os
      c.KernelSpecManager.whitelist = {
        '${python36_kernel.name}',
      }
      c.NotebookApp.ip = os.environ.get('JUPYTER_NOTEBOOK_IP', 'localhost')
      EOF
    '';
  };
};

in with self;

stdenv.mkDerivation rec {
  name = "jupyter";
  env = buildEnv { name = name; paths = buildInputs; };
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup; ln -s $env $out
  '';
  buildInputs = [
    jupyter
    jupyter_config_dir
  ];
  shellHook = ''
    mkdir -p $(pwd)/.jupyter
    export JUPYTER_CONFIG_DIR=${jupyter_config_dir}/etc/jupyter
    export JUPYTER_PATH=${jupyter_config_dir}/etc/jupyter
    export JUPYTER_DATA_DIR=$(pwd)/.jupyter
    export JUPYTER_RUNTIME_DIR=$(pwd)/.jupyter
  '';
}
