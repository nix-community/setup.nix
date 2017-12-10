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
         rev = "b1bfe61cd2f60f5446c8e3e74e99663fdbbaf7f6";
         sha256 = "1iw3ib6zwgyqnyr9gapsrmwprawws8k331cb600724ddv30xrpkg";
       })
     }:

     setup {
       inherit pkgs pythonPackages;
       src = ./.;
     }

Generate ``requirements.nix`` from your ``requirements.txt``:

  .. code:: bash

     $ nix-shell setup.nix -A pip2nix \
       --run "pip2nix generate -r requirements.txt --output=requirements.nix"


Basic use cases
---------------

Develop package in console with a Nix development shell (this is similar to
developing with a regular Python virtualenv):

  .. code:: bash

     $ nix-shell setup.nix -A develop

Build easily accessible environment with all the requirements (this is useful
e.g. as project Python interpreter for PyCharm):

  .. code:: bash

     $ nix-build setup.nix -A env

Build a reasonably minimal docker image from the package (the best part being
that build itself does not requier Docker at all):

  .. code:: bash

     $ nix-build setup.nix -A bdist_docker
     $ docker load < result

Install the package for local use (that's where Nix excels, because any amount
of Python packages could be installed to be available in path without worrying
about conflicting package versions):

  .. code:: bash

     $ nix-env -f setup.nix -iA build

Build a wheel release for the package (though sure you could just include
``zest.releaser [recommended]`` in your ``requirements.txt`` and use that):

  .. code:: bash

     $ nix-build setup.nix -A bdist_wheel

Integration with regular Makefile so that ``make nix-test`` will be equal
to ``make test`` within Nix-built shell:

  .. code:: make

     nix-%: requirements.nix
        nix-shell setup.nix -A develop --run "$(MAKE) $*"



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

Here's a complete example of using **setup.nix** for Python package
development:


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
        rev = "b1bfe61cd2f60f5446c8e3e74e99663fdbbaf7f6";
        sha256 = "1iw3ib6zwgyqnyr9gapsrmwprawws8k331cb600724ddv30xrpkg";
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

**./tests.nix**:

.. code:: nix

    { pkgs, pythonPackages, make-test, build, ... }:

    make-test ({ pkgs, ... }: {
      name = "test";
      machine = { config, pkgs, lib, ... }: {
        environment.systemPackages = [ build ];
      };
      testScript = ''
        $machine->waitForUnit("multi-user.target");
        $machine->succeed("hello-world") =~ /Hello World!/;
      '';
    })


Interaction examples
--------------------

Run tests with coverage:

  .. code:: bash

     $ nix-shell setup.nix -A develop --run "pytest --cov=helloworld"

Build and run docker image:

  .. code:: bash

     $ docker load < `nix-build setup.nix -A bdist_docker --no-build-output`
     $ docker run --rm helloworld:latest
     Hello World!

Run functional NixOS tests:

  .. code:: bash

     $ nix-build setup.nix -A tests


Configuration options
=====================

Here is the signature of **setup.nix** expression with all the available
configuration arguments:

.. code:: nix

    {
    # Nixpkgs revision
      pkgs ? import <nixpkgs> {}

    # Python version
    , pythonPackages ? pkgs.python36Packages

    # project path, usually ./. (with implicit cleanSource filter)
    , src

    # enable tests on build
    , doCheck ? false

    # force to build environment packages with empty requirements
    , force ? false

    # requirements overrides
    , overrides ? self: super: {}
    , defaultOverrides ? true

    # non-Python inputs
    , buildInputs ? []
    , propagatedBuildInputs ? []

    # bdist_docker options (with image_name defaulting to package name)
    , image_name ? null
    , image_tag  ? "latest"
    , image_entrypoint ? "/bin/sh"
    , image_features ? [ "busybox" "tmpdir" ]
    , image_labels ? {}
    }:

Arguments in detail:

**pkgs**
    **setup.nix** defaults to the currently available Nixpkgs_ version,
    but also accepts the given version for better reproducibility:

    .. code:: nix

       pkgs = import ((import <nixpkgs> {}).pkgs.fetchFromGitHub {
           owner = "NixOS";
           repo = "nixpkgs";
           rev = "11d0cccf56979f621a2e513bf3a921b46972615b";
           sha256 = "1il0r3xnmml71arg1f5kds0ds4ymmcljdmxrk8i8w3y1jw2mqgj6";
       })

**pythonPackges**
    In Nixpkgs_ each Python version has its own set of available packages.
    This is also used in **setup.nix** for selection of the used Python
    version (e.g. ``pkgs.python27Packages`` for Python 2.7 and
    ``pkgs.pythonPackages36Packages`` for Python 3.6).

**src**
    This is the absolute path for the project directory or ``environment.nix``.
    Usually this must be ``src = ./.`` in Nix for **setup.nix** to properly
    find your project's ``setup.cfg`` and ``requirements.txt``.
    If you are only building an evironment or an existing package from
    ``requirements.txt``, ``src = ./requirements.nix`` is enough.

**force**
    By default **setup.nix** tries its best to behave like a good **nixpkgs**
    citizen and compose Python projects from reusable package builds with
    well-defined dependencies. ``force = true`` configures **setup.nix** to
    build individual packages without their dependencies, only to add all the
    dependencies into the final derivation. `This makes it possible to build
    packages with circular dependencies or packages with add-ons (depending
    on the package itself).`__

**doCheck**
    In Nixpkgs_ it is usual to require tests to pass before pakage is built,
    but elsewhere it's usual to run tests in a separate test stage on CI.
    **setup.nix** defaults to disable automatic tests on build, but tests
    can be forced with argment ``doCheck = true``.

**overrides**
    Because pip2nix_ cannot always generate fully working derivations for every
    Python package, **overrides**-function is required to complete the failing
    derivations. In addition, some Python package are actually hard to build,
    but luckily it's possible to re-use build insructions from Nixpkgs_.  See
    the `default overrides`__ example function (``overrides = self: super:
    {}``).

    The most usual use cases for overrides are:

    1. Adding missing Python ``buildInputs`` from package ``setup_requires``
       or non-Python inputs required by possible C-extensions in the package.

    2. Using the existing Nixpkgs_ derivation as it is.

    3. Using use the existing Nixpkgs_ derivation with updated PyPI version.

**defaultOverrides**
    **setup.nix** includes growing amount default package overrides to minimize
    the need of custom overrides. In case that those default overrides cause
    unexpected issues, it's possible to disable including the with argument
    ``defaultOverrides = false``.

**buildInputs**
    Non-Python build-time dependencies (usually Nixpkgs_-packages) required for
    building or testing the developed Python package.

**propagatedBuildInputs**
    Non-Python run-time dependencies (usually Nixpkgs_-packages) required for
    actually using the developed Python package.

**image_name**, **image_tag**, **image_entrypoint**, **image_features**, **image_labels**:
    Required for configuring the build of Docker image with ``bdist_docker``
    build target.

    Allowed arguments for ``image_features`` are:

    * ``"busybox"`` to make possible to execute interactive shell in the image
      with e.g. ``docker run --rm -ti --entrypoint=/bin/sh``

    * ``"tmpfile"`` to include writable ``/tmp`` in the image with environment
      variables ``TMP`` and ``HOME`` set to point it.

    ``image_labels`` should be a flat record of key value pairs for to be
    used as Docker image labels.

__ https://github.com/datakurre/setup.nix/blob/master/examples/tool
__ https://github.com/datakurre/setup.nix/blob/master/overrides.nix


More examples
=============

* https://github.com/collective/sphinxcontrib-httpexample
* https://github.com/datakurre/setup.nix/blob/master/examples/env
* https://github.com/datakurre/setup.nix/blob/master/examples/package
* https://github.com/datakurre/setup.nix/blob/master/examples/tool
