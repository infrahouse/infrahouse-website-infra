.DEFAULT_GOAL := help
define BROWSER_PYSCRIPT
import webbrowser
webbrowser.open("docs/_build/html/index.html")
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-40s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT
BROWSER := python -c "$$BROWSER_PYSCRIPT"

help: ## Print this help
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

.PHONY: install-hooks
install-hooks:  ## Install repo hooks
	@echo "Checking and installing hooks"
	@test -d .git/hooks || (echo "Looks like you are not in a Git repo" ; exit 1)
	@test -L .git/hooks/pre-commit || ln -fs ../../hooks/pre-commit .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit

.PHONY: bootstrap
bootstrap: install-hooks ## Build development environment
	pip install -r requirements.txt

.PHONY: bootstrap-ci
bootstrap-ci:  ## Build environment for CI
	pip install -r requirements-ci.txt

.PHONY: lint
lint:  ## Check code style
	yamllint .github/workflows
	terraform fmt -check


.PHONY: format
format:  ## Format terraform files
	terraform fmt

.PHONY: init
init:
	terraform init

.PHONY: plan
plan: init ## Run terraform plan
	set -o pipefail ; terraform plan -no-color --out=tf.plan 2> plan.stderr | tee plan.stdout || (cat plan.stderr; exit 1)


.PHONY: apply
apply: ## Run terraform apply
	terraform apply -auto-approve -input=false tf.plan
