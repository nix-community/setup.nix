all: test

isort:
	isort *.py
	isort tests/*.py

test:
	pytest --cov=helloworld tests/
	flake8 src tests

.PHONY: all isort
