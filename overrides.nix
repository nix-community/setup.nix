{ pkgs, pythonPackages }:

self: super: {

  "aiovault" = super."aiovault".overridePythonAttrs (old: {
    buildInputs = [ self."pytest-runner" ];
  });

  "python-dateutil" = super."python-dateutil".overridePythonAttrs (old: {
    buildInputs = [ self."setuptools-scm" ];
  });

  "flake8-print" = super."flake8-print".overridePythonAttrs (old: {
    buildInputs = [ self."pytest-runner" ];
  });

  "cffi" = pythonPackages."cffi".overridePythonAttrs(old:
    with super."cffi"; {
      inherit name src propagatedBuildInputs;
      buildInputs = [ pkgs."libffi" self."pytest" ];
      doCheck = false;
    }
  );

  "cmarkgfm" = super."cmarkgfm".overridePythonAttrs(old: {
    buildInputs = [ self."cffi" ];
  });

  # Pillow is often written with title case
  "Pillow" = pythonPackages."pillow".overridePythonAttrs(old:
    with super."Pillow"; {
      inherit name src propagatedBuildInputs;
      doCheck = false;
    }
  );

  pip = pythonPackages."pip";

  "python-ldap" = pythonPackages."ldap".overridePythonAttrs(old:
    with super."python-ldap"; {
      inherit name src;
      propagatedBuildInputs = [
        pkgs.cyrus_sasl
        pkgs.openldap
        pkgs.openssl
        self.pyasn1-modules
      ];
      patches = [];
      doCheck = false;
    }
  );

  "setuptools-scm" = pythonPackages."setuptools_scm".overridePythonAttrs(old:
    with super."setuptools-scm"; {
      inherit name src propagatedBuildInputs;
    }
  );

  "py.test" = self."pytest";

  "pytest-runner" = pythonPackages."pytestrunner".overridePythonAttrs(old:
    with super."pytest-runner"; {
      inherit name src propagatedBuildInputs;
    }
  );

  "rst2pdf" = super."rst2pdf".overridePythonAttrs(old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [ self."pillow" ];
  });

  "setuptools" = pythonPackages."setuptools";

  "testpath" = pythonPackages."testpath";

}
