PYTHON ?= python3
ARGSTR ?= --argstr python $(PYTHON)

all: test

nix-%: requirements.nix
	nix-shell setup.nix $(ARGSTR) -A develop --run "$(MAKE) $*"

nix-test: requirements.nix
	nix-shell setup.nix $(ARGSTR) -A develop --run "$(MAKE) test"
	nix-build setup.nix -A test

nix-env: requirements.nix
	nix-build setup.nix $(ARGSTR) -A env

nix-shell: requirements.nix
	nix-shell setup.nix $(ARGSTR) -A develop

nix-build: requirements.nix
	nix-build setup.nix $(ARGSTR) -A build

nix-sdist: requirements.nix
	nix-build setup.nix $(ARGSTR) -A sdist

nix-wheel: requirements.nix
	nix-build setup.nix $(ARGSTR) -A bdist_wheel

isort:
	isort *.py
	isort tests/*.py

test:
	flake8 *.py tests/*.py
	pytest --cov=helloworld tests/

.PHONY: all isort test nix-%

requirements.nix: requirements.txt
	nix-shell setup.nix -A pip2nix \
	  --run "pip2nix generate -r requirements.txt --output=requirements.nix"
