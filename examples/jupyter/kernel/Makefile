nix-%: requirements.nix
	nix-shell setup.nix -A develop --run "$(MAKE) $*"

all: requirements.nix

requirements.nix: requirements.txt
	nix-shell -p gdal geos --run 'nix-shell setup.nix -A pip2nix \
		--run "pip2nix generate -r requirements.txt --output=requirements.nix"'
