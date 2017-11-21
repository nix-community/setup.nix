PYTHON ?= python3
ARGSTR ?= --argstr python $(PYTHON)

env: requirements.nix
	nix-build setup.nix $(ARGSTR) -A env

.PHONY: env

requirements.nix: requirements.txt
	nix-shell setup.nix -A pip2nix \
	  --run "pip2nix generate -r requirements.txt --output=requirements.nix"
