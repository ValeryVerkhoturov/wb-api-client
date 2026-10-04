#!/usr/bin/env bash
set -euo pipefail

# Download the Wildberries OpenAPI (Swagger) specifications used by this
# repository. Files are placed in ./swaggers/ next to a checksums file that
# is later used by the daily GitHub Action to detect upstream changes.
#
# Specs come from github.com/ValeryVerkhoturov/wb-api-client-specs, a mirror
# of dev.wildberries.ru refreshed hourly. Pulling from raw GitHub avoids the
# WBAAS antibot challenge (HTTP 498) the live portal serves to non-browser
# clients.

BASE_URL="https://raw.githubusercontent.com/ValeryVerkhoturov/wb-api-client-specs/main/specs/ru"

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${REPO_ROOT}/swaggers"
mkdir -p "${OUT_DIR}"

SPECS=(
  "01-general.yaml"
  "02-items.yaml"
  "03-orders-fbs.yaml"
  "04-orders-dbw.yaml"
  "05-dbs.yaml"
  "06-in-store-pickup.yaml"
  "07-orders-fbw.yaml"
  "08-promotion.yaml"
  "09-communications.yaml"
  "10-rates.yaml"
  "11-analytics.yaml"
  "12-reports.yaml"
  "13-finances.yaml"
)

echo "Downloading ${#SPECS[@]} specs from ${BASE_URL}"
for spec in "${SPECS[@]}"; do
  url="${BASE_URL}/${spec}"
  dest="${OUT_DIR}/${spec}"
  echo "  → ${spec}"
  curl --fail --silent --show-error --location \
       --retry 3 --retry-delay 2 \
       --output "${dest}" \
       "${url}"
done

# Emit a stable, sorted SHA-256 manifest so the daily-check workflow can
# compare a fresh download against the previous one to decide whether to
# regenerate and publish new client releases.
(
  cd "${OUT_DIR}"
  shasum -a 256 -- *.yaml | sort -k2 > checksums.txt
)

echo "Done. Manifest: ${OUT_DIR}/checksums.txt"
