PYTHON ?= python3
ARGSTR ?= --argstr python $(PYTHON)

shell: requirements.nix
	nix-shell setup.nix $(ARGSTR) -A develop

env: requirements.nix
	nix-build setup.nix $(ARGSTR) -A env

.PHONY: env shell

requirements.nix: requirements.txt
	nix-shell setup.nix -A pip2nix \
	  --run "pip2nix generate -r requirements.txt --output=requirements.nix"
