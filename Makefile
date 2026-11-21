VERSION ?= 0.0.0.dev0
SUBMODULES := php onescript go rust
DOCS ?= ../wb-api-client-docs
PY := $(shell test -x .venv/bin/python && echo .venv/bin/python || echo python3)
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
DOTNET_DOCKER = docker run --rm -u $$(id -u):$$(id -g) \
                -v $(CURDIR)/clients/csharp:/app -w /app \
                -e HOME=/tmp -e DOTNET_CLI_TELEMETRY_OPTOUT=1 -e DOTNET_NOLOGO=1 \
                -e NUGET_PACKAGES=/tmp/.nuget \
                mcr.microsoft.com/dotnet/sdk:8.0
RUST_DOCKER = docker run --rm -u $$(id -u):$$(id -g) \
                -v $(CURDIR)/clients/rust:/app -w /app \
                -e HOME=/tmp -e CARGO_HOME=/tmp/.cargo \
                -e CARGO_TARGET_DIR=/tmp/.cargo-target \
                rust:1.98-slim
RUSTFMT_DOCKER = docker run --rm \
                -v $(CURDIR)/clients/rust:/app -w /app \
                rust:1.98-slim sh -c

.DEFAULT_GOAL := help
.PHONY: help venv download post-process generate regen reference \
        test verify verify-python verify-ts verify-go verify-java verify-php \
        verify-csharp \
        verify-onescript verify-rust \
        gofmt black prettier spotless php-cs-fixer dotnet-format rustfmt clean \
        git-status git-commit git-push git-pull check-submodules

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

download: ## Pull spec YAMLs (ru + en) from the specs mirror
	$(PY) scripts/download-specs.py

post-process: ## Run all post-processing passes on specs/unprocessed/{ru,en}/
	$(PY) scripts/process-specs.py

generate: post-process ## Regenerate all six language clients
	$(PY) scripts/generate-clients.py $(VERSION)

regen: download post-process generate ## Full pipeline: download → process → generate

reference: ## Regenerate the docs-site API reference into $(DOCS)
	@test -d "$(DOCS)/docs/.vitepress" || \
	  { echo "No docs checkout at $(DOCS) — clone wb-api-client-docs or pass DOCS=<path>"; exit 1; }
	$(PY) scripts/generate-docs.py "$(DOCS)/docs"

# ── verification ──────────────────────────────────────────────────────────

scripts-check: ## Smoke-check the pipeline kernel and ban `#` comments under scripts/
	PYTHONPATH=scripts $(PY) -m pipeline.core.selfcheck
	PYTHONPATH=scripts $(PY) -m pipeline.core.commentcheck

test: ## Run the scripts test suite (YAML fixture cases)
	PYTHONPATH=scripts $(PY) -m pytest tests -q

verify: scripts-check test verify-python verify-ts verify-go verify-java verify-php verify-csharp verify-onescript verify-rust gofmt black prettier spotless php-cs-fixer dotnet-format rustfmt ## Build every language + fmt checks

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
	$(PHP_DOCKER) composer validate --no-check-publish
	@docker run --rm -u $$(id -u):$$(id -g) -v $(CURDIR)/clients/php:/app -w /app \
	  -e HOME=/tmp php:8.3-cli-alpine sh -c \
	  "find src -name '*.php' -print0 | xargs -0 -n1 php -l >/dev/null && echo '  ✓ php -l passes on every file'"

verify-csharp: ## Build the C# package
	@echo "── C# ─────────────────────────────────────────"
	$(DOTNET_DOCKER) dotnet build -v q --nologo
	@echo "  ✓ dotnet build OK"

verify-onescript: ## Compile-check every OneScript module + load the package
	@echo "── OneScript ──────────────────────────────────"
	$(PY) scripts/verify-onescript.py

verify-rust: ## cargo build the whole crate
	@echo "── Rust ───────────────────────────────────────"
	$(RUST_DOCKER) cargo build
	@echo "  ✓ cargo build OK"

rustfmt: ## Fail if any Rust file needs `cargo fmt`
	@$(RUSTFMT_DOCKER) "rustup component add rustfmt >/dev/null 2>&1 && cargo fmt -- --check" \
	  && echo "  ✓ rustfmt clean"

dotnet-format: ## Fail if any C# file needs `dotnet format`
	@$(DOTNET_DOCKER) dotnet format whitespace --verify-no-changes --no-restore -v q \
	  && echo "  ✓ dotnet format clean"

gofmt: ## Fail if any Go file needs `gofmt -w`
	@out=$$(docker run --rm -v $(CURDIR)/clients/go:/app -w /app golang:1.22-alpine gofmt -l . 2>&1); \
	 if [ -n "$$out" ]; then echo "gofmt needed:"; echo "$$out"; exit 1; \
	 else echo "  ✓ gofmt clean"; fi

black: ## Fail if any Python file (clients/python or scripts/) needs `black`
	@$(PY) -m black --check --quiet clients/python scripts tests && echo "  ✓ black clean"

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

git-status: ## Show `git status` in main repo AND all submodules
	@echo "── main repo ──"
	@git status --short
	@for sub in $(SUBMODULES); do \
	  echo ""; echo "── clients/$$sub submodule ──"; \
	  (cd clients/$$sub && git status --short); \
	done

git-commit: ## Commit main + all submodules with the same message (MSG=…)
	@if [ -z "$(MSG)" ]; then \
	  echo "usage: make git-commit MSG=\"your message\""; exit 2; \
	fi
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

git-push: ## Push main AND all submodules (needs push rights on all four)
	@for sub in $(SUBMODULES); do \
	  url=$$(git config -f .gitmodules --get submodule.clients/$$sub.url); \
	  echo "── clients/$$sub → $$url ──"; \
	  (cd clients/$$sub && git push "$$url" HEAD:main) || exit 1; \
	done
	@echo "── main ──"
	@git push
	@$(MAKE) --no-print-directory check-submodules

check-submodules: ## Fail if a recorded submodule pointer is missing from its remote
	@rc=0; \
	 for sub in $(SUBMODULES); do \
	   url=$$(git config -f .gitmodules --get submodule.clients/$$sub.url); \
	   sha=$$(git ls-tree HEAD clients/$$sub | awk '{print $$3}'); \
	   if [ -z "$$sha" ]; then \
	     echo "  ! clients/$$sub is not a gitlink in HEAD"; rc=1; continue; \
	   fi; \
	   if git ls-remote "$$url" 2>/dev/null | grep -q "$$sha"; then \
	     echo "  ✓ clients/$$sub $$(echo $$sha | cut -c1-12) is on its remote"; \
	   else \
	     echo "  ✗ clients/$$sub $$(echo $$sha | cut -c1-12) is NOT on $$url"; \
	     echo "    push that repo first, or CI will fail cloning the submodule"; \
	     rc=1; \
	   fi; \
	 done; \
	 exit $$rc

git-pull: ## Pull main AND fast-forward all submodules
	@echo "── main ──"
	@git pull --ff-only
	@for sub in $(SUBMODULES); do \
	  echo "── clients/$$sub ──"; \
	  git submodule update --remote --merge clients/$$sub; \
	done

# ── housekeeping ──────────────────────────────────────────────────────────

clean: ## Remove generated clients/, processed specs, local scratch
	rm -rf clients/python clients/typescript clients/java clients/csharp clients/.tmp
	@for sub in $(SUBMODULES); do rm -rf clients/$$sub/src; done
	rm -rf clients/go/*/ clients/go/go.sum
	rm -f clients/rust/Cargo.toml clients/rust/Cargo.lock
	rm -rf specs/processed/ .venv/ .cache/
