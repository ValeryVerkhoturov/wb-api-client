#!/usr/bin/env bash
set -euo pipefail

# Download the Wildberries OpenAPI (Swagger) specifications used by this
# repository. Files are placed in ./swaggers/ next to a checksums file that
# is later used by the daily GitHub Action to detect upstream changes.

BASE_URL="https://dev.wildberries.ru/api/swagger/yaml/ru"

# Wildberries fronts dev.wildberries.ru with WBAAS, which serves a JS
# antibot challenge to non-browser clients (HTTP 498). Passing a valid
# `x_wbaas_token` cookie skips the challenge. The default value below was
# harvested from a real browser session; override by exporting
# WBAAS_TOKEN in the environment before running.
DEFAULT_WBAAS_TOKEN="1.1000.554dbe25718742978c94425d47c5bc47.MTV8MzEuNTYuMTg0LjEwMnxNb3ppbGxhLzUuMCAoTWFjaW50b3NoOyBJbnRlbCBNYWMgT1MgWCAxMF8xNV83KSBBcHBsZVdlYktpdC81MzcuMzYgKEtIVE1MLCBsaWtlIEdlY2tvKSBDaHJvbWUvMTUzLjAuMC4wIFNhZmFyaS81MzcuMzZ8MTc5MDA4Nzc2M3xyZXVzYWJsZXwyfGV5Sm9ZWE5vSWpvaUluMD18MHw0MDk2MjE3fDE3ODk5NTgxNjN8MXwrd289.MEUCIQCqW61jH2AUVu8jELK1QaUIBS453pMn8acR5DOBJAi7qwIgaMtQUjKsleqJHqPOw4D1cRAJ4gYXNMbjwHhWXIPYFbw="
WBAAS_TOKEN="${WBAAS_TOKEN:-${DEFAULT_WBAAS_TOKEN}}"

# The token was issued for this UA + IP fingerprint, so send both.
USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36"

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
       --user-agent "${USER_AGENT}" \
       --cookie "x_wbaas_token=${WBAAS_TOKEN}" \
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
