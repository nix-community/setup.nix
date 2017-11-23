================================================
setup.nix – Nix for Python developers simplified
================================================

**setup.nix** provides opinionated helper functions and pip2nix_-based workflow
for developing, testing and packaging declaratively configured Python packages
in Nix_/NixOS_ environments. **setup.nix** is designed for mixed environments,
where both traditional and Nixpkgs_ based Python package development must
coexist with minimal additional maintanance.

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

Create minimal ``./setup.nix``:

  .. code:: nix

     { pkgs ? import <nixpkgs> {}
     , pythonPackages ? pkgs.python3Packages
     , setup ? import (pkgs.fetchFromGitHub {
         owner = "datakurre";
         repo = "setup.nix";
         rev = "7748fdb925366cbd8fa4f01ec39418da37c3bc96";
         sha256 = "1fi49ns3ylii6kzpvmlpkg0zirw3p95ga24mcss99jgm3lj8s8pl";
       })
     }:

     setup {
       inherit pkgs pythonPackages;
       src = ./.;
     }

Generate ``requirements.nix``:

  .. code:: bash

     $ nix-shell setup.nix -A pip2nix \
       --run "pip2nix generate -r requirements.txt --output=requirements.nix"


Basic usage
-----------

Develop package in console with a Nix development shell (this is similar to
developing with a regular Python virtualenv):

  .. code:: bash

     $ nix-shell setup.nix -A develop

Build easily accessible environment with all the requirements (this is useful
e.g. as project Python interpreter for PyCharm):

  .. code:: bash

     $ nix-build setup.nix -A env

Install the package for local use (that's where Nix excels, any amount of
Python packages could be installed to be available in path without worrying
about conflicting package versions):

  .. code:: bash

     $ nix-env -if setup.nix -A build

Build a wheel release for the package (though sure you could just include
``zest.releaser [recommended]`` in your ``requirements.txt`` and use that):

  .. code:: bash

     $ nix-build setup.nix -A bdist_wheel

Build a reasonably minimal docker image from the package (the best part being
that build itself does not requier Docker at all):

  .. code:: bash

     $ nix-build setup.nix -A bdist_docker
     $ docker load < result


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
setup-function_ and `examples`_ for more information.

.. _setup-function: https://github.com/datakurre/setup.nix/blob/master/default.nix
.. _examples: https://github.com/datakurre/setup.nix/blob/master/examples


Complete example
================


Project skeleton
----------------

**./helloworld.py**:

.. code:: python

    # -*- coding: utf-8 -*-
    def main():
        print('Hello World!')

**./tests/test_helloworld.py**:

.. code:: python

    # -*- coding: utf-8 -*-
    import helloworld


    def test_main():
        helloworld.main()

**./setup.py**:

.. code:: python

   from setuptools import setup; setup()

**./setup.cfg**:

.. code:: ini

    [metadata]
    name = helloworld
    version = 1.0

    [options]
    setup_requires =
        pytest-runner
    install_requires =
    tests_require =
        pytest
    py_modules =
        helloworld

    [options.entry_points]
    console_scripts =
        hello-world = helloworld:main

    [aliases]
    test = pytest

**./requirements.txt**:

.. code::

   coverage
   pytest
   pytest-cov
   pytest-runner

**./setup.nix**:

.. code:: nix

    { pkgs ? import <nixpkgs> {}
    , pythonPackages ? pkgs.python3Packages
    , setup ? import (pkgs.fetchFromGitHub {
        owner = "datakurre";
        repo = "setup.nix";
        rev = "7748fdb925366cbd8fa4f01ec39418da37c3bc96";
        sha256 = "1fi49ns3ylii6kzpvmlpkg0zirw3p95ga24mcss99jgm3lj8s8pl";
      })
    }:

    setup {
      inherit pkgs pythonPackages;
      src = ./.;
      doCheck = true;
      image_entrypoint = "/bin/hello-world";
    }

**./requirements.nix**:

.. code:: bash

    $ nix-shell setup.nix -A pip2nix \
        --run "pip2nix generate -r requirements.txt --output=requirements.nix"


Testing for coverage
--------------------

Run tests with coverage:

  .. code:: bash

     $ nix-shell setup.nix -A develop --run "pytest --cov=helloworld"


Running as Docker image
-----------------------

Build and run docker image:

  .. code:: bash

     $ docker load < `nix-build setup.nix -A bdist_docker --no-build-output`
     $ docker run --rm helloworld:latest
     Hello World!


More examples
=============

* https://github.com/collective/sphinxcontrib-httpexample
* https://github.com/datakurre/setup.nix/blob/master/examples
