PLONE ?= plone52
PYTHON ?= python3
BUILDOUT_CFG ?= buildout-$(PLONE).cfg
BUILDOUT_ARGS ?= -N
PYBOT_ARGS ?=

.PHONY: all
all: .installed.cfg

.PHONE: buildout
buildout:
	nix-shell setup.nix -A develop \
	--argstr python $(PYTHON) --argstr plone $(PLONE) \
	--arg requirements ./requirements-buildout.nix \
	--run "buildout -c $(BUILDOUT_CFG) $(BUILDOUT_ARGS)"

.PHONY: nix-shell
nix-shell:
	nix-shell setup.nix -A develop \
	--argstr python $(PYTHON) --argstr plone $(PLONE)

build: result

.PHONY: clean
clean:
	rm -rf .installed bin develop-eggs parts

.PHONY: show
show:
	buildout -c $(BUILDOUT_CFG) $(BUILDOUT_ARGS) annotate

.PHONY: watch
watch: .installed.cfg
	RELOAD_PATH=src bin/instance fg

###

.installed.cfg: $(wildcard *.cfg)
	buildout -c $(BUILDOUT_CFG) $(BUILDOUT_ARGS)

result:
	nix-build setup.nix -A env \
	--argstr python $(PYTHON) --argstr plone $(PLONE)

.PHONY: requirements
requirements: requirements-$(PLONE)-$(PYTHON).nix

requirements-$(PLONE)-$(PYTHON).nix: BUILDOUT_ARGS=buildout:overwrite-requirements-file=true buildout:dump-requirements-file=requirements-$(PLONE)-$(PYTHON).txt
requirements-$(PLONE)-$(PYTHON).nix: requirements-buildout.nix requirements-extras.txt
	nix-shell setup.nix -A develop \
	--argstr python $(PYTHON) --argstr plone $(PLONE) \
	--arg requirements ./requirements-buildout.nix  \
	--run "buildout -c $(BUILDOUT_CFG) $(BUILDOUT_ARGS)"
	nix-shell -p libffi nix nix-prefetch-git \
	--run 'nix-shell setup.nix -A pip2nix --argstr python $(PYTHON) --argstr plone $(PLONE) \
	--run "pip2nix generate -r requirements-$(PLONE)-$(PYTHON).txt -r requirements-buildout.txt -r requirements-extras.txt \
	--output=requirements-$(PLONE)-$(PYTHON).nix"'

requirements-buildout.nix: requirements-buildout.txt
	nix-shell --pure -p libffi nix \
	--run 'nix-shell setup.nix -A pip2nix \
	--run "pip2nix generate -r requirements-buildout.txt \
	--output=requirements-buildout.nix"'

.PHONY: freeze
freeze:
	@grep "name" requirements.nix |grep -Eo "\"(.*)\""|grep -Eo "[^\"]+"|sed -r "s|-([0-9\.]+)|==\1|g"|grep -v "setuptools="

.PHONY: freeze-buildout
freeze-buildout:
	@grep "name" requirements-buildout.nix |grep -Eo "\"(.*)\""|grep -Eo "[^\"]+"|sed -r "s|-([0-9\.]+)|==\1|g"|grep -v "setuptools="

.PHONY: setup.nix
setup.nix:
	@echo "Updating nixpkgs/nixos-19.03 revision"; \
	rev=$$(curl https://api.github.com/repos/NixOS/nixpkgs-channels/branches/nixos-19.03|jq -r .commit.sha); \
	echo "Updating nixpkgs $$rev hash"; \
	sha=$$(nix-prefetch-url --unpack https://github.com/NixOS/nixpkgs-channels/archive/$$rev.tar.gz); \
	sed -i "2s|.*|    url = \"https://github.com/NixOS/nixpkgs-channels/archive/$$rev.tar.gz\";|" setup.nix; \
	sed -i "3s|.*|    sha256 = \"$$sha\";|" setup.nix;
	@echo "Updating setup.nix revision"; \
	rev=$$(curl https://api.github.com/repos/datakurre/setup.nix/branches/master|jq -r ".commit.sha"); \
	echo "Updating setup.nix $$rev hash"; \
	sha=$$(nix-prefetch-url --unpack https://github.com/datakurre/setup.nix/archive/$$rev.tar.gz); \
	sed -i "6s|.*|    url = \"https://github.com/datakurre/setup.nix/archive/$$rev.tar.gz\";|" setup.nix; \
	sed -i "7s|.*|    sha256 = \"$$sha\";|" setup.nix

.PHONY: upgrade
upgrade:
	nix-shell --pure -p curl gnumake jq nix --run "make setup.nix"
