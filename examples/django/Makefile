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
	nix-shell -p libffi postgresql --run 'nix-shell setup.nix -A pip2nix \
	  --run "pip2nix generate -r requirements.txt --output=requirements.nix"'

.PHONY: freeze
freeze:
	@grep "name" requirements.nix |grep -Eo "\"(.*)\""|grep -Eo "[^\"]+"|sed -r "s|-([0-9\.]+)|==\1|g"|grep -v "setuptools="

.PHONY: upgrade
upgrade:
	@echo "Updating nixpkgs/nixos-19.03 revision"; \
	rev=$$(curl https://api.github.com/repos/NixOS/nixpkgs-channels/branches/nixos-19.03|jq -r .commit.sha); \
	echo "Updating nixpkgs $$rev hash"; \
	sha=$$(nix-prefetch-url --unpack https://github.com/NixOS/nixpkgs-channels/archive/$$rev.tar.gz); \
	sed -i "2s|.*|    url = \"https://github.com/NixOS/nixpkgs-channels/archive/$$rev.tar.gz\";|" setup-pinned.nix; \
	sed -i "3s|.*|    sha256 = \"$$sha\";|" setup-pinned.nix;
	@echo "Updating setup-pinned.nix revision"; \
	rev=$$(curl https://api.github.com/repos/datakurre/setup.nix/tags|jq -r ".[0].name"); \
	echo "Updating setup-pinned.nix $$rev hash"; \
	sha=$$(nix-prefetch-url --unpack https://github.com/datakurre/setup.nix/archive/$$rev.tar.gz); \
	sed -i "6s|.*|    url = \"https://github.com/datakurre/setup.nix/archive/$$rev.tar.gz\";|" setup-pinned.nix; \
	sed -i "7s|.*|    sha256 = \"$$sha\";|" setup-pinned.nix
