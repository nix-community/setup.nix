{ pkgs, pythonPackages }:

self: super: {
  "aiovault" = super."aiovault".overridePythonAttrs (old: {
    buildInputs = [ self."pytest-runner" ];
  });

  "fiona" = pythonPackages."fiona".overridePythonAttrs(old:
    with super."fiona"; { inherit name src propagatedBuildInputs; }
  );

  "flake8" = super."flake8".overridePythonAttrs (old: {
    buildInputs = [ self."pytest-runner" ];
    propagatedBuildInputs = super."flake8".propagatedBuildInputs ++ [
      self."enum34"
      self."configparser"
    ];
  });

  "flake8-debugger" = super."flake8-debugger".overridePythonAttrs (old: {
    buildInputs = [ self."pytest-runner" ];
  });

  "flake8-print" = super."flake8-print".overridePythonAttrs (old: {
    buildInputs = [ self."pytest-runner" ];
  });

  "cffi" = pythonPackages."cffi".overridePythonAttrs(old:
    with super."cffi"; {
      inherit name src;
      propagatedBuildInputs = propagatedBuildInputs ++ [ pkgs.libffi ];
      doCheck = false;
    }
  );

  "cmarkgfm" = super."cmarkgfm".overridePythonAttrs(old: {
    buildInputs = [ self."cffi" ];
  });

  "ipykernel" = pythonPackages."ipykernel".overridePythonAttrs(old:
    with super."ipykernel"; { inherit name src propagatedBuildInputs; }
  );

  "lxml" = pythonPackages."lxml".overridePythonAttrs(old:
    with super."lxml"; { inherit name src propagatedBuildInputs; }
  );

  "mccabe" = super."mccabe".overridePythonAttrs (old: {
    buildInputs = [ self."pytest-runner" ];
  });

  "olefile" = pythonPackages."olefile".overridePythonAttrs(old:
    with super."olefile"; { inherit name src propagatedBuildInputs; }
  );

  "pillow" = pythonPackages."pillow".overridePythonAttrs(old:
    with super."pillow"; { inherit name src propagatedBuildInputs; }
  );

  "pip" = pythonPackages."pip".overridePythonAttrs(old:
    with super."pip"; { inherit name src propagatedBuildInputs; }
  );

  "psycopg2" = pythonPackages."psycopg2".overridePythonAttrs(old:
    with super."psycopg2"; { inherit name src propagatedBuildInputs; }
  );

  "pytest" = super."pytest".overridePythonAttrs (old: {
    buildInputs = [ self."setuptools_scm" ];
  });

  "python-dateutil" = super."python-dateutil".overridePythonAttrs (old: {
    buildInputs = [ self."setuptools_scm" ];
  });

  "python-ldap" = pythonPackages."ldap".overridePythonAttrs(old:
    with super."python-ldap"; {
      inherit name src;
      propagatedBuildInputs = propagatedBuildInputs ++ [
        pkgs.cyrus_sasl
        pkgs.openldap
        pkgs.openssl
      ];
      patches = [];
    }
  );

  "pytest-runner" = super."pytest-runner".overridePythonAttrs (old: {
    buildInputs = [ self."setuptools_scm" ];
  });

  "reportlab" = (pythonPackages."reportlab".override {
    pillow = self.pillow;
  }).overridePythonAttrs(old:
    with super."reportlab"; {
      inherit name src propagatedBuildInputs;
      doCheck = false;
    }
  );

  "rst2pdf" = super."rst2pdf".overridePythonAttrs(old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [ self."pillow" ];
  });

  "setuptools" = pythonPackages."setuptools";

  "shapely" = pythonPackages."shapely".overridePythonAttrs(old:
    with super."shapely"; { inherit name src propagatedBuildInputs; }
  );

  "sphinx" = super."sphinx".overridePythonAttrs(old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [
      self."typing"
      self."configparser"
    ];
  });

  "wheel" = pythonPackages."wheel".overridePythonAttrs(old:
    with super."wheel"; { inherit name src propagatedBuildInputs; }
  );

}
