# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A code-generation pipeline, not a hand-written library. The only human-authored source is:

- `scripts/` — download, post-process, generate, inject-secret, gen-readmes
- `generator-configs/` — one YAML per target language, passed to `openapi-generator-cli`
- `templates/` — top-level manifests (`pyproject.toml`, `package.json`, `go.mod`, `pom.xml`, `composer.json`) with `__VERSION__` placeholders
- `.github/workflows/` — daily upstream check + PR-drift check + reusable per-language publish

Everything under `clients/` is generated output. Do not edit it — regenerate.

## Pipeline

```
download-swaggers.sh   →  swaggers/*.yaml         (raw upstream, checksummed)
post-process.py        →  swaggers/processed/     (7 passes; see below)
generate.sh <ver>      →  clients/<lang>/…        (openapi-generator-cli, 6 langs)
    ├── inject-secret.py           (SecretString wrapper per lang; OneScript ships its own)
    ├── {black|prettier|gofmt|spotless|php-cs-fixer}   (canonicalize formatting)
    ├── gen-onescript-manifests.py (unified packagedef + lib.config)
    └── gen-readmes.py             (per-language README.md)
     ↓ committed at v<version>, single tag covers all 6 languages
publish.yml            →  PyPI / npm / Go tag / Maven Central / Packagist / hub.oscript.io
```

`swaggers/`, `clients/python/`, `clients/typescript/`, `clients/go/`, `clients/java/`, `clients/onescript/` are committed here at each release tag. `clients/php/` is a **git submodule** pointing at [`ValeryVerkhoturov/wb-api-client-php`](https://github.com/ValeryVerkhoturov/wb-api-client-php) — Packagist requires `composer.json` at the ROOT of the crawled repo, so PHP can't live under `clients/`. daily-check.yml regenerates everything, commits and tags the sibling PHP repo FIRST, then commits + tags the main repo (which now includes the bumped submodule pointer), then dispatches publish per language. `publish.yml` is a pure publish step — it does not regenerate; it checks out the tag and pushes to the registry. Rationale: consumers can browse and pin exact source; Go modules resolve directly from the tag; Packagist crawls the sibling repo's tag; audits diff cleanly between releases.

**Submodule mechanics for local dev**: `git clone --recurse-submodules` clones both. If you already cloned without: `git submodule update --init --recursive`. The tracked URL in `.gitmodules` is the GitHub HTTPS URL; local iteration can override to a `file://` path with `git config -f .git/config submodule.clients/php.url file:///path/to/wb-api-client-php`. `scripts/generate.sh` writes to `clients/php/…` unchanged — the mount transparently redirects into the submodule working tree.

`pr-check.yml` enforces the invariant on pull requests: it regenerates from scratch using the version currently baked into `clients/python/pyproject.toml`, then fails the PR if `git diff` against `swaggers/` or `clients/` is non-empty. For that check to be meaningful, generation must be deterministic — every generator config sets `hideGenerationTimestamp: true`, and the openapi-generator Docker image tag is pinned in `generate.sh`. Each formatter version is pinned too (black in `scripts/requirements.txt`; prettier in `templates/typescript/package.json`; google-java-format via spotless in `templates/java/pom.xml`; php-cs-fixer image tag in `generate.sh`; gofmt bundled with pinned `golang:1.22-alpine`). If a change makes generation non-deterministic (e.g. re-adds a timestamp), PRs will flap; fix at the source rather than skipping the check.

The daily workflow uses `swaggers/checksums.txt` to decide whether upstream changed. That file is committed alongside the specs and is what makes the "release only when upstream moves" behavior work — don't hand-edit it.

## Auth model — non-obvious

Upstream YAMLs (`dev.wildberries.ru/api/swagger/yaml/ru/*.yaml`) declare a `HeaderApiKey` scheme (apiKey named "Authorization"), which duplicates the actual bearer JWT semantics and makes openapi-generator emit two auth code paths per operation. `scripts/post-process.py`'s `inject_bearer_auth` deletes every pre-existing scheme and rewires every `security` requirement to a single `BearerAuth` (HTTP bearer, JWT). Generated clients then expose exactly one token parameter.

The bearer JWT is stored inside a **secret-string wrapper** per language so it redacts under logs / `print` / `console.log` / `System.out.println` / `fmt.Printf` / `var_dump` unless explicitly exposed. `scripts/inject-secret.py` patches every generated `Configuration`/`ApiClient` to accept the wrapper:

| Language | Wrapper | Setter | Explicit expose |
|---|---|---|---|
| Python | `pydantic.SecretStr` | `Configuration(access_token=str_or_SecretStr)` | `.get_secret_value()` |
| TypeScript | inlined `SecretString` class | `Configuration.setAccessToken(token)` | `.exposeSecret()` |
| Go | `github.com/negrel/secrecy` | `Configuration.SetAccessToken(token)` | `.ExposeSecret()` |
| Java | per-sub-module `SecretString` | `ApiClient.setBearerToken(SecretString)` | `.exposeSecret()` |
| PHP | per-sub-module `SecretString` | `Configuration::setAccessTokenSecret(SecretString)` | `->exposeSecret()` |
| OneScript | `СекретнаяСтрока` | `Конфигурация.УстановитьТокен(строка или СекретнаяСтрока)` | `.Раскрыть()` |

For Go we additionally strip the openapi-generator-default `ContextAccessToken` context-value channel — `cfg.SetAccessToken` is the only auth path, so no accidental bypass is possible.

## Versioning

Format: `1.YYYYMMDD.N` (stable semver + PEP 440 in one string, used verbatim by every language).

- **MAJOR = 1** — fixed. Keeps Go's module path free of the `/vN` suffix that MAJOR ≥ 2 would require.
- **MINOR = YYYYMMDD** — UTC release date as int. Monotonic across days (`20260919 < 20260920`).
- **PATCH = N** — same-day counter (0 for the first release of the day, 1, 2, … for repeats).

Computed in `daily-check.yml`: `n=$(git tag --list "v1.$(date -u +%Y%m%d).*" | wc -l); version="1.$(date -u +%Y%m%d).${n}"`. `npm install pkg` / `pip install pkg` / `mvn dep` / `composer require` / `go get pkg@latest` all auto-pick the highest because these are true stable releases, not prereleases.

## Package layout — one library per language, 13 sub-modules inside

6 published packages per release (one per language), each bundling all 13 WB API categories as isolated sub-namespaces. `openapi-generator` still emits a standalone SDK per spec (own `ApiClient`, own model namespace); `generate.sh` splices those 13 outputs into a single unified tree with no cross-category name clashes:

```
clients/python/wb_api_client/<slug>/…           (packageName=wb_api_client.<slug>)
clients/typescript/src/<slug>/… + subpath exports in package.json
clients/go/<slug>/…                             (single go.mod at clients/go)
clients/java/src/main/java/io/github/valeryverkhoturov/wbapi/<slug>/…
clients/php/src/<Slug>/…                        (PSR-4 ValeryVerkhoturov\WbApiClient\<Slug>)
clients/onescript/src/{Классы,Модели}/<Slug>/…   (no namespaces — see below)
```

Package names on each registry (some diverge from the natural `wb-api-client` because that name is taken):

| Registry | Package |
|---|---|
| PyPI | `valeryverkhoturov-wb-api-client` (bare `wb-api-client` was already claimed) |
| npm | `@valeryverkhoturov/wb-api-client` (scoped) |
| Maven Central | `io.github.valeryverkhoturov:wb-api-client` |
| Go (git tag) | `github.com/ValeryVerkhoturov/wb-api-client/clients/go` |
| Packagist | `valeryverkhoturov/wb-api-client` |
| hub.oscript.io | `wb-api-client` |

Top-level manifests come from `templates/{python,typescript,go,java,php,onescript}/`. `__VERSION__` (and `__EXPORTS__` for TS) is substituted at generate time — do not hand-edit `clients/*/package.json` etc., they're regenerated on every run.

Slugs come from the spec filename (`02-items.yaml` → `items`, snake_cased where needed, PascalCased for PHP). Keep spec filenames stable — they become part of every import path.

## User-Agent

Every generated client sends `ValeryVerkhoturov/wb-api-client/<lang>` on every request:

- Python, Go, Java: via the `httpUserAgent` generator config option
- TypeScript: seeded into `Configuration.baseOptions.headers` by inject-secret.py (typescript-axios generator doesn't accept `httpUserAgent`)
- PHP: `Configuration::$userAgent` default is replaced by inject-secret.py (php generator doesn't accept `httpUserAgent` either)
- OneScript: the `userAgent` generator option in `generator-configs/onescript.yaml`

## post-process.py passes (in order)

1. `inject_bearer_auth` — drops WB's `HeaderApiKey` and installs `BearerAuth` as the only scheme
2. `fix_untyped_arrays` — `items: {type: string}` for arrays missing an inner type (Go/TS otherwise emit `Array` / `any`)
3. `inline_top_level_arrays` — inlines every `$ref` to a `type: array` component, collapses `allOf: [array, description-only]` wrappers (openapi-generator mishandles arrays-at-root; runs to fixed point because inlined subtrees can contain further refs)
4. `rename_digit_prefixed_schemas` — `409SupplyDeliverError` → `Http409SupplyDeliverError` (invalid Go identifier otherwise)
5. `name_inline_response_schemas` — hoists anonymous inline 4xx/5xx bodies to `<OperationId>Response<code>` (invalid Go identifier otherwise)
6. `sanitize_non_ascii_enums` — adds `x-enum-varnames` for `["Склад WB", "Склад продавца"]`-style enums (empty JS/Go/Java identifiers otherwise)
7. `htmlize_descriptions_to_markdown` — every `description` field goes through `markdownify` (`<div>`, `<a href>`, `<br>`, `<ul>`, `<code>` → Markdown for readable doc-comments)
8. `absolutize_description_links` — prefixes `[…](/openapi/…)` with `https://dev.wildberries.ru` so links in generated docstrings resolve

(Counted as "8 passes" if you split HTML→MD and link-absolutize; the pipeline diagram calls it 7 for the sake of the "one big semantic step for descriptions" reading.)

## Anti-bot on downloads

`dev.wildberries.ru` sits behind WBAAS and returns HTTP 498 with a JS challenge to non-browser clients. `download-swaggers.sh` sidesteps it by sending a hardcoded `x_wbaas_token` cookie plus the matching browser UA. That cookie is bound to the browser session that minted it (IP + UA fingerprint encoded in the token itself) and expires; when the daily CI download starts 498-ing, the fix is to grab a fresh cookie from a browser and either update `DEFAULT_WBAAS_TOKEN` in the script or set the `WBAAS_TOKEN` env var / GitHub Actions secret. Do not strip the checksum step to hide download failures — daily-check depends on it.

## Local commands

```bash
./scripts/download-swaggers.sh                     # pull upstream (may 498 locally)
pip install -r scripts/requirements.txt            # ruamel.yaml, markdownify, black, flask
python  scripts/post-process.py                    # -> swaggers/processed/
./scripts/generate.sh 1.20260920.0                 # -> clients/{python,typescript,go,java,php,onescript}
make verify                                         # build + format check every language
```

`generate.sh` always regenerates all six languages; if you need per-language iteration during debugging, comment out the other four loops rather than adding a flag — the script is <200 lines and doesn't need argument plumbing.

Formatting runs inside Docker so contributors don't need language runtimes installed. `make verify-<lang>` and `make {black,prettier,gofmt,spotless,php-cs-fixer}` are individual targets. `make help` lists all.

## Publishing credentials

Configured in GitHub Environments referenced by `publish.yml`:

| Environment | Auth mechanism | Secrets |
|---|---|---|
| `pypi` | OIDC trusted publishing | none — configure trusted publisher on pypi.org for `valeryverkhoturov-wb-api-client`, workflow `publish.yml`, env `pypi` |
| `npm` | OIDC trusted publishing (npm ≥ 11.5.1) | none — configure trusted publisher on npmjs.com for `@valeryverkhoturov/wb-api-client`, workflow `publish.yml`, env `npm`, allow publish directly |
| `maven-central` | GPG-signed deploy | `MAVEN_USERNAME`, `MAVEN_PASSWORD`, `MAVEN_GPG_PRIVATE_KEY`, `MAVEN_GPG_PASSPHRASE` |
| `packagist` | API token + separate GitHub repo | `PACKAGIST_USERNAME`, `PACKAGIST_API_TOKEN` — package pre-registered at packagist.org pointing at `wb-api-client-php` sibling repo |
| `onescript` | `opm push` to hub.oscript.io | `OSCRIPT_HUB_TOKEN` — a GitHub token used only to verify the pusher's identity; package pre-registered on the hub |
| Go (no env) | git tags only | none — `proxy.golang.org` fetches from the pushed tag |
| — (repo-level) | `PHP_REPO_TOKEN` PAT (repo scope) for pushing tags to `wb-api-client-php` in daily-check; falls back to `GITHUB_TOKEN` for read-only PR checks |

PyPI + npm trusted publishing: **the "Workflow filename" on pypi.org and npmjs.com must be `publish.yml`**, and daily-check must dispatch it via `gh workflow run publish.yml` (workflow_dispatch), NOT `uses: ./.github/workflows/publish.yml` (workflow_call). Reason: trusted publishing verifies both the OIDC `job_workflow_ref` claim and the Sigstore attestation cert's `workflow_ref` extension. With workflow_call those two claims point at *different* files (callee vs caller) and no TP config can satisfy both — PyPI explicitly does not support reusable workflows. Dispatching makes publish.yml a top-level workflow so both claims resolve to it. Environment names on the TP page must match the `environment:` value on the publish job (`pypi` / `npm`).

## OneScript-specific quirks

- **The generator is out-of-tree.** openapi-generator has no OneScript target, so
  `-g onescript` comes from a plugin in
  [`ValeryVerkhoturov/onescript-openapi-generator`](https://github.com/ValeryVerkhoturov/onescript-openapi-generator),
  loaded next to `openapi-generator-cli.jar` on the classpath (Java merges both
  `META-INF/services` entries). `scripts/onescript-toolchain.sh` pins it **by commit**
  and builds it in the Maven image, caching the jar under `.cache/`. That pin is the
  OneScript equivalent of `OPENAPI_GENERATOR_VERSION` — bump it deliberately, since it
  decides every generated name.
- **No namespaces.** Every OneScript class name is global, so the usual
  "one sub-namespace per category" trick doesn't exist. Tag names happen to be unique
  across all 13 specs, so API classes keep the tag (`КарточкиТоваровApi`); model names
  are *not* unique (34 repeat, `Response4XX` in 12 specs), so each category is passed
  `modelNamePrefix=<Slug>` and its models come out as `ItemsResponse4XX`,
  `OrdersFbsResponse4XX`. Directories under `src/Классы/` and `src/Модели/` are for
  humans only — `lib.config` is what actually resolves a class.
- **`lib.config` is the registry.** A class missing from it is unreachable no matter
  where its file sits. `scripts/gen-onescript-manifests.py` rebuilds it (and
  `packagedef`) from the spliced tree, sorted, so a new spec surfaces without editing
  anything and the manifests stay byte-stable for `pr-check`. It also fails loudly on
  a case-insensitive name collision — BSL identifiers ignore case, so two classes
  differing only in case would silently shadow one another.
- **`packagedef` must not list `lib.config`.** `opm build` regenerates its own copy
  inside the `.ospx` from the `ОпределяетКласс` lines; listing it as an included file
  too makes the build fail with a duplicate-key error. The committed `lib.config` is
  what makes `#Использовать` work straight from a checkout.
- **The runtime is shared, not per-category.** The plugin emits
  `Конфигурация` / `СекретнаяСтрока` / `ТранспортHTTP` / `ОтветAPI` into every package;
  the splice keeps one copy. They are byte-identical across specs except `Конфигурация`,
  which documents its own spec's default host — that line is stripped, because here 13
  categories sit on different hosts and each operation already carries its own address.
- **Never extract the OneScript archive with `unzip`.** Entry names are Cyrillic UTF-8;
  Info-ZIP rewrites them (as `#Uxxxx` escapes on Linux, as decomposed NFD with some
  macOS tools), which leaves every path in `lib.config` dangling and breaks OneScript's
  own bundled libraries — `asserts` first, which cascades into `cli`, `logos` and `opm`.
  `python3 -m zipfile -e` reads the names as stored; the toolchain script and
  `publish.yml` both use it.
- **macOS Gatekeeper SIGKILLs the unsigned arm64 `oscript`** with no diagnostic of its
  own. `onescript-toolchain.sh` clears the quarantine flag and ad-hoc signs the binary
  and its dylibs right after extraction.
- **No formatter.** There is no community formatter for BSL, so there is no
  OneScript counterpart to black/prettier/gofmt/spotless/php-cs-fixer. The equivalent
  gate is `scripts/verify-onescript.sh`: `oscript -check` over every module (in
  parallel — it is one process per file) plus a `#Использовать` load of the package,
  which is what proves `lib.config` actually resolves.
- **Errors carry text, not objects.** `ВызватьИсключение <объект>` does not preserve the
  object for the handler, so the transport raises a formatted string. Set
  `Настройки.ВыбрасыватьИсключениеПриОшибке = Ложь` to inspect `ОтветAPI` instead.

## PHP-specific quirks

- **Lives in a separate git repo** (`ValeryVerkhoturov/wb-api-client-php`), mounted here as the `clients/php` submodule — Packagist requires `composer.json` at the crawled repo root, which rules out a subdirectory layout. See the pipeline section for how daily-check.yml coordinates commits + tags across both repos.
- PSR-4 root namespace: `ValeryVerkhoturov\WbApiClient\`; each slug is a PascalCase sub-namespace (`Items`, `OrdersFbs`, `InStorePickup`, …)
- `composer.json` keeps the `version` field even though Packagist prefers to derive it from git tags — the field is how the pipeline stamps a uniform version across every language manifest. `composer validate --strict` therefore fails; `make verify-php` runs plain `composer validate --no-check-publish`
- openapi-generator's PHP template writes `src/{Api,Model,Configuration.php,ApiException.php,HeaderSelector.php,ObjectSerializer.php}` at a flat root with the invoker namespace declared inside the files. `generate.sh` splices the whole `src/` contents into `clients/php/src/<Slug>/` (which resolves through the submodule mount to `wb-api-client-php/src/<Slug>/`), so PSR-4 resolves `\ValeryVerkhoturov\WbApiClient\<Slug>\Configuration` to `src/<Slug>/Configuration.php`
- `SecretString` lives per sub-module (not consolidated) because PHP autoload is namespace-scoped and each sub-module already has its own namespace root — no reason to force consumers to cross namespace boundaries
