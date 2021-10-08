.PHONY: clean clean-test clean-pyc clean-build docs help
.DEFAULT_GOAL := help
define BROWSER_PYSCRIPT
import os, webbrowser, sys
try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT
BROWSER := python -c "$$BROWSER_PYSCRIPT"

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: clean-build clean-pyc clean-test ## remove all build, test, coverage and Python artifacts

format: ## auto format all code
	isort with_time tests setup.py
	black with_time tests setup.py

isort: ## check imports with isort
	isort -c with_time tests setup.py

black: ## check formatting with black
	black --check with_time tests setup.py

clean-build: ## remove build artifacts
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc: ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test: ## remove test and coverage artifacts
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/

lint: ## check style with flake8
	flake8 with_time tests

test-security:
	bandit -r . -x ./tests

test: ## run tests quickly with the default Python
	py.test tests --ignore tests/test_lambda_integration.py --cov=with_time --cov-fail-under=100 --cov-report term-missing

test-all: isort black lint test-security test

integration-test: ## run tests quickly with the default Python
	py.test tests --cov=with_time --cov-fail-under=100

install: clean ## install the package to the active Python's site-packages
	pip install . --upgrade

install-dev: clean
	pip install -e '.[testing]' --upgrade

publish:
	python setup.py sdist bdist_wheel
	twine upload dist/*
