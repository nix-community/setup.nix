{ pkgs, pythonPackages }:

self: super: {
  "aiovault" = super."aiovault".overridePythonAttrs (old: {
    buildInputs = super."aiovault".buildInputs ++ [
      self."pytest-runner"
    ];
  });

  "flake8" = super."flake8".overridePythonAttrs (old: {
    buildInputs = super."flake8".buildInputs ++ [
      self."pytest-runner"
    ];
    propagatedBuildInputs = super."flake8".propagatedBuildInputs ++ [
      self."enum34"
      self."configparser"
    ];
  });

  "flake8-debugger" = super."flake8-debugger".overridePythonAttrs (old: {
    buildInputs = super."flake8-debugger".buildInputs ++ [
      self."pytest-runner"
    ];
  });

  "flake8-print" = super."flake8-print".overridePythonAttrs (old: {
    buildInputs = super."flake8-print".buildInputs ++ [
      self."pytest-runner"
    ];
  });

  "cffi" = pythonPackages."cffi".overridePythonAttrs(old:
    with super."cffi"; { inherit name src; }
  );

  "lxml" = pythonPackages."lxml".overridePythonAttrs(old:
    with super."lxml"; { inherit name src; }
  );

  "mccabe" = super."mccabe".overridePythonAttrs (old: {
    buildInputs = super."mccabe".buildInputs ++ [
      self."pytest-runner"
    ];
  });

  "olefile" = pythonPackages."olefile";

  "pillow" = pythonPackages."pillow".overridePythonAttrs(old:
    with super."pillow"; { inherit name src; }
  );

  "psycopg2" = pythonPackages."psycopg2".overridePythonAttrs(old:
    with super."psycopg2"; { inherit name src; }
  );

  "pytest" = super."pytest".overridePythonAttrs (old: {
    buildInputs = super."pytest".buildInputs ++ [
      self."setuptools_scm"
    ];
  });

  "python-ldap" = pythonPackages."ldap".overridePythonAttrs(old:
    with super."python-ldap"; {
      inherit name src;
      patches = [];
      propagatedBuildInputs = old.propagatedBuildInputs ++ [
        self."pyasn1-modules"
      ];
    }
  );

  "pytest-runner" = super."pytest-runner".overridePythonAttrs (old: {
    buildInputs = super."pytest-runner".buildInputs ++ [
      self."setuptools_scm"
    ];
  });

  "reportlab" = pythonPackages."reportlab".overridePythonAttrs(old:
    with super."reportlab"; { inherit name src; doCheck = false; }
  );

  "rst2pdf" = super."rst2pdf".overridePythonAttrs(old: {
    propagatedBuildInputs = super."rst2pdf".propagatedBuildInputs ++ [
      self."pillow"
    ];
  });

  "setuptools" = pythonPackages."setuptools";

  "sphinx" = super."sphinx".overridePythonAttrs(old: {
    propagatedBuildInputs = super."sphinx".propagatedBuildInputs ++ [
      self."typing"
      self."configparser"
    ];
  });

  "wheel" = pythonPackages."wheel".overridePythonAttrs(old:
    with super."wheel"; { inherit name src; }
  );

}
