nix-build: requirements.nix
	nix-build setup.nix -A 'build."zest.releaser"'

nix-install: requirements.nix
	nix-env -f setup.nix -iA 'build."zest.releaser"'

.PHONY: nix-%

requirements.nix: requirements.txt
	nix-shell setup.nix -A pip2nix \
	  --run "pip2nix generate -r requirements.txt --output=requirements.nix"
