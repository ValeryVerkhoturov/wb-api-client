#!/usr/bin/env bash
set -euo pipefail

# Verifies the generated OneScript client two ways:
#
#   1. `oscript -check` compiles every module without running it. That is the
#      only compile gate OneScript offers, and it is per-file, so the files are
#      checked in parallel — serially this takes minutes.
#   2. Loading the package through `#Использовать` proves lib.config actually
#      resolves: a class missing from it is unreachable however valid its file.
#
# Usage: scripts/verify-onescript.sh [package-dir]
#   OSCRIPT=/path/to/oscript  use an existing install instead of the cached one

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE="${1:-${REPO_ROOT}/clients/onescript}"

# shellcheck source=scripts/onescript-toolchain.sh
source "${REPO_ROOT}/scripts/onescript-toolchain.sh"
ensure_onescript

if [[ ! -d "${PACKAGE}/src" ]]; then
  echo "no OneScript client at ${PACKAGE} — run ./scripts/generate.sh first" >&2
  exit 1
fi

# #Использовать resolves a relative path against the script being run, and the
# loader below is written to a temp dir.
PACKAGE="$(cd -- "${PACKAGE}" && pwd)"

jobs="$( (command -v nproc >/dev/null && nproc) || sysctl -n hw.ncpu 2>/dev/null || echo 4)"
report="$(mktemp)"
trap 'rm -f "${report}"' EXIT

# `oscript -check` prints "No errors." and exits 0 on success. Run it under
# xargs so a non-zero exit from any file propagates, and keep only the noise
# that matters.
find "${PACKAGE}/src" -name '*.os' -type f -print0 \
  | xargs -0 -P "${jobs}" -n 1 "${ONESCRIPT_BIN}" -check \
  > "${report}" 2>&1 || true

total="$(find "${PACKAGE}/src" -name '*.os' -type f | wc -l | tr -d ' ')"
failures="$(grep -c 'Ошибка' "${report}" || true)"

if [[ "${failures}" -ne 0 ]]; then
  echo "  ✗ ${failures} file(s) failed to compile:"
  grep 'Ошибка' "${report}" | head -20
  exit 1
fi

echo "  ✓ oscript -check passes on all ${total} files"

# Loading the library registers every class in lib.config; a bad path or a
# name collision surfaces here rather than at the consumer's first Новый.
loader="$(mktemp -t onescript-load-XXXXXX).os"
trap 'rm -f "${report}" "${loader}"' EXIT
cat > "${loader}" <<LOADER
#Использовать "${PACKAGE}"
Сообщить("  ✓ пакет загружается, Конфигурация доступна: " + Строка(ТипЗнч(Новый Конфигурация())));
LOADER

"${ONESCRIPT_BIN}" "${loader}"
