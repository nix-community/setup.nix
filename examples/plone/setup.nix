{ pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs-channels/archive/541d9cce8af7a490fb9085305939569567cb58e6.tar.gz";
    sha256 = "0jgz72hhzkd5vyq5v69vpljjlnf0lqaz7fh327bvb3cvmwbfxrja";
  }) {}
, setup ? import ../..
, plone ? "plone52"
, python ? "python3"
, pythonPackages ? builtins.getAttr (python + "Packages") pkgs
, requirements ? ./. + "/requirements-${plone}-${python}.nix"
}:

with builtins;

let

  overrides = self: super:

    # Install Plone packages without dep checks because of cyclic deps
    (listToAttrs (map (name: { name = name;
             value = (getAttr name super).overridePythonAttrs(old: {
        installFlags = [ "--no-dependencies" ];
        propagatedBuildInputs = [];
      });
    }) (filter (x: !isNull (match "(Products|Plone|plone|five|borg).*" x))
               (attrNames ((import requirements {
      inherit pkgs; inherit (pkgs) fetchurl fetchgit fetchhg;
    }) {} {})))))

    //

    # Disable tests for packages form nixpkgs with failing tests
    (listToAttrs (map (name: { name = name;
             value = (getAttr name super).overridePythonAttrs(old: {
         doCheck = false;
      });
    }) [
      "whoosh"
    ]))

    //

    {

    "sphinx" = super."sphinx".overridePythonAttrs(old: {
      propagatedBuildInputs = old.propagatedBuildInputs ++ [ self."packaging" ];
    });

    "collective.wsevents" = super."collective.wsevents".overridePythonAttrs(old: {
      installFlags = [ "--no-dependencies" ];
      propagatedBuildInputs = [];
    });

    # fix zc.recipe.egg to support zip-installed setuptools
    "zc.recipe.egg" = super."zc.recipe.egg".overridePythonAttrs (old: {
      postPatch = if !pythonPackages.isPy27 then ''
        sed -i "s|return copy.deepcopy(cache_storage\[cache_key\])|import copyreg; import zipimport; copyreg.pickle(zipimport.zipimporter, lambda x: (x.__class__, (x.archive, ))); return copy.deepcopy(cache_storage[cache_key])|g" src/zc/recipe/egg/egg.py
      '' else "";
    });
  };

  zope_conf = import ./zconfig/instance.nix {};
  run_py = pkgs.copyPathToStore ./run.py;
  run_sh = pkgs.writeTextFile {
    name = "run.sh";
    text = ''
      #!/usr/bin/env sh
      mkdir -p /var/plone/filestorage
      if [ ! -f /var/plone/.sentinel ]; then
          /bin/plonectl instance -C ${zope_conf} run ${run_py} && touch /var/plone/.sentinel
      fi
      /bin/plonectl instance -C ${zope_conf} console
    '';
    executable = true;
  };

in

setup {
  inherit pkgs pythonPackages overrides;
  src = requirements;
  requirements = requirements;
  buildInputs = with pkgs; [];

  image_keepContentsDirlinks = true;    # optimizes image size using symlinks
  propagatedBuildInputs = with pkgs; [  # allows keepContentsDirlinks
    busybox
  ];
  image_extras = [  # propagatedBuildInputs cannot contain files
    zope_conf
    run_py
    run_sh
  ];
  image_author = "Asko Soukka <asko.soukka@iki.fi>";
  image_name = "gatsby-source-plone";
  image_tag = "latest";
  image_entrypoint = ["${run_sh}"];
  image_features = [];  # busybox removed for keepContentsDirlinks
  image_runAsRoot = ''
    mkdir -p /usr/bin && ln -s /sbin/env /usr/bin/env
    mkdir -p /tmp /var/plone/filestorage
    chown nobody:nobody -R /var/plone
    chmod a+rxwt /tmp
  '';
  image_extraConfig = {
    WorkingDir = "/var/plone";
    Env = [
      "HOME=/var/plone"
      "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      "TMPDIR=/tmp"
    ];
    Volumes = {
      "/var/plone" = {};
    };
    ExposedPorts = {
      "8080/tcp" = {};
    };
  };
}
