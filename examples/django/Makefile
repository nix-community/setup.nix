.PHONY: all
all: nix-build

nix-%: requirements.nix
	nix-shell setup.nix -A develop --run "$(MAKE) $*"

.PHONY: nix-env
nix-env: requirements.nix
	nix-build setup.nix -A env

.PHONY: nix-shell
nix-shell: requirements.nix
	nix-shell setup.nix -A develop

.PHONY: nix-build
nix-build: requirements.nix
	nix-build setup.nix -A build

.PHONY: runserver
runserver: nix-build
	result/bin/manage runserver --noreload

requirements.nix: requirements.txt
	nix-shell -p libffi --run 'nix-shell setup.nix -A pip2nix \
	  --run "pip2nix generate -r requirements.txt --output=requirements.nix"'
