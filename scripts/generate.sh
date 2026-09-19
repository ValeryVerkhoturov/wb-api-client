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
#
# Top-level manifests (pyproject.toml, package.json, go.mod, pom.xml) come
# from templates/ with __VERSION__ substituted in.
#
# Usage: generate.sh <version>

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <version>" >&2
  exit 2
fi

VERSION="$1"
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SPEC_DIR="${REPO_ROOT}/swaggers/processed"
CLIENTS_DIR="${REPO_ROOT}/clients"
CONFIG_DIR="${REPO_ROOT}/generator-configs"
TEMPLATE_DIR="${REPO_ROOT}/templates"

if [[ ! -d "${SPEC_DIR}" ]] || ! compgen -G "${SPEC_DIR}/*.yaml" >/dev/null; then
  echo "no processed specs at ${SPEC_DIR} — run post-process.py first" >&2
  exit 1
fi

# openapi-generator runs in the official Docker image so contributors don't
# need Node/JDK installed. Repo is mounted at /work; every path passed to
# the generator must be repo-relative so it resolves inside the container.
OPENAPI_GENERATOR_VERSION="${OPENAPI_GENERATOR_VERSION:-v7.10.0}"
GEN="docker run --rm -u $(id -u):$(id -g) -v ${REPO_ROOT}:/work -w /work openapitools/openapi-generator-cli:${OPENAPI_GENERATOR_VERSION}"
in_container() { echo "${1#${REPO_ROOT}/}"; }

JAVA_GROUP_PATH="io/github/valeryverkhoturov/wbapi"

# category slug from spec filename: "02-items.yaml" → "items"
slug_from_spec() {
  local base
  base="$(basename "$1" .yaml)"
  echo "${base#*-}"
}

# openapi-generator run: writes to a scratch dir under clients/.tmp/.
gen() {
  local lang="$1" spec="$2" scratch="$3" config="$4" extra="$5"
  # shellcheck disable=SC2086
  ${GEN} generate \
    --input-spec "$(in_container "${spec}")" \
    --generator-name "${lang}" \
    --output "$(in_container "${scratch}")" \
    --config "$(in_container "${config}")" \
    --additional-properties="packageVersion=${VERSION},artifactVersion=${VERSION},npmVersion=${VERSION},${extra}" \
    --global-property=skipFormModel=false \
    --skip-validate-spec \
    >/dev/null
}

rm -rf "${CLIENTS_DIR}"
mkdir -p "${CLIENTS_DIR}"/{python/wb_api_client,typescript/src,go,java/src/main/java/${JAVA_GROUP_PATH}}
SCRATCH="${CLIENTS_DIR}/.tmp"
mkdir -p "${SCRATCH}"

# Collect slugs so template-driven manifests (exports map) can iterate them.
SLUGS=()
for spec in "${SPEC_DIR}"/*.yaml; do
  SLUGS+=("$(slug_from_spec "${spec}")")
done

for spec in "${SPEC_DIR}"/*.yaml; do
  slug="$(slug_from_spec "${spec}")"        # e.g. "orders-fbs"
  slug_snake="${slug//-/_}"                 # e.g. "orders_fbs"
  echo "→ ${slug}"

  # -------- Python --------
  # Ask the generator to place output at `wb_api_client/<slug>` inside the
  # scratch dir by using a dotted packageName. Then move just that subtree
  # into the unified package; discard the manifest files the generator
  # scattered alongside it.
  py_tmp="${SCRATCH}/py-${slug_snake}"
  gen python "${spec}" "${py_tmp}" "${CONFIG_DIR}/python.yaml" \
    "packageName=wb_api_client.${slug_snake},projectName=wb_api_client_${slug_snake}"
  mv "${py_tmp}/wb_api_client/${slug_snake}" \
     "${CLIENTS_DIR}/python/wb_api_client/${slug_snake}"

  # -------- TypeScript --------
  # typescript-axios writes flat source files (no per-package folder), so we
  # generate to a scratch dir then copy just the .ts sources into src/<slug>.
  ts_tmp="${SCRATCH}/ts-${slug}"
  gen typescript-axios "${spec}" "${ts_tmp}" "${CONFIG_DIR}/typescript.yaml" \
    "npmName=@valeryverkhoturov/wb-api-client-${slug}"
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
  gen go "${spec}" "${go_tmp}" "${CONFIG_DIR}/go.yaml" \
    "packageName=${slug_snake}"
  go_dest="${CLIENTS_DIR}/go/${slug_snake}"
  mkdir -p "${go_dest}"
  find "${go_tmp}" -maxdepth 1 -name "*.go" -exec cp {} "${go_dest}/" \;

  # -------- Java --------
  # Generate with the full per-slug package coordinates, then splice the
  # source subtree into the shared src/main/java tree.
  java_tmp="${SCRATCH}/java-${slug}"
  java_pkg="io.github.valeryverkhoturov.wbapi.${slug_snake}"
  gen java "${spec}" "${java_tmp}" "${CONFIG_DIR}/java.yaml" \
    "artifactId=wb-api-client-${slug},invokerPackage=${java_pkg},apiPackage=${java_pkg}.api,modelPackage=${java_pkg}.model"
  java_src="${java_tmp}/src/main/java/${JAVA_GROUP_PATH}/${slug_snake}"
  java_dest="${CLIENTS_DIR}/java/src/main/java/${JAVA_GROUP_PATH}/${slug_snake}"
  mv "${java_src}" "${java_dest}"
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

# Go — one module, one go.mod. Run `go mod tidy` (via the same golang
# image already used elsewhere) so generated-code imports (e.g.
# gopkg.in/validator.v2, used by hoisted response models) are captured
# in go.mod/go.sum before commit.
cp "${TEMPLATE_DIR}/go/go.mod" "${CLIENTS_DIR}/go/go.mod"
if command -v docker >/dev/null 2>&1; then
  docker run --rm -u "$(id -u):$(id -g)" \
    -v "${REPO_ROOT}:/work" -w "/work/clients/go" \
    -e HOME=/tmp -e GOCACHE=/tmp/.cache/go-build -e GOPATH=/tmp/go \
    golang:1.22-alpine go mod tidy >/dev/null 2>&1 || \
    echo "  ! go mod tidy failed — run it manually in clients/go before publish"
fi

# Java — one pom.xml at repo root of the module.
sed "s/__VERSION__/${VERSION}/g" "${TEMPLATE_DIR}/java/pom.xml" \
    > "${CLIENTS_DIR}/java/pom.xml"

rm -rf "${SCRATCH}"
echo "Generated 4 unified client libraries at version ${VERSION}"
