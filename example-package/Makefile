all: test

isort:
	isort *.py
	isort tests/*.py

test:
	flake8 *.py tests/*.py
	pytest --cov=helloworld tests/

.PHONY: all isort
