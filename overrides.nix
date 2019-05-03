{ pkgs, pythonPackages }:

self: super: {

  "aiovault" = super."aiovault".overridePythonAttrs (old: {
    nativeBuildInputs = [ self."pytest-runner" ];
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

  "faker" = super."faker".overridePythonAttrs (old: {
    nativeBuildInputs = [ self."pytest-runner" ];
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

  # Pillow is often written with title case
  "Pillow" = pythonPackages."pillow".overridePythonAttrs(old:
    with super."Pillow"; {
      inherit name src propagatedBuildInputs;
      doCheck = false;
    }
  );

  pip = pythonPackages."pip";

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

  "rst2pdf" = super."rst2pdf".overridePythonAttrs(old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [ self."pillow" ];
  });

  "setuptools" = pythonPackages."setuptools";

  "setuptools-scm" = pythonPackages."setuptools_scm".overridePythonAttrs(old:
    with super."setuptools-scm"; {
      inherit name src propagatedBuildInputs;
    }
  );

  "testpath" = pythonPackages."testpath";

  "xhtml2pdf" = super."xhtml2pdf".overridePythonAttrs (old: {
    nativeBuildInputs = [ self."nose" ];
  });

}
