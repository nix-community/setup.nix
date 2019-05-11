{ pkgs, pythonPackages }:

self: super: {

  "aiovault" = super."aiovault".overridePythonAttrs (old: {
    nativeBuildInputs = [ self."pytest-runner" ];
  });

  "Automat" = super."Automat".overridePythonAttrs(old: {
    buildInputs = [ self."m2r" self."setuptools-scm" ];
  });

  "backports.functools-lru-cache" = super."backports.functools-lru-cache".overridePythonAttrs(old: {
    nativeBuildInputs = [ self."setuptools-scm" ];
    postInstall = ''
      rm -f $out/lib/*/site-packages/backports/__init__.py
      rm -f $out/lib/*/site-packages/backports/__init__.pyc
    '';
  });

  "BTrees" = super."BTrees".overridePythonAttrs (old: {
    nativeBuildInputs = [ self."persistent" self."zope.interface" ];
  });

  "cffi" = pythonPackages."cffi".overridePythonAttrs(old:
    with super."cffi"; {
      inherit name src propagatedBuildInputs;
      nativeBuildInputs = [ self."pytest" ];
      buildInputs = [ pkgs."libffi" ];
      doCheck = false;
    }
  );

  "cmarkgfm" = super."cmarkgfm".overridePythonAttrs(old: {
    buildInputs = [ self."cffi" ];
  });

  "createcoverage" = super."createcoverage".overridePythonAttrs(old: {
    nativeBuildInputs = [ self."setuptools-scm" ];
    postInstall = ''
      rm $out/bin/coverage
    '';
  });

  "fancycompleter" = super."fancycompleter".overridePythonAttrs(old: {
    nativeBuildInputs = [ self."setuptools-scm" ];
  });

  "faker" = super."faker".overridePythonAttrs (old: {
    nativeBuildInputs = [ self."pytest-runner" ];
  });

  "flake8-logging-format" = super."flake8-logging-format".overridePythonAttrs (old: {
    nativeBuildInputs = [ self."nose" ];
  });

  "flake8-print" = super."flake8-print".overridePythonAttrs (old: {
    nativeBuildInputs = [ self."pytest-runner" ];
  });

  "jsonschema" = super."jsonschema".overridePythonAttrs(old: {
    nativeBuildInputs = [
      self."pytest-runner"
      self."setuptools-scm"
    ];
  });

  "Paste" = super."Paste".overridePythonAttrs (old: {
    nativeBuildInputs = [ self."pytest-runner" ];
  });

  "pdbpp" = super."pdbpp".overridePythonAttrs(old: {
    nativeBuildInputs = [ self."setuptools-scm" ];
  });

  # Pillow is often written with title case
  "Pillow" = pythonPackages."pillow".overridePythonAttrs(old:
    with super."Pillow"; {
      inherit name src propagatedBuildInputs;
      doCheck = false;
    }
  );

  "Products.CMFActionIcons" = super."Products.CMFActionIcons".overridePythonAttrs(old: {
    nativeBuildInputs = [ self."eggtestinfo" ];
  });

  "Products.CMFCore" = super."Products.CMFCore".overridePythonAttrs(old: {
    nativeBuildInputs = [ self."eggtestinfo" ];
  });

  "Products.CMFUid" = super."Products.CMFUid".overridePythonAttrs (old: {
    nativeBuildInputs = [ self."eggtestinfo" ];
  });

  "Products.DCWorkflow" = super."Products.DCWorkflow".overridePythonAttrs (old: {
    nativeBuildInputs = [ self."eggtestinfo" ];
  });

  "Products.GenericSetup" = super."Products.GenericSetup".overridePythonAttrs (old: {
    nativeBuildInputs = [ self."eggtestinfo" ];
  });

  "persistent" = super."persistent".overridePythonAttrs(old: {
    nativeBuildInputs = [];
  });

  "pip" = pythonPackages."pip";

  "piexif" = super."piexif".overridePythonAttrs(old: {
    nativeBuildInputs = [ pkgs."unzip" ];
  });

  "plone.app.robotframework" = super."plone.app.robotframework".overridePythonAttrs(old: {
    nativeBuildInputs = [ self."setuptools-scm" ];
    postInstall = ''
      rm -f $out/bin/pybabel
      rm -f $out/bin/pybot
      rm -f $out/bin/robot
    '';
  });

  "py.test" = self."pytest";

  "pyrsistent" = super."pyrsistent".overridePythonAttrs(old: {
    nativeBuildInputs = [ self."pytest-runner" ];
  });

  "python-dateutil" = super."python-dateutil".overridePythonAttrs (old: {
    nativeBuildInputs = [ self."setuptools-scm" ];
  });

  "python-ldap" = pythonPackages."ldap".overridePythonAttrs(old:
    with super."python-ldap"; {
      inherit name src;
      propagatedBuildInputs = [
        pkgs."cyrus_sasl"
        pkgs."openldap"
        pkgs."openssl"
        self."pyasn1-modules"
      ];
      patches = [];
      doCheck = false;
    }
  );

  "pytest-runner" = pythonPackages."pytestrunner".overridePythonAttrs(old:
    with super."pytest-runner"; {
      inherit name src propagatedBuildInputs;
    }
  );

  "reportlab" = super."reportlab".overridePythonAttrs(old: {
    buildInputs = [
      (pkgs."freetype".overrideAttrs (old: { dontDisableStatic = true; }))
      self."pillow"
    ];
  });

  "robotframework-python3" = self.robotframework;

  "rst2pdf" = super."rst2pdf".overridePythonAttrs(old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [ self."pillow" ];
  });

  "setuptools" = pythonPackages."setuptools";

  "setuptools-scm" = pythonPackages."setuptools_scm".overridePythonAttrs(old:
    with super."setuptools-scm"; {
      inherit name src propagatedBuildInputs;
    }
  );

  # Sphinx is often written with title case
  "Sphinx" = pythonPackages."sphinx".overridePythonAttrs(old:
    with super."Sphinx"; {
      inherit name src propagatedBuildInputs;
      doCheck = false;
    }
  );

  "testpath" = pythonPackages."testpath";

  "Twisted" = super."Twisted".overridePythonAttrs(old: {
    buildInputs = [ self."incremental" ];
  });

  "xhtml2pdf" = super."xhtml2pdf".overridePythonAttrs (old: {
    nativeBuildInputs = [ self."nose" ];
  });

  "zope.security" = super."zope.security".overridePythonAttrs (old: {
    nativeBuildInputs = [ self."zope.interface" self."zope.proxy" ];
  });

  "zope.testing" = super."zope.testing".overridePythonAttrs(old: {
    postInstall = ''
      rm -f $out/bin/zope-testrunner
    '';
  });

}
