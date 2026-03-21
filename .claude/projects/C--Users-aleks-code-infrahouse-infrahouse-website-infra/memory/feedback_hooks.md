---
name: InfraHouse uses custom git hooks, not pre-commit framework
description: InfraHouse repos use shell scripts in hooks/ dir symlinked to .git/hooks/, not the pre-commit Python framework
type: feedback
---

InfraHouse repos do NOT use the `pre-commit` Python framework. They use custom shell scripts in `hooks/pre-commit` that are symlinked into `.git/hooks/pre-commit` by the `install-hooks` Makefile target. The hooks are managed centrally by Terraform in the `github-control` repository.

**Why:** The hooks are standardized across all InfraHouse repos via github-control. Using pre-commit would conflict with this centralized management.

**How to apply:** When setting up git hooks in InfraHouse repos, always use the symlink approach (`ln -fs ../../hooks/pre-commit .git/hooks/pre-commit`), never `pre-commit install`. Do not add `pre-commit` to requirements.txt.