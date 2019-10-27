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

.. note::

   The current master is development version of setup.nix 3.x supporting
   NixOS >= 19.03, pip >= 18 and implicit reuse of nixpkgs Python package
   derivations. Some rarely used flags from previous versions have been
   removed.


Quick start
===========


Requirements
------------

* package configuration declaratively in `setup.cfg`_
* union of package and development requirements in ``requirements.txt``
* Nix_ or NixOS_ with current Nixpkgs_ channel.

.. _setup.cfg: http://setuptools.readthedocs.io/en/latest/setuptools.html#configuring-setup-using-setup-cfg-files
.. _pip2nix: https://github.com/nix-community/pip2nix
.. _Nix: https://nixos.org/nix/
.. _NixOS: https://nixos.org/
.. _Nixpkgs: https://nixos.org/nixpkgs/


Installation
------------

Create minimal ``./setup.nix``:

  .. code:: nix

     { pkgs ? import <nixpkgs> {}
     , pythonPackages ? pkgs.python3Packages
     , setup ? import (fetchTarball {
         url = "https://github.com/nix-community/setup.nix/archive/v3.3.0.tar.gz";
         sha256 = "1v1rgv1rl7za7ha3ngs6zap0b61z967aavh4p2ydngp44w5m2j5a";
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
``setup.nix`` ``overrides``, e.g.:

.. code:: nix

   overrides = self: super: {

     "sphinx" = super."sphinx".overridePythonAttrs(old: {
       propagatedBuildInputs = old.propagatedBuildInputs ++ [ self."packaging" ];
     });

   };


Please, see the `examples`_ for more examples of use.

.. _examples: https://github.com/nix-community/setup.nix/blob/master/examples


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
   , setup ? import (fetchTarball {
      url = "https://github.com/nix-community/setup.nix/archive/v3.3.0.tar.gz";
      sha256 = "1v1rgv1rl7za7ha3ngs6zap0b61z967aavh4p2ydngp44w5m2j5a";
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

    { pkgs ? import <nixpkgs> {}
    , pythonPackages ? pkgs.pythonPackages

    # project path, usually ./., without cleanSource, which is added later
    , src

    # nix path to pip2nix built requirements file (or empty for ./requirements.nix)
    , requirements ? null

    # custom post install script
    , postInstall ? ""

    # enable tests on package
    , doCheck ? false

    # requirements overrides fix building packages with undetected inputs
    , overrides ? self: super: {}

    # non-Python inputs
    , buildInputs ? []
    , propagatedBuildInputs ? []
    , shellHook ? ""

    # very dedicated bdist_docker
    , image_author ? null
    , image_name ? null
    , image_tag ? "latest"
    , image_entrypoint ? "/bin/sh"
    , image_cmd ? null
    , image_features ? [ "busybox" "tmpdir" ]
    , image_labels ? {}
    , image_extras ? []
    , image_created ? "1970-01-01T00:00:01Z"
    , image_user ? { name = "nobody"; uid = "65534"; gid = "65534"; }
    , image_keepContentsDirlinks ? false
    , image_runAsRoot ? ""
    , image_extraCommands ? ""
    , image_extraConfig ? {}
    }:

Arguments in detail:

**pkgs**
    **setup.nix** defaults to the currently available Nixpkgs_ version,
    but also accepts the given version for better reproducibility:

    .. code:: nix

     {
       pkgs = (fetchTarball {
         url = "https://github.com/NixOS/nixpkgs-channels/archive/915ce0f1e1a75adec7079ddb6cd3ffba5036b3fc.tar.gz";
         sha256 = "1kmx29i3xy4701z4lgmv5xxslb1djahrjxmrf83ig1whb4vgk4wm";
       }) {};
     }

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

**requirements**
    This is the absolute path for ``requirements.nix``, when it's named something
    other than ``requirements.nix``. This option was added to allow to generate
    different requirements files for different Python versions.

**doCheck**
    In Nixpkgs_ it is usual to require tests to pass before pakage is built,
    **setup.nix** disables tests for overridden packages. ``doCheck = true``
    enables tests for the current package. Tests for overridden packages can
    only be re-enabled by doing in custom overrides (see below).

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

__ https://github.com/nix-community/setup.nix/blob/master/examples/tool
__ https://github.com/nix-community/setup.nix/blob/master/overrides.nix


More examples
=============

* https://github.com/collective/sphinxcontrib-httpexample
* https://github.com/nix-community/setup.nix/blob/master/examples/env
* https://github.com/nix-community/setup.nix/blob/master/examples/package
* https://github.com/nix-community/setup.nix/blob/master/examples/tool
