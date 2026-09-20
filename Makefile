# Convenience wrappers around the scripts in scripts/. Nothing here does
# anything the pipeline can't do directly — this is just the short-command
# surface for day-to-day work.
#
# Run `make` (or `make help`) to see the list.

# ── config ────────────────────────────────────────────────────────────────

# Version stamped into every generated manifest. Overridable:
#   make generate VERSION=2026.09.20
VERSION ?= 0.0.0.dev0

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
        gofmt black prettier spotless php-cs-fixer clean

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

generate: post-process ## Regenerate all four language clients
	./scripts/generate.sh $(VERSION)

regen: download post-process generate ## Full pipeline: download → process → generate

# ── verification ──────────────────────────────────────────────────────────

verify: verify-python verify-ts verify-go verify-java verify-php gofmt black prettier spotless php-cs-fixer ## Build every language + fmt checks

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

# ── housekeeping ──────────────────────────────────────────────────────────

clean: ## Remove generated clients/, processed swaggers, local scratch
	rm -rf clients/ swaggers/processed/ .venv/
