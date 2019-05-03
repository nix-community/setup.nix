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

.PHONY: upgrade
upgrade:
	@echo "Updating nixpkgs unstable revision"; \
	rev=$$(curl https://api.github.com/repos/NixOS/nixpkgs-channels/branches/nixos-unstable|jq -r .commit.sha); \
	echo "Updating nixpkgs $$rev hash"; \
	sha=$$(nix-prefetch-url --unpack https://github.com/NixOS/nixpkgs-channels/archive/$$rev.tar.gz); \
	sed -i "2s|.*|    url = \"https://github.com/NixOS/nixpkgs-channels/archive/$$rev.tar.gz\";|" setup.nix; \
	sed -i "3s|.*|    sha256 = \"$$sha\";|" setup.nix; \
