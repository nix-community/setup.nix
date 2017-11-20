PYTHON ?= python3
ARGSTR ?= --argstr python $(PYTHON)

test: requirements.nix
	nix-shell setup.nix $(ARGSTR) -A develop --run "$(MAKE) $@"

env: requirements.nix
	nix-build setup.nix $(ARGSTR) -A env

shell: requirements.nix
	nix-shell setup.nix $(ARGSTR) -A develop

.PHONY: docs env shell test

requirements.nix: requirements.txt
	nix-shell setup.nix -A pip2nix \
	  --run "pip2nix generate -r requirements.txt --output=requirements.nix"
