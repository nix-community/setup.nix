# Generated by pip2nix 0.8.0.dev1
# See https://github.com/nix-community/pip2nix

{ pkgs, fetchurl, fetchgit, fetchhg }:

self: super: {
  "Jinja2" = super.buildPythonPackage rec {
    pname = "Jinja2";
    version = "2.10.1";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/1d/e7/fd8b501e7a6dfe492a433deb7b9d833d39ca74916fa8bc63dd1a4947a671/Jinja2-2.10.1-py2.py3-none-any.whl";
      sha256 = "0yqwnvqsxf74l4m5ayfv7slkp1a0mi77hv7q10gv5ar72npnrp8l";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [
      self."MarkupSafe"
    ];
  };
  "MarkupSafe" = super.buildPythonPackage rec {
    pname = "MarkupSafe";
    version = "1.1.1";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/b9/2e/64db92e53b86efccfaea71321f597fa2e1b2bd3853d8ce658568f7a13094/MarkupSafe-1.1.1.tar.gz";
      sha256 = "0sqipg4fk7xbixqd8kq6rlkxj664d157bdwbh93farcphf92x1r9";
    };
    format = "setuptools";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "Pygments" = super.buildPythonPackage rec {
    pname = "Pygments";
    version = "2.4.2";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/5c/73/1dfa428150e3ccb0fa3e68db406e5be48698f2a979ccbcec795f28f44048/Pygments-2.4.2-py2.py3-none-any.whl";
      sha256 = "09q1bggw7yxwx2ayqskg3ml7yh6j66rxkh8a007l72n8hny31r3i";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "alabaster" = super.buildPythonPackage rec {
    pname = "alabaster";
    version = "0.7.12";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/10/ad/00b090d23a222943eb0eda509720a404f531a439e803f6538f35136cae9e/alabaster-0.7.12-py2.py3-none-any.whl";
      sha256 = "0nfkvlqp1mwjj0jjqk0mm7hk5c6rq5l1dpm2bva5pq50rjykhr24";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "atomicwrites" = super.buildPythonPackage rec {
    pname = "atomicwrites";
    version = "1.3.0";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/52/90/6155aa926f43f2b2a22b01be7241be3bfd1ceaf7d0b3267213e8127d41f4/atomicwrites-1.3.0-py2.py3-none-any.whl";
      sha256 = "1d0id3y2hbnwjfm8hf6spfzpya5qdak2qk3y4alinp9cxcq2qiq3";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "attrs" = super.buildPythonPackage rec {
    pname = "attrs";
    version = "19.1.0";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/23/96/d828354fa2dbdf216eaa7b7de0db692f12c234f7ef888cc14980ef40d1d2/attrs-19.1.0-py2.py3-none-any.whl";
      sha256 = "0ybaycx149w1q2fqkjv119l83vx5115l8167bv5y2b9rxprdph39";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "babel" = super.buildPythonPackage rec {
    pname = "babel";
    version = "2.7.0";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/2c/60/f2af68eb046c5de5b1fe6dd4743bf42c074f7141fe7b2737d3061533b093/Babel-2.7.0-py2.py3-none-any.whl";
      sha256 = "1asqc722hrksgwyliflhdaryzd7qjmvasf2vna355idpdh8fd4mg";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [
      self."pytz"
    ];
  };
  "certifi" = super.buildPythonPackage rec {
    pname = "certifi";
    version = "2019.9.11";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/18/b0/8146a4f8dd402f60744fa380bc73ca47303cccf8b9190fd16a827281eac2/certifi-2019.9.11-py2.py3-none-any.whl";
      sha256 = "1vvc1sssixxgcx719hpibg4zwkv0valbn9ndk87g1p3xf9s7qz7x";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "chardet" = super.buildPythonPackage rec {
    pname = "chardet";
    version = "3.0.4";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/bc/a9/01ffebfb562e4274b6487b4bb1ddec7ca55ec7510b22e4c51f14098443b8/chardet-3.0.4-py2.py3-none-any.whl";
      sha256 = "14b621614q2lw7ik2igdv4qdbblqgdsiglgl5fhf1l5fmvy3ycpw";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "docutils" = super.buildPythonPackage rec {
    pname = "docutils";
    version = "0.15.2";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/22/cd/a6aa959dca619918ccb55023b4cb151949c64d4d5d55b3f4ffd7eee0c6e8/docutils-0.15.2-py3-none-any.whl";
      sha256 = "1l5nk52lmds6gjak2az9b7q43g8fhiilnn8cpaw1z7xpcdj6jkvc";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "entrypoints" = super.buildPythonPackage rec {
    pname = "entrypoints";
    version = "0.3";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/ac/c6/44694103f8c221443ee6b0041f69e2740d89a25641e62fb4f2ee568f2f9c/entrypoints-0.3-py2.py3-none-any.whl";
      sha256 = "06bdwpdvijwfwlscrvcix9prnkiavvpxf33fpqsssf9p655qg7sq";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "flake8" = super.buildPythonPackage rec {
    pname = "flake8";
    version = "3.7.8";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/26/de/3f815a99d86eb10464ea7bd6059c0172c7ca97d4bdcfca41051b388a653b/flake8-3.7.8-py2.py3-none-any.whl";
      sha256 = "15h62f0zf0q5ii2b0h68p611d0iy0k1m8b5470vhnh5jxhygm7cf";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [
      self."entrypoints"
      self."mccabe"
      self."pycodestyle"
      self."pyflakes"
    ];
  };
  "flake8-debugger" = super.buildPythonPackage rec {
    pname = "flake8-debugger";
    version = "3.1.0";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/39/4b/90548607282483dd15f9ce1f4434d735ae756e16e1faf60621b0f8877fcc/flake8-debugger-3.1.0.tar.gz";
      sha256 = "15qxrb2d7sr0pf024fkknsx58aqa5iz38b9s0panv3zfwf6vhkxy";
    };
    format = "setuptools";
    doCheck = false;
    buildInputs = [];
    checkInputs = [
      self."pytest"
    ];
    nativeBuildInputs = [
      self."pytest-runner"
    ];
    propagatedBuildInputs = [
      self."flake8"
      self."pycodestyle"
    ];
  };
  "idna" = super.buildPythonPackage rec {
    pname = "idna";
    version = "2.8";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/14/2c/cd551d81dbe15200be1cf41cd03869a46fe7226e7450af7a6545bfc474c9/idna-2.8-py2.py3-none-any.whl";
      sha256 = "0g2agqpl6ilwgwcsrxmbhx84hvb8zjlpvpy36xsi3yp6i1hpz2za";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "imagesize" = super.buildPythonPackage rec {
    pname = "imagesize";
    version = "1.1.0";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/fc/b6/aef66b4c52a6ad6ac18cf6ebc5731ed06d8c9ae4d3b2d9951f261150be67/imagesize-1.1.0-py2.py3-none-any.whl";
      sha256 = "1n51yc4rsz0ajx5qw35x1b1ya524alwbwzgvzrrmj54rxgirsd1z";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "importlib-metadata" = super.buildPythonPackage rec {
    pname = "importlib-metadata";
    version = "0.23";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/f6/d2/40b3fa882147719744e6aa50ac39cf7a22a913cbcba86a0371176c425a3b/importlib_metadata-0.23-py2.py3-none-any.whl";
      sha256 = "1brrppl17a672z5qimlgzh4ba9rf5207fws5q5ws2fkzfxwqmwfm";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [
      self."zipp"
    ];
  };
  "mccabe" = super.buildPythonPackage rec {
    pname = "mccabe";
    version = "0.6.1";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/87/89/479dc97e18549e21354893e4ee4ef36db1d237534982482c3681ee6e7b57/mccabe-0.6.1-py2.py3-none-any.whl";
      sha256 = "0hhdp0srgrv4bmzlzvmk67zrqr9cvkjjzgd4gmkvd90dhrc652mb";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "more-itertools" = super.buildPythonPackage rec {
    pname = "more-itertools";
    version = "7.2.0";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/45/dc/3241eef99eb45f1def35cf93af35d1cf9ef4c0991792583b8f33ea41b092/more_itertools-7.2.0-py3-none-any.whl";
      sha256 = "1i30pck2xhfxqy4z0j5bq6xf3cjjvqp2z6vjq08hckxcdnqc9f4j";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "packaging" = super.buildPythonPackage rec {
    pname = "packaging";
    version = "19.1";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/ec/22/630ac83e8f8a9566c4f88038447ed9e16e6f10582767a01f31c769d9a71e/packaging-19.1-py2.py3-none-any.whl";
      sha256 = "1ycca9ak1mfpabc63vdhqgn79lnc6m2gwn401bl7xh7xjxxqdb57";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [
      self."attrs"
      self."pyparsing"
      self."six"
    ];
  };
  "pillow" = super.buildPythonPackage rec {
    pname = "pillow";
    version = "6.1.0";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/51/fe/18125dc680720e4c3086dd3f5f95d80057c41ab98326877fc7d3ff6d0ee5/Pillow-6.1.0.tar.gz";
      sha256 = "1pnrsz0f0n0c819v1pdr8j6rm8xvhc9f3kh1fv9xpdp9n5ygf108";
    };
    format = "setuptools";
    doCheck = false;
    buildInputs = [];
    checkInputs = [
      self."pytest"
    ];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "pluggy" = super.buildPythonPackage rec {
    pname = "pluggy";
    version = "0.13.0";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/92/c7/48439f7d5fd6bddb4c04b850bb862b42e3e2b98570040dfaf68aedd8114b/pluggy-0.13.0-py2.py3-none-any.whl";
      sha256 = "1rn39rg4ncng4m5rdrn1hn8s2nl4fsj2sa1kl2s3a7df39hbgd0d";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [
      self."importlib-metadata"
    ];
  };
  "py" = super.buildPythonPackage rec {
    pname = "py";
    version = "1.8.0";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/76/bc/394ad449851729244a97857ee14d7cba61ddb268dce3db538ba2f2ba1f0f/py-1.8.0-py2.py3-none-any.whl";
      sha256 = "1ylkczijmfk6vrv8dj4sdfdmpwf38yhs6rkplb783cz5mramgxk4";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "pycodestyle" = super.buildPythonPackage rec {
    pname = "pycodestyle";
    version = "2.5.0";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/0e/0c/04a353e104d2f324f8ee5f4b32012618c1c86dd79e52a433b64fceed511b/pycodestyle-2.5.0-py2.py3-none-any.whl";
      sha256 = "0mmfj4saqvrzzrfimclpnajhasy71g1lx8b28mq0abrp2afj38lm";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "pyflakes" = super.buildPythonPackage rec {
    pname = "pyflakes";
    version = "2.1.1";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/84/f2/ed0ffb887f8138a8fe5a621b8c0bb9598bfb3989e029f6c6a85ee66628ee/pyflakes-2.1.1-py2.py3-none-any.whl";
      sha256 = "1q4wlrg49kh864s7fki3iw1x2d2ndm2brykpqwjjfxsd7wpfpnqp";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "pyparsing" = super.buildPythonPackage rec {
    pname = "pyparsing";
    version = "2.4.2";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/11/fa/0160cd525c62d7abd076a070ff02b2b94de589f1a9789774f17d7c54058e/pyparsing-2.4.2-py2.py3-none-any.whl";
      sha256 = "1d18n2lq47808yxm55j85q6v2s0r2v18fkhfbbbgbfq357qqscyr";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "pytest" = super.buildPythonPackage rec {
    pname = "pytest";
    version = "5.1.2";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/2f/19/d5f71752f71451ccc5ed5f6739e9da4a235f38783fdaf3629cae41b2ca7b/pytest-5.1.2-py3-none-any.whl";
      sha256 = "042ja2d98v3hv5pp20mcjgadk9bbsy28xihyl2hlq5qlri1k3lcm";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [
      self."atomicwrites"
      self."attrs"
      self."importlib-metadata"
      self."more-itertools"
      self."packaging"
      self."pluggy"
      self."py"
      self."wcwidth"
    ];
  };
  "pytest-runner" = super.buildPythonPackage rec {
    pname = "pytest-runner";
    version = "5.1";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/f8/31/f291d04843523406f242e63b5b90f7b204a756169b4250ff213e10326deb/pytest_runner-5.1-py2.py3-none-any.whl";
      sha256 = "0k9zgpvjh9z3y83gg0nymrfxn1gm0wmgzg7i317mffwsybxl6hnh";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "pytz" = super.buildPythonPackage rec {
    pname = "pytz";
    version = "2019.2";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/87/76/46d697698a143e05f77bec5a526bf4e56a0be61d63425b68f4ba553b51f2/pytz-2019.2-py2.py3-none-any.whl";
      sha256 = "1izhlrh3mfcvmkjqqc12j2yymddsgnvsljhif5f2vkd401sxb568";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "reportlab" = super.buildPythonPackage rec {
    pname = "reportlab";
    version = "3.5.26";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/7b/1c/b1a119589ddfcda0d8c8e9de64c3d979081ba5ffc6c593d4cca99eea0cca/reportlab-3.5.26.tar.gz";
      sha256 = "03xawa673c10acxkv5h9w5pgzdnlk49nncax4bcfh6ym5jiq37kk";
    };
    format = "setuptools";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [
      self."pillow"
    ];
  };
  "requests" = super.buildPythonPackage rec {
    pname = "requests";
    version = "2.22.0";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/51/bd/23c926cd341ea6b7dd0b2a00aba99ae0f828be89d72b2190f27c11d4b7fb/requests-2.22.0-py2.py3-none-any.whl";
      sha256 = "0cabdkf52181iks919g9hn0bn4vz39yhs7pw3ikqqn8grlpjkxcw";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [
      self."certifi"
      self."chardet"
      self."idna"
      self."urllib3"
    ];
  };
  "six" = super.buildPythonPackage rec {
    pname = "six";
    version = "1.12.0";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/73/fb/00a976f728d0d1fecfe898238ce23f502a721c0ac0ecfedb80e0d88c64e9/six-1.12.0-py2.py3-none-any.whl";
      sha256 = "073nyd09fqi2xwalmsi2lf8lrwnma85hscs84iaizcam0ngq0l1k";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "snowballstemmer" = super.buildPythonPackage rec {
    pname = "snowballstemmer";
    version = "1.9.1";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/51/16/86a280d59b3bb439e7103ea1a275a191e3d2df8a3543cda0708f7cb4333c/snowballstemmer-1.9.1.tar.gz";
      sha256 = "0gh3bkdvqhx16p48kxz2rkkpfjnm6c50h1js4k2ppydwkjvm6gki";
    };
    format = "setuptools";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "sphinx" = super.buildPythonPackage rec {
    pname = "sphinx";
    version = "2.2.0";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/8e/4c/95a21788db2e1653e931420f561015a0bbc9bd4660c4520467ab9e733eb2/Sphinx-2.2.0-py3-none-any.whl";
      sha256 = "0s8h4q6m3k8s6vb2xxdr1wv92scyrj4l80ljyihbp4mhyvb3x6l3";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [
      self."Jinja2"
      self."Pygments"
      self."alabaster"
      self."babel"
      self."docutils"
      self."imagesize"
      self."packaging"
      self."requests"
      self."setuptools"
      self."snowballstemmer"
      self."sphinxcontrib-applehelp"
      self."sphinxcontrib-devhelp"
      self."sphinxcontrib-htmlhelp"
      self."sphinxcontrib-jsmath"
      self."sphinxcontrib-qthelp"
      self."sphinxcontrib-serializinghtml"
    ];
  };
  "sphinxcontrib-applehelp" = super.buildPythonPackage rec {
    pname = "sphinxcontrib-applehelp";
    version = "1.0.1";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/13/9a/4428b3114d654cb1cd34d90d5e6fab938d5436f94a571155187ea1dd78b4/sphinxcontrib_applehelp-1.0.1-py2.py3-none-any.whl";
      sha256 = "0p8d3lcvrxwfhai8hx0gir8hhwwnr2rpw3pij46c7rcmmy2yx3gv";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "sphinxcontrib-devhelp" = super.buildPythonPackage rec {
    pname = "sphinxcontrib-devhelp";
    version = "1.0.1";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/b0/a3/fea98741f0b2f2902fbf6c35c8e91b22cd0dd13387291e81d457f9a93066/sphinxcontrib_devhelp-1.0.1-py2.py3-none-any.whl";
      sha256 = "10crrfx7171sqa61xs079f1mj1xrmvvkjsvk8shj221b1aqfq4lm";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "sphinxcontrib-htmlhelp" = super.buildPythonPackage rec {
    pname = "sphinxcontrib-htmlhelp";
    version = "1.0.2";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/e4/35/80a67cc493f4a8a9634ab203a77aaa1b84d79ccb1c02eca72cb084d2c7f7/sphinxcontrib_htmlhelp-1.0.2-py2.py3-none-any.whl";
      sha256 = "1xzgv1hy3jdaa0xvcpdiljirk0ndygcs5a3zdpw9sp32bak3kzfl";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "sphinxcontrib-jsmath" = super.buildPythonPackage rec {
    pname = "sphinxcontrib-jsmath";
    version = "1.0.1";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/c2/42/4c8646762ee83602e3fb3fbe774c2fac12f317deb0b5dbeeedd2d3ba4b77/sphinxcontrib_jsmath-1.0.1-py2.py3-none-any.whl";
      sha256 = "0y1i21qwi5p5f98jxds8r1n12yj12la6nrkkiq3z5wvqzgmymhif";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "sphinxcontrib-qthelp" = super.buildPythonPackage rec {
    pname = "sphinxcontrib-qthelp";
    version = "1.0.2";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/ce/5b/4747c3ba98b3a3e21a66faa183d8f79b9ded70e74212a7988d236a6eb78a/sphinxcontrib_qthelp-1.0.2-py2.py3-none-any.whl";
      sha256 = "084s9vhhvrgjrxpqa3v3lmxbgzm4d10agbjdgpsv3gii62wljc2i";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "sphinxcontrib-serializinghtml" = super.buildPythonPackage rec {
    pname = "sphinxcontrib-serializinghtml";
    version = "1.1.3";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/57/b3/3648e48fa5682e61e9839d62de4e23af1795ceb738d68d73bd974257a95c/sphinxcontrib_serializinghtml-1.1.3-py2.py3-none-any.whl";
      sha256 = "0s4p7bfbzp9dxd48rnv0rj9szar91h93kkd6a48vyl1n76piarnv";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "urllib3" = super.buildPythonPackage rec {
    pname = "urllib3";
    version = "1.25.3";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/e6/60/247f23a7121ae632d62811ba7f273d0e58972d75e58a94d329d51550a47d/urllib3-1.25.3-py2.py3-none-any.whl";
      sha256 = "1l8qdszclda4r5505z90ajvazwys7hp2hvswq3dbx05c4mx60imj";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "wcwidth" = super.buildPythonPackage rec {
    pname = "wcwidth";
    version = "0.1.7";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/7e/9f/526a6947247599b084ee5232e4f9190a38f398d7300d866af3ab571a5bfe/wcwidth-0.1.7-py2.py3-none-any.whl";
      sha256 = "0z6yi9wgxisnsz14c5zpz123bd2rslg7cgsmcjl40yxg4lcygszl";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "zipp" = super.buildPythonPackage rec {
    pname = "zipp";
    version = "0.6.0";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/74/3d/1ee25a26411ba0401b43c6376d2316a71addcc72ef8690b101b4ea56d76a/zipp-0.6.0-py2.py3-none-any.whl";
      sha256 = "0d9kggxfnvdf51ljciy7mm29mcvan33lljq0f79i4fzly7lh6sgh";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [
      self."more-itertools"
    ];
  };
}
