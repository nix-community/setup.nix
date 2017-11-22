===================================================
setup.nix – ”setuptools” for Python packages on Nix
===================================================

**setup.nix** provides opinionated helper functions and pip2nix_-based workflow
for developing, testing and packaging declaratively configured Python packages
in Nix_/NixOS_ environments. **setup.nix** is designed for mixed environments,
where both traditional and Nixpkgs_ based Python package development must
coexists with minimal additional maintance.

**setup.nix** does not replace any tools or conventions in Nixpkgs_, but helps
to develop Python packages on top of it when not all required packages or
versions are yet (or no longer) in Nixpkgs_.


Quick start
===========

Requirements
------------

* `package configuration declaratively in setup.cfg`__
* union of package and development requirements in ``requirements.txt``
* Nix_ or NixOS_ with current Nixpkgs_ channel.

.. _pip2nix: https://github.com/johbo/pip2nix
.. _Nix: https://nixos.org/nix/
.. _NixOS: https://nixos.org/
.. _Nixpkgs:  https://nixos.org/nixpkgs/

__ http://setuptools.readthedocs.io/en/latest/setuptools.html#configuring-setup-using-setup-cfg-files


Installation
------------

* create minimal ``./setup.nix``:

  .. code:: nix

     { pkgs ? import <nixpkgs> {}
     , pythonPackages ? python3Packages
     , setup ? import (pkgs.fetchFromGitHub {
         owner = "datakurre";
         repo = "setup.nix";
         rev = "593c60f59f247a554d4a3e87e7879768d87a983e";
         sha256 = "047sizgifwaj6rvawr4qmmicqa9j49nkrdhqmn9w88qk8s0n02vh";
       })
     }:

     let overrides = self: super: {
     };

     in setup {
       inherit pkgs pythonPackages overrides;
       src = ./.;
    }

* generate ``requirements.nix``:

  .. code:: bash

     $ nix-shell setup.nix -A pip2nix \
       --run "pip2nix generate -r requirements.txt --output=requirements.nix"


Usage
-----

* develop package in a Nix development shell:

  .. code:: bash

     $ nix-shell setup.nix -A develop

* build environment with all the requirements (e.g. for PyCharm):

  .. code:: bash

     $ nix-build setup.nix -A env

* install the package:

  .. code:: bash

     $ nix-env -if setup.nix -A build

* build wheel for the package:

  .. code:: bash

     $ nix-build setup.nix -A bdist_wheel

* build docker image for the package:

  .. code:: bash

     $ nix-build setup.nix -A bdist_docker
     $ docker loads < result


Troubleshooting
---------------

When Python packages fail to build with ``nix-shell`` or ``nix-build``, it's
usually because of missing ``buildInputs`` (because pip2nix cannot detect
``setup_requires`` for generated packages in ``requirements.nix``). These
issues can usually be fixed by manually overriding package derivation in
``setup.nix`` ``overrides``. Check the automatically included `default
overrides`__ for reference.

__ https://github.com/datakurre/setup.nix/blob/master/overrides.nix

Until all the available features and options are documented, see the
setup-function_  and `test examples`_ for more information.

.. _setup-function: https://github.com/datakurre/setup.nix/blob/master/default.nix
.. _test examples: https://github.com/datakurre/setup.nix/blob/master/tests


