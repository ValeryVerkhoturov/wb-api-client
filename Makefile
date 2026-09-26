# Convenience wrappers around the scripts in scripts/. Nothing here does
# anything the pipeline can't do directly — this is just the short-command
# surface for day-to-day work.
#
# Run `make` (or `make help`) to see the list.

# ── config ────────────────────────────────────────────────────────────────

# Version stamped into every generated manifest. Overridable:
#   make generate VERSION=2026.09.20
VERSION ?= 0.0.0.dev0

# Sibling repos mounted under clients/. Both are committed, tagged and
# pushed alongside the main repo — see the git-* targets below.
SUBMODULES := php onescript

# Prefer a venv-local python if one exists, else system python3.
PY := $(shell test -x .venv/bin/python && echo .venv/bin/python || echo python3)

# One-off Docker invocations. Reused rather than re-typed per target.
GO_DOCKER   = docker run --rm -u $$(id -u):$$(id -g) \
                -v $(CURDIR)/clients/go:/app -w /app \
                -e HOME=/tmp -e GOCACHE=/tmp/.cache/go-build -e GOPATH=/tmp/go \
                golang:1.22-alpine
NODE_DOCKER = docker run --rm -u $$(id -u):$$(id -g) \
                -v $(CURDIR)/clients/typescript:/app -w /app \
                -e HOME=/tmp -e npm_config_cache=/tmp/.npm \
                node:20-alpine
MVN_DOCKER  = docker run --rm -u $$(id -u):$$(id -g) \
                -v $(CURDIR)/clients/java:/app -w /app \
                -e HOME=/tmp maven:3.9-eclipse-temurin-17
PHP_DOCKER  = docker run --rm -u $$(id -u):$$(id -g) \
                -v $(CURDIR)/clients/php:/app -w /app \
                -e HOME=/tmp -e COMPOSER_HOME=/tmp/.composer \
                composer:2

.DEFAULT_GOAL := help
.PHONY: help venv download post-process generate regen \
        verify verify-python verify-ts verify-go verify-java verify-php \
        verify-onescript \
        gofmt black prettier spotless php-cs-fixer clean \
        git-status git-commit git-push git-pull

# ── help ──────────────────────────────────────────────────────────────────

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "Targets:\n"} \
	     /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2 }' \
	     $(MAKEFILE_LIST)
	@echo ""
	@echo "  Override VERSION=<x.y.z> on generate to stamp a specific version."

# ── setup ─────────────────────────────────────────────────────────────────

venv: ## Create .venv and install post-processor deps
	python3 -m venv .venv
	.venv/bin/pip install -q -r scripts/requirements.txt

# ── pipeline ──────────────────────────────────────────────────────────────

download: ## Pull swagger YAMLs from dev.wildberries.ru
	./scripts/download-swaggers.sh

post-process: ## Run all post-processing passes on swaggers/
	$(PY) scripts/post-process.py

generate: post-process ## Regenerate all six language clients
	./scripts/generate.sh $(VERSION)

regen: download post-process generate ## Full pipeline: download → process → generate

# ── verification ──────────────────────────────────────────────────────────

verify: verify-python verify-ts verify-go verify-java verify-php verify-onescript gofmt black prettier spotless php-cs-fixer ## Build every language + fmt checks

verify-python: ## Build the Python wheel and import every sub-module
	@echo "── Python ─────────────────────────────────────"
	cd clients/python && rm -rf dist && ../../.venv/bin/python -m build --wheel 2>&1 | tail -1
	@$(PY) -c "import sys; sys.path.insert(0,'clients/python'); \
	  import importlib; \
	  [importlib.import_module(f'wb_api_client.{s}') for s in \
	   ['general','items','orders_fbs','orders_dbw','dbs','in_store_pickup', \
	    'orders_fbw','promotion','communications','rates','analytics','reports','finances']]; \
	  print('  ✓ all 13 sub-modules import')"

verify-ts: ## tsc-build the TypeScript package
	@echo "── TypeScript ─────────────────────────────────"
	$(NODE_DOCKER) sh -c "npm install --silent --no-audit --no-fund && npx tsc && echo '  ✓ tsc OK'"

verify-go: ## Compile every Go sub-package
	@echo "── Go ─────────────────────────────────────────"
	$(GO_DOCKER) sh -c "go build ./... && echo '  ✓ go build OK'"

verify-java: ## Compile the Java module (mvn clean compile)
	@echo "── Java ───────────────────────────────────────"
	$(MVN_DOCKER) mvn -q -Duser.home=/tmp -DskipTests clean compile
	@echo "  ✓ mvn compile OK"

verify-php: ## composer validate + PHP lint every generated file
	@echo "── PHP ────────────────────────────────────────"
	@# Not --strict: composer warns about `version` in composer.json
	@# ("recommended to leave it out for Packagist"), which we accept
	@# because the version field is how the generation pipeline stamps
	@# a uniform version across every language manifest.
	$(PHP_DOCKER) composer validate --no-check-publish
	@# php -l lints every .php file; loop through them via find so a
	@# syntax error in one surfaces its filename clearly.
	@docker run --rm -u $$(id -u):$$(id -g) -v $(CURDIR)/clients/php:/app -w /app \
	  -e HOME=/tmp php:8.3-cli-alpine sh -c \
	  "find src -name '*.php' -print0 | xargs -0 -n1 php -l >/dev/null && echo '  ✓ php -l passes on every file'"

verify-onescript: ## Compile-check every OneScript module + load the package
	@echo "── OneScript ──────────────────────────────────"
	@# No formatter step: the generator emits its own canonical layout and
	@# OneScript has no community formatter to canonicalize against.
	./scripts/verify-onescript.sh

gofmt: ## Fail if any Go file needs `gofmt -w`
	@out=$$(docker run --rm -v $(CURDIR)/clients/go:/app -w /app golang:1.22-alpine gofmt -l . 2>&1); \
	 if [ -n "$$out" ]; then echo "gofmt needed:"; echo "$$out"; exit 1; \
	 else echo "  ✓ gofmt clean"; fi

black: ## Fail if any Python file needs `black`
	@$(PY) -m black --check --quiet clients/python && echo "  ✓ black clean"

prettier: ## Fail if any TypeScript file needs `prettier`
	@$(NODE_DOCKER) sh -c "npm install --silent --no-audit --no-fund && npx --no-install prettier --check --log-level=error 'src/**/*.ts'" \
	  && echo "  ✓ prettier clean"

spotless: ## Fail if any Java file needs `spotless:check` (google-java-format)
	@$(MVN_DOCKER) mvn -q -Duser.home=/tmp spotless:check && echo "  ✓ spotless clean"

php-cs-fixer: ## Fail if any PHP file needs `php-cs-fixer` (PSR-12)
	@docker run --rm -u $$(id -u):$$(id -g) -v $(CURDIR)/clients/php:/work -w /work \
	  -e HOME=/tmp -e PHP_CS_FIXER_IGNORE_ENV=1 \
	  ghcr.io/php-cs-fixer/php-cs-fixer:3-php8.3 fix src --dry-run --rules=@PSR12 --using-cache=no \
	  >/dev/null 2>&1 && echo "  ✓ php-cs-fixer clean"

# ── main + submodule git ops ──────────────────────────────────────────────
# `clients/php` and `clients/onescript` are submodules pointing at
# ValeryVerkhoturov/wb-api-client-php and .../wb-api-client-1c. These targets
# act on the main repo AND both submodules so you don't have to remember to
# `cd clients/<sub> && git …` after every regen.

git-status: ## Show `git status` in main repo AND both submodules
	@echo "── main repo ──"
	@git status --short
	@for sub in $(SUBMODULES); do \
	  echo ""; echo "── clients/$$sub submodule ──"; \
	  (cd clients/$$sub && git status --short); \
	done

git-commit: ## Commit main + both submodules with the same message (MSG=…)
	@if [ -z "$(MSG)" ]; then \
	  echo "usage: make git-commit MSG=\"your message\""; exit 2; \
	fi
	@# Submodules first so the pointers we record in main are the new SHAs.
	@for sub in $(SUBMODULES); do \
	  echo "── clients/$$sub ──"; \
	  (cd clients/$$sub && \
	    if ! git diff --cached --quiet || ! git diff --quiet || \
	       [ -n "$$(git ls-files --others --exclude-standard)" ]; then \
	      git add -A && git commit -m "$(MSG)"; \
	    else echo "  (no changes)"; fi); \
	done
	@echo "── main ──"
	@git add -A && \
	  if ! git diff --cached --quiet; then git commit -m "$(MSG)"; \
	  else echo "  (no main-repo changes)"; fi

git-push: ## Push main AND both submodules (needs push rights on all three)
	@for sub in $(SUBMODULES); do \
	  echo "── clients/$$sub ──"; \
	  (cd clients/$$sub && git push origin HEAD:main); \
	done
	@echo "── main ──"
	@git push

git-pull: ## Pull main AND fast-forward both submodules
	@echo "── main ──"
	@git pull --ff-only
	@for sub in $(SUBMODULES); do \
	  echo "── clients/$$sub ──"; \
	  git submodule update --remote --merge clients/$$sub; \
	done

# ── housekeeping ──────────────────────────────────────────────────────────

clean: ## Remove generated clients/, processed swaggers, local scratch
	@# Never `rm -rf clients/`: that deletes the .git gitfile inside each
	@# submodule mount, silently turning it into a plain directory — after
	@# which regeneration writes into the main repo instead of the sibling
	@# repo. Same invariant generate.sh protects.
	rm -rf clients/python clients/typescript clients/go clients/java clients/.tmp
	@for sub in $(SUBMODULES); do rm -rf clients/$$sub/src; done
	rm -rf swaggers/processed/ .venv/ .cache/
