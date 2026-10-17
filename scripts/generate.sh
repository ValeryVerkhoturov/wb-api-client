#!/usr/bin/env bash
set -euo pipefail

# Generate one consolidated client library per language, containing all 13
# WB API categories as sub-modules. openapi-generator emits a self-contained
# SDK per spec, so this script generates each spec into a scratch directory
# and then splices the per-slug source tree into the unified layout:
#
#   clients/python/wb_api_client/<slug>/…
#   clients/typescript/src/<slug>/…
#   clients/go/<slug>/…
#   clients/java/src/main/java/io/github/valeryverkhoturov/wbapi/<slug>/…
#   clients/php/src/<Slug>/…                (PSR-4 ValeryVerkhoturov\WbApiClient\<Slug>)
#
# Top-level manifests (pyproject.toml, package.json, go.mod, pom.xml,
# composer.json) come from templates/ with __VERSION__ substituted in.
#
# Usage: generate.sh <version>

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <version>" >&2
  exit 2
fi

VERSION="$1"

# Canonical version format `1.YYYYMMDD.N` is stable-semver + PEP 440 in
# one — no per-language transform needed.

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SPEC_DIR="${REPO_ROOT}/swaggers/processed"
CLIENTS_DIR="${REPO_ROOT}/clients"
CONFIG_DIR="${REPO_ROOT}/generator-configs"
TEMPLATE_DIR="${REPO_ROOT}/templates"

if [[ ! -d "${SPEC_DIR}" ]] || ! compgen -G "${SPEC_DIR}/*.yaml" >/dev/null; then
  echo "no processed specs at ${SPEC_DIR} — run post-process.py first" >&2
  exit 1
fi

# All generator tasks share one official Docker container and JVM. The repo is
# mounted at /work, and batch configs reference paths inside that mount.
OPENAPI_GENERATOR_VERSION="${OPENAPI_GENERATOR_VERSION:-v7.10.0}"
OPENAPI_GENERATOR_THREADS="${OPENAPI_GENERATOR_THREADS:-2}"
in_container() { echo "${1#${REPO_ROOT}/}"; }

# OneScript has no generator in openapi-generator itself. The plugin lives in
# a sibling repo, pinned by commit, and is loaded next to the CLI jar on the
# classpath — Java merges both META-INF/services entries, so `onescript`
# resolves exactly like a built-in generator.
# shellcheck source=scripts/onescript-toolchain.sh
source "${REPO_ROOT}/scripts/onescript-toolchain.sh"
ensure_onescript_plugin

# Runtime classes the plugin emits into every generated package. They are
# identical across specs (bar Конфигурация — see the splice below), so the
# unified package keeps exactly one copy of each.
ONESCRIPT_RUNTIME=(Конфигурация СекретнаяСтрока ТранспортHTTP ОтветAPI)

JAVA_GROUP_PATH="io/github/valeryverkhoturov/wbapi"

# category slug from spec filename: "02-items.yaml" → "items"
slug_from_spec() {
  local base
  base="$(basename "$1" .yaml)"
  echo "${base#*-}"
}

# Queue one isolated output directory for the single batch invocation below.
# Optional args: one global property, then a template override directory (PHP).
queue_generation() {
  local name="$1" lang_config="$2" lang="$3" spec="$4" out="$5"
  local properties_csv="$6" global_property="${7:-}" template_dir="${8:-}"
  local config="${SCRATCH}/configs/${name}.yaml"
  local property
  local -a properties

  {
    printf "'!include': '%s'\n" "$(in_container "${lang_config}")"
    printf "generatorName: '%s'\n" "${lang}"
    printf "inputSpec: '/work/%s'\n" "$(in_container "${spec}")"
    printf "outputDir: '/work/%s'\n" "$(in_container "${out}")"
    printf "additionalProperties:\n"
    IFS=',' read -ra properties <<< "${properties_csv}"
    for property in "${properties[@]}"; do
      printf "  %s: '%s'\n" "${property%%=*}" "${property#*=}"
    done
    if [[ -n "${global_property}" ]]; then
      printf "globalProperties:\n  %s: '%s'\n" "${global_property%%=*}" "${global_property#*=}"
    fi
    printf "skipValidateSpec: true\n"
    if [[ -n "${template_dir}" ]]; then
      printf "templateDir: '/work/%s'\n" "$(in_container "${template_dir}")"
    fi
  } > "${config}"
  BATCH_CONFIGS+=("$(in_container "${config}")")
}

# Reset the non-submodule client trees. Leave clients/php,
# clients/onescript and clients/go alone — all three are git submodules
# (pointing at wb-api-client-php, wb-api-client-1c and wb-api-client-go),
# and `rm -rf` would blow away their .git gitfile, silently converting the
# mount into a plain directory. Subsequent writes would then land in an
# orphaned dir under the main repo instead of the sibling repo's working
# tree.
rm -rf "${CLIENTS_DIR}"/{python,typescript,java,csharp}

# Guard: each submodule dir MUST be a proper mount before we write into
# it, otherwise the manifests + src/ we produce would sit as untracked
# bytes in the main repo, invisible to consumers — Packagist crawls the
# PHP sibling repo, the OneScript package is published from the 1c one,
# and `go get` resolves the Go module from the go one's tags.
#
# Clear only the generated payloads (regen recreates them from scratch).
# Preserve everything else in the mount: composer.json / packagedef /
# go.mod, README.md, LICENSE, .gitignore, and — critically — the .git
# gitfile that makes the mount work.
for submodule in php onescript go; do
  if [[ -e "${CLIENTS_DIR}/${submodule}/.git" ]]; then
    case "${submodule}" in
      php|onescript) rm -rf "${CLIENTS_DIR}/${submodule}/src" ;;
      # Go has no src/: generated payload is the slug package dirs and
      # go.sum (go.mod is overwritten from templates/ later, README.md by
      # gen-readmes.py).
      go) rm -rf "${CLIENTS_DIR}"/go/*/ "${CLIENTS_DIR}/go/go.sum" ;;
    esac
    continue
  fi

  case "${submodule}" in
    php)       sibling="wb-api-client-php" ;;
    onescript) sibling="wb-api-client-1c" ;;
    go)        sibling="wb-api-client-go" ;;
  esac

  cat >&2 <<EOF
error: clients/${submodule} is not a git submodule mount (${CLIENTS_DIR}/${submodule}/.git missing).
       Output would land in an orphaned directory, not the sibling
       ${sibling} repo. Initialize the submodule first:

           git submodule update --init clients/${submodule}

       On a fresh checkout add --recurse-submodules to the clone. For
       local dev without the GitHub sibling repo available, override
       the URL:

           git config -f .git/config submodule.clients/${submodule}.url \\
               file:///path/to/${sibling}
           git submodule sync clients/${submodule}
           git -c protocol.file.allow=always submodule update --init clients/${submodule}
EOF
  exit 1
done

mkdir -p "${CLIENTS_DIR}"/{python/wb_api_client,typescript/src,go,java/src/main/java/${JAVA_GROUP_PATH},php/src,csharp/src} \
         "${CLIENTS_DIR}/onescript/src/Классы" "${CLIENTS_DIR}/onescript/src/Модели"
SCRATCH="${CLIENTS_DIR}/.tmp"
mkdir -p "${SCRATCH}"

# Collect slugs for manifests and queue every generator task with an isolated
# scratch output. The batch command reuses one container/JVM for all 91 tasks.
SLUGS=()
BATCH_CONFIGS=()
mkdir -p "${SCRATCH}/configs"
for spec in "${SPEC_DIR}"/*.yaml; do
  slug="$(slug_from_spec "${spec}")"
  slug_snake="${slug//-/_}"
  slug_pascal="$(printf '%s' "${slug_snake}" | awk 'BEGIN{FS="_";OFS=""} {for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1')"
  common_properties="packageVersion=${VERSION},artifactVersion=${VERSION},npmVersion=${VERSION}"
  java_pkg="io.github.valeryverkhoturov.wbapi.${slug_snake}"
  php_ns="ValeryVerkhoturov\\WbApiClient\\${slug_pascal}"
  SLUGS+=("${slug}")

  queue_generation "py-${slug_snake}" "${CONFIG_DIR}/python.yaml" python \
    "${spec}" "${SCRATCH}/py-${slug_snake}" \
    "${common_properties},packageName=wb_api_client.${slug_snake},projectName=wb_api_client_${slug_snake}" \
    "skipFormModel=false"
  queue_generation "ts-${slug}" "${CONFIG_DIR}/typescript.yaml" typescript-axios \
    "${spec}" "${SCRATCH}/ts-${slug}" \
    "${common_properties},npmName=@valeryverkhoturov/wb-api-client-${slug}" \
    "skipFormModel=false"
  queue_generation "go-${slug_snake}" "${CONFIG_DIR}/go.yaml" go \
    "${spec}" "${SCRATCH}/go-${slug_snake}" \
    "${common_properties},packageName=${slug_snake}" \
    "skipFormModel=false"
  queue_generation "java-${slug}" "${CONFIG_DIR}/java.yaml" java \
    "${spec}" "${SCRATCH}/java-${slug}" \
    "${common_properties},artifactId=wb-api-client-${slug},invokerPackage=${java_pkg},apiPackage=${java_pkg}.api,modelPackage=${java_pkg}.model" \
    "skipFormModel=false"
  queue_generation "php-${slug_snake}" "${CONFIG_DIR}/php.yaml" php \
    "${spec}" "${SCRATCH}/php-${slug_snake}" \
    "${common_properties},invokerPackage=${php_ns},packageName=WbApiClient${slug_pascal},composerPackageName=valeryverkhoturov/wb-api-client-${slug}" \
    "skipFormModel=false" "${TEMPLATE_DIR}/php"
  queue_generation "cs-${slug_snake}" "${CONFIG_DIR}/csharp.yaml" csharp \
    "${spec}" "${SCRATCH}/cs-${slug_snake}" \
    "${common_properties},packageName=ValeryVerkhoturov.WbApiClient.${slug_pascal}" \
    "skipFormModel=false"
  queue_generation "os-${slug_snake}" "${CONFIG_DIR}/onescript.yaml" onescript \
    "${spec}" "${SCRATCH}/os-${slug_snake}" \
    "packageVersion=${VERSION},modelNamePrefix=${slug_pascal}"
done

echo "→ ${#BATCH_CONFIGS[@]} generator tasks (${OPENAPI_GENERATOR_THREADS} threads)"
docker run --rm -u "$(id -u):$(id -g)" \
  -v "${REPO_ROOT}:/work" \
  -v "${ONESCRIPT_PLUGIN}:/plugin.jar:ro" \
  -w /work \
  --entrypoint java \
  "openapitools/openapi-generator-cli:${OPENAPI_GENERATOR_VERSION}" \
  -cp "/plugin.jar:/opt/openapi-generator/modules/openapi-generator-cli/target/openapi-generator-cli.jar" \
  org.openapitools.codegen.OpenAPIGenerator batch \
  --fail-fast --includes-base-dir /work \
  --threads "${OPENAPI_GENERATOR_THREADS}" \
  -- "${BATCH_CONFIGS[@]}" >/dev/null

# Splice the completed scratch trees into the unified packages sequentially.
for spec in "${SPEC_DIR}"/*.yaml; do
  slug="$(slug_from_spec "${spec}")"        # e.g. "orders-fbs"
  slug_snake="${slug//-/_}"                 # e.g. "orders_fbs"
  slug_pascal="$(printf '%s' "${slug_snake}" | awk 'BEGIN{FS="_";OFS=""} {for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1')"
  echo "→ ${slug}"

  # -------- Python --------
  # Ask the generator to place output at `wb_api_client/<slug>` inside the
  # scratch dir by using a dotted packageName. Then move just that subtree
  # into the unified package; discard the manifest files the generator
  # scattered alongside it.
  py_tmp="${SCRATCH}/py-${slug_snake}"
  mv "${py_tmp}/wb_api_client/${slug_snake}" \
     "${CLIENTS_DIR}/python/wb_api_client/${slug_snake}"

  # -------- TypeScript --------
  # typescript-axios writes flat source files (no per-package folder), so we
  # generate to a scratch dir then copy just the .ts sources into src/<slug>.
  ts_tmp="${SCRATCH}/ts-${slug}"
  ts_dest="${CLIENTS_DIR}/typescript/src/${slug}"
  mkdir -p "${ts_dest}"
  # Keep only source. The generator's package.json/tsconfig.json would
  # collide with the top-level ones.
  find "${ts_tmp}" -maxdepth 1 -name "*.ts" -exec cp {} "${ts_dest}/" \;
  for sub in api models; do
    [[ -d "${ts_tmp}/${sub}" ]] && cp -R "${ts_tmp}/${sub}" "${ts_dest}/"
  done
  # typescript-axios `common.ts` fails TS strict declaration emission
  # because `axios.request<T, R>`'s inferred return type touches an
  # unnameable `unique symbol` in axios. Cast the return to Promise<R> so
  # tsc can name it in the emitted .d.ts.
  if [[ -f "${ts_dest}/common.ts" ]]; then
    sed -i.bak \
      "s|return axios.request<T, R>(axiosRequestArgs);|return axios.request<T, R>(axiosRequestArgs) as unknown as Promise<R>;|" \
      "${ts_dest}/common.ts"
    rm -f "${ts_dest}/common.ts.bak"
  fi

  # -------- Go --------
  # One Go module for the whole tree; each slug becomes a package. Delete
  # the per-slug go.mod/go.sum the generator emits — the top-level go.mod
  # (dropped in later from templates/) covers everything.
  go_tmp="${SCRATCH}/go-${slug_snake}"
  go_dest="${CLIENTS_DIR}/go/${slug_snake}"
  mkdir -p "${go_dest}"
  find "${go_tmp}" -maxdepth 1 -name "*.go" -exec cp {} "${go_dest}/" \;

  # -------- Java --------
  # Generate with the full per-slug package coordinates, then splice the
  # source subtree into the shared src/main/java tree.
  java_tmp="${SCRATCH}/java-${slug}"
  java_src="${java_tmp}/src/main/java/${JAVA_GROUP_PATH}/${slug_snake}"
  java_dest="${CLIENTS_DIR}/java/src/main/java/${JAVA_GROUP_PATH}/${slug_snake}"
  mv "${java_src}" "${java_dest}"

  # -------- PHP --------
  # Each slug becomes a PSR-4 namespace root
  # (ValeryVerkhoturov\WbApiClient\<Slug>). openapi-generator's PHP
  # template writes source to a flat `<scratch>/src/` (Api/, Model/,
  # Configuration.php, ApiException.php, …) with namespaces declared
  # inside each file. We move the whole `src/` contents into
  # clients/php/src/<Slug>/ — PSR-4 autoload then resolves
  # `\ValeryVerkhoturov\WbApiClient\<Slug>\Configuration` to
  # `src/<Slug>/Configuration.php`.
  php_tmp="${SCRATCH}/php-${slug_snake}"
  # The template override in templates/php adds the operation description
  # (`notes`) to method docblocks — the stock template's `{{#description}}`
  # placeholder binds to an empty field in this generator, so docblocks
  # would otherwise carry only the summary.
  php_dest="${CLIENTS_DIR}/php/src/${slug_pascal}"
  mkdir -p "${php_dest}"
  # Move Api/ Model/ dirs and top-level .php files into place.
  mv "${php_tmp}/src"/* "${php_dest}/"

  # -------- C# --------
  # Each slug becomes its own namespace root
  # (ValeryVerkhoturov.WbApiClient.<Slug>), which the generator already writes
  # into every file — so no post-processing is needed to keep categories apart.
  # It emits src/<packageName>/{Api,Client,Model} plus a per-spec .csproj, .sln,
  # docs and tests; only the source tree is kept. The unified project file comes
  # from templates/csharp/ and picks these up automatically, because SDK-style
  # projects include every .cs beneath them.
  cs_tmp="${SCRATCH}/cs-${slug_snake}"
  cs_ns="ValeryVerkhoturov.WbApiClient.${slug_pascal}"
  cs_dest="${CLIENTS_DIR}/csharp/src/${slug_pascal}"
  mkdir -p "${cs_dest}"
  for cs_sub in Api Client Model; do
    [[ -d "${cs_tmp}/src/${cs_ns}/${cs_sub}" ]] && \
      mv "${cs_tmp}/src/${cs_ns}/${cs_sub}" "${cs_dest}/"
  done

  # -------- OneScript --------
  # The plugin emits a standalone opm package per spec. We keep the API and
  # model classes and drop the per-spec packagedef/lib.config/README — the
  # unified package gets one of each after the loop.
  #
  # OneScript has no namespaces: every class name is global. Tag names are
  # unique across all 13 specs, so API classes keep their generated names;
  # model names are not (Response4XX alone appears in 12 specs), so each
  # category stamps its slug onto them via modelNamePrefix. Directories are
  # for humans — lib.config is what actually resolves a class.
  os_tmp="${SCRATCH}/os-${slug_snake}"

  os_api_dest="${CLIENTS_DIR}/onescript/src/Классы/${slug_pascal}"
  os_model_dest="${CLIENTS_DIR}/onescript/src/Модели/${slug_pascal}"
  mkdir -p "${os_api_dest}" "${os_model_dest}"

  # Everything in Классы/ except the shared runtime is an API class.
  for os_class in "${os_tmp}"/src/Классы/*.os; do
    [[ -e "${os_class}" ]] || continue
    os_name="$(basename "${os_class}" .os)"
    os_is_runtime=0
    for os_runtime in "${ONESCRIPT_RUNTIME[@]}"; do
      [[ "${os_name}" == "${os_runtime}" ]] && os_is_runtime=1 && break
    done
    [[ ${os_is_runtime} -eq 1 ]] || mv "${os_class}" "${os_api_dest}/"
  done

  if compgen -G "${os_tmp}/src/Модели/*.os" >/dev/null; then
    mv "${os_tmp}"/src/Модели/*.os "${os_model_dest}/"
  fi

  # Take the runtime from the first spec only; the copies are identical.
  if [[ ! -f "${CLIENTS_DIR}/onescript/src/Классы/Конфигурация.os" ]]; then
    for os_runtime in "${ONESCRIPT_RUNTIME[@]}"; do
      cp "${os_tmp}/src/Классы/${os_runtime}.os" \
         "${CLIENTS_DIR}/onescript/src/Классы/${os_runtime}.os"
    done
    # Конфигурация is the one runtime class whose text depends on the spec it
    # came from: it documents that spec's default host. Here 13 categories sit
    # on different hosts and every operation carries its own address, so the
    # line would be wrong at package level.
    sed -i.bak '/Адрес по умолчанию из спецификации/d' \
      "${CLIENTS_DIR}/onescript/src/Классы/Конфигурация.os"
    rm -f "${CLIENTS_DIR}/onescript/src/Классы/Конфигурация.os.bak"
  fi
done

# -------- Drop in top-level manifests, substituting __VERSION__ --------

# Python
sed "s/__VERSION__/${VERSION}/g" "${TEMPLATE_DIR}/python/pyproject.toml" \
    > "${CLIENTS_DIR}/python/pyproject.toml"
sed "s/__VERSION__/${VERSION}/g" "${TEMPLATE_DIR}/python/__init__.py" \
    > "${CLIENTS_DIR}/python/wb_api_client/__init__.py"

# TypeScript — build the exports map dynamically so a new spec surfaces
# without editing the template.
exports_json='{'
first=1
for slug in "${SLUGS[@]}"; do
  [[ $first -eq 0 ]] && exports_json+=','
  first=0
  exports_json+="\"./${slug}\": {\"types\": \"./dist/${slug}/index.d.ts\", \"default\": \"./dist/${slug}/index.js\"}"
done
exports_json+='}'
sed -e "s/__VERSION__/${VERSION}/g" -e "s|__EXPORTS__|${exports_json}|" \
    "${TEMPLATE_DIR}/typescript/package.json" \
    > "${CLIENTS_DIR}/typescript/package.json"
cp "${TEMPLATE_DIR}/typescript/tsconfig.json" "${CLIENTS_DIR}/typescript/tsconfig.json"
# One index.ts per slug that re-exports the generator's flat surface, so
# consumers can `import { ItemsApi } from ".../wb-api-client/items"`.
for slug in "${SLUGS[@]}"; do
  ts_dir="${CLIENTS_DIR}/typescript/src/${slug}"
  cat > "${ts_dir}/index.ts" <<'EOF'
export * from "./api";
export * from "./configuration";
export * from "./base";
export * from "./common";
EOF
done

# Consolidated secret-string injection: wraps the bearer JWT in a
# language-appropriate redacting type across all four clients so accidental
# logs don't leak the token. See scripts/inject-secret.py for per-language
# specifics. Must run AFTER language splicing (needs the generated
# Configuration/ApiClient files in place) and BEFORE `go mod tidy` (which
# reads the freshly-added github.com/negrel/secrecy import).
python3 "${REPO_ROOT}/scripts/inject-secret.py" "${CLIENTS_DIR}"

# Go — one module, one go.mod.
cp "${TEMPLATE_DIR}/go/go.mod" "${CLIENTS_DIR}/go/go.mod"

# Java — one pom.xml at repo root of the module.
sed "s/__VERSION__/${VERSION}/g" "${TEMPLATE_DIR}/java/pom.xml" \
    > "${CLIENTS_DIR}/java/pom.xml"

# PHP — one composer.json at the module root, PSR-4 autoload rooted at
# ValeryVerkhoturov\WbApiClient\ → src/.
sed "s/__VERSION__/${VERSION}/g" "${TEMPLATE_DIR}/php/composer.json" \
    > "${CLIENTS_DIR}/php/composer.json"

# C# — one .csproj at the package root covering every slug.
sed "s/__VERSION__/${VERSION}/g" "${TEMPLATE_DIR}/csharp/WbApiClient.csproj" \
    > "${CLIENTS_DIR}/csharp/WbApiClient.csproj"

# OneScript — one packagedef + lib.config covering all 13 categories. Both are
# a class-name registry, so they are built from the spliced tree rather than
# from a static template: a new spec surfaces without editing anything.
# OneScript resolves classes only through lib.config, so a class missing from
# it is unreachable no matter where its file sits.
if [[ -x "${REPO_ROOT}/.venv/bin/python" ]]; then
  "${REPO_ROOT}/.venv/bin/python" "${REPO_ROOT}/scripts/gen-onescript-manifests.py" "${REPO_ROOT}" "${VERSION}"
else
  python3 "${REPO_ROOT}/scripts/gen-onescript-manifests.py" "${REPO_ROOT}" "${VERSION}"
fi

# ── canonicalize per-language formatting ──────────────────────────────
# Each language uses its own community-standard formatter, pinned so
# local and CI produce byte-identical output. Independent trees are formatted
# concurrently, and every exit status is collected before README generation.
FORMAT_PIDS=()

# Go — gofmt follows secret injection because both the generator and injected
# fields arrive with misaligned struct tags and inconsistent spacing.
if command -v docker >/dev/null 2>&1; then
  # gofmt -w on the whole tree in a single pass consistently leaves 18
  # api_*.go files unformatted here — the doc-comment indentation
  # openapi-generator emits inside interface method blocks needs two
  # passes to converge. Do both in one container to keep the caching
  # benefit; the second pass is a fast no-op if the first covered everything.
  docker run --rm -u "$(id -u):$(id -g)" \
    -v "${REPO_ROOT}:/work" -w "/work/clients/go" \
    -e HOME=/tmp -e GOCACHE=/tmp/.cache/go-build -e GOPATH=/tmp/go \
    golang:1.22-alpine sh -c "go mod tidy && gofmt -w . && gofmt -w ." >/dev/null 2>&1 || \
    echo "  ! go mod tidy / gofmt failed — run manually in clients/go before publish"
fi &
FORMAT_PIDS+=("$!")

# Python — black (pinned in scripts/requirements.txt).
if [[ -x "${REPO_ROOT}/.venv/bin/black" ]]; then
  "${REPO_ROOT}/.venv/bin/black" --quiet "${CLIENTS_DIR}/python"
elif command -v black >/dev/null 2>&1; then
  black --quiet "${CLIENTS_DIR}/python"
elif python3 -c "import black" 2>/dev/null; then
  python3 -m black --quiet "${CLIENTS_DIR}/python"
else
  echo "  ! black not installed — skipping Python format (pip install -r scripts/requirements.txt)"
fi &
FORMAT_PIDS+=("$!")

# TypeScript — prettier via the same node image used for tsc. Pinned via
# devDependencies in templates/typescript/package.json.
if command -v docker >/dev/null 2>&1; then
  docker run --rm -u "$(id -u):$(id -g)" \
    -v "${REPO_ROOT}:/work" -w "/work/clients/typescript" \
    -e HOME=/tmp -e npm_config_cache=/tmp/.npm \
    node:20-alpine sh -c "npm install --silent --no-audit --no-fund && npx --no-install prettier --write --log-level=error 'src/**/*.ts'" \
    >/dev/null 2>&1 || \
    echo "  ! prettier failed — run manually in clients/typescript before publish"
fi &
FORMAT_PIDS+=("$!")

# Java — spotless (google-java-format). The plugin is declared in
# templates/java/pom.xml and pins both spotless and google-java-format
# versions. `spotless:apply` rewrites in place.
if command -v docker >/dev/null 2>&1; then
  docker run --rm -u "$(id -u):$(id -g)" \
    -v "${REPO_ROOT}:/work" -w "/work/clients/java" \
    -e HOME=/tmp maven:3.9-eclipse-temurin-17 \
    mvn -q -Duser.home=/tmp spotless:apply >/dev/null 2>&1 || \
    echo "  ! mvn spotless:apply failed — run manually in clients/java before publish"
fi &
FORMAT_PIDS+=("$!")

# PHP — PHP-CS-Fixer via the friendsofphp image. PSR-12 preset for the
# widely-accepted community layout. Config is passed inline via
# --rules=@PSR12 so we don't need a .php-cs-fixer.php file per client.
if command -v docker >/dev/null 2>&1; then
  docker run --rm -u "$(id -u):$(id -g)" \
    -v "${REPO_ROOT}:/work" -w "/work/clients/php" \
    -e HOME=/tmp -e PHP_CS_FIXER_IGNORE_ENV=1 \
    ghcr.io/php-cs-fixer/php-cs-fixer:3-php8.3 fix src --rules=@PSR12 --using-cache=no \
    >/dev/null 2>&1 || \
    echo "  ! php-cs-fixer failed — run manually in clients/php before publish"
fi &
FORMAT_PIDS+=("$!")

# C# — dotnet format. Whitespace only: the generated sources do not follow
# every analyzer convention, and a style/analyzer pass would rewrite code we
# don't control. CI uses its installed SDK for both formatting and verification;
# local generation keeps the Docker SDK used by `make dotnet-format`.
if [[ "${CI:-}" == "true" ]] && command -v dotnet >/dev/null 2>&1; then
  (cd "${CLIENTS_DIR}/csharp" && dotnet format whitespace -v q) >/dev/null 2>&1 || \
    echo "  ! dotnet format failed — run manually in clients/csharp before publish"
elif command -v docker >/dev/null 2>&1; then
  docker run --rm -u "$(id -u):$(id -g)" \
    -v "${REPO_ROOT}/clients/csharp:/app" -w /app \
    -e HOME=/tmp -e DOTNET_CLI_TELEMETRY_OPTOUT=1 -e DOTNET_NOLOGO=1 \
    -e NUGET_PACKAGES=/tmp/.nuget \
    mcr.microsoft.com/dotnet/sdk:8.0 \
    dotnet format whitespace -v q >/dev/null 2>&1 || \
    echo "  ! dotnet format failed — run manually in clients/csharp before publish"
fi &
FORMAT_PIDS+=("$!")

format_status=0
for pid in "${FORMAT_PIDS[@]}"; do
  wait "${pid}" || format_status=$?
done
(( format_status == 0 )) || exit "${format_status}"

# Per-language READMEs. Runs last so it can introspect the final,
# formatted trees (enumerating Api classes from *.py/*.ts/*.go/*.java).
if [[ -x "${REPO_ROOT}/.venv/bin/python" ]]; then
  "${REPO_ROOT}/.venv/bin/python" "${REPO_ROOT}/scripts/gen-readmes.py" "${REPO_ROOT}"
else
  python3 "${REPO_ROOT}/scripts/gen-readmes.py" "${REPO_ROOT}"
fi

rm -rf "${SCRATCH}"
echo "Generated 7 unified client libraries at version ${VERSION}"
