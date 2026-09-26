#!/usr/bin/env bash
# Resolves the two tools the OneScript client needs, caching both under .cache/.
#
# Sourced by generate.sh and by the Makefile's verify/publish targets. Exports:
#
#   ONESCRIPT_BIN     path to `oscript`
#   ONESCRIPT_HOME    root of the OneScript distribution (has bin/ and lib/)
#   ONESCRIPT_PLUGIN  path to the openapi-generator plugin jar
#
# Why a download instead of a container: OneScript publishes no linux-arm64
# build, so a Docker-based toolchain would run under emulation on Apple
# Silicon — slow, since compile-checking spawns one process per file. The
# release archives are self-contained (they bundle the .NET runtime), so
# unpacking the one matching the host is both faster and simpler.

set -euo pipefail

ONESCRIPT_VERSION="${ONESCRIPT_VERSION:-2.2.0}"

# Pinned so regeneration is reproducible: the plugin decides every generated
# name and file, exactly like the openapi-generator image tag does for the
# other five languages.
ONESCRIPT_CODEGEN_REPO="${ONESCRIPT_CODEGEN_REPO:-https://github.com/ValeryVerkhoturov/onescript-openapi-generator.git}"
ONESCRIPT_CODEGEN_REF="${ONESCRIPT_CODEGEN_REF:-6bbe860bd0fe5309357c49a05fbc31d71223121d}"

TOOLCHAIN_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CACHE_DIR="${TOOLCHAIN_ROOT}/.cache"

onescript_platform() {
  local os arch
  case "$(uname -s)" in
    Darwin) os="osx" ;;
    Linux)  os="linux" ;;
    *) echo "unsupported OS: $(uname -s)" >&2; return 1 ;;
  esac
  case "$(uname -m)" in
    arm64|aarch64) arch="arm64" ;;
    x86_64|amd64)  arch="x64" ;;
    *) echo "unsupported architecture: $(uname -m)" >&2; return 1 ;;
  esac
  # Upstream ships no linux-arm64 archive; x64 runs fine under emulation on
  # the rare arm64 Linux host, and that is better than failing outright.
  if [[ "${os}" == "linux" && "${arch}" == "arm64" ]]; then
    arch="x64"
  fi
  echo "${os}-${arch}"
}

ensure_onescript() {
  if [[ -n "${OSCRIPT:-}" && -x "${OSCRIPT}" ]]; then
    ONESCRIPT_BIN="${OSCRIPT}"
    ONESCRIPT_HOME="$(cd -- "$(dirname -- "${OSCRIPT}")/.." && pwd)"
    export ONESCRIPT_BIN ONESCRIPT_HOME
    return 0
  fi

  local platform home archive
  platform="$(onescript_platform)"
  home="${CACHE_DIR}/onescript/${ONESCRIPT_VERSION}-${platform}"

  if [[ ! -x "${home}/bin/oscript" ]]; then
    echo "→ fetching OneScript ${ONESCRIPT_VERSION} (${platform})"
    mkdir -p "${home}"
    archive="${CACHE_DIR}/onescript/OneScript-${ONESCRIPT_VERSION}-${platform}.zip"
    curl -fsSL -o "${archive}" \
      "https://github.com/EvilBeaver/OneScript/releases/download/v${ONESCRIPT_VERSION}/OneScript-${ONESCRIPT_VERSION}-${platform}.zip"

    # Deliberately not `unzip`: the archive stores its (Cyrillic) entry names
    # in UTF-8, and Info-ZIP rewrites them — as #Uxxxx escapes on Linux, as
    # decomposed NFD on some macOS tools. Either way every path recorded in
    # lib.config is then dangling, and OneScript's own bundled libraries
    # (asserts → cli, logos, opm) fail to load. Python's zipfile reads the
    # names as stored.
    python3 -m zipfile -e "${archive}" "${home}"
    rm -f "${archive}"
    chmod +x "${home}/bin/oscript"

    # Gatekeeper SIGKILLs the unsigned arm64 binary with no diagnostic of its
    # own. Clearing the quarantine flag and ad-hoc signing makes it runnable.
    if [[ "$(uname -s)" == "Darwin" ]]; then
      xattr -cr "${home}" 2>/dev/null || true
      codesign --force --sign - "${home}/bin/oscript" >/dev/null 2>&1 || true
      for dylib in "${home}"/bin/*.dylib; do
        [[ -e "${dylib}" ]] && codesign --force --sign - "${dylib}" >/dev/null 2>&1 || true
      done
    fi
  fi

  ONESCRIPT_BIN="${home}/bin/oscript"
  ONESCRIPT_HOME="${home}"
  export ONESCRIPT_BIN ONESCRIPT_HOME
}

ensure_onescript_plugin() {
  local short jar src
  short="${ONESCRIPT_CODEGEN_REF:0:12}"
  jar="${CACHE_DIR}/onescript-codegen/${short}/onescript-openapi-generator.jar"

  if [[ ! -f "${jar}" ]]; then
    echo "→ building onescript-openapi-generator @ ${short}"
    src="${CACHE_DIR}/onescript-codegen/${short}/src"
    rm -rf "${src}"
    mkdir -p "${src}"
    git -c advice.detachedHead=false clone --quiet "${ONESCRIPT_CODEGEN_REPO}" "${src}"
    git -C "${src}" -c advice.detachedHead=false checkout --quiet "${ONESCRIPT_CODEGEN_REF}"

    mkdir -p "${CACHE_DIR}/onescript-codegen/m2"
    docker run --rm -u "$(id -u):$(id -g)" \
      -v "${src}:/work" \
      -v "${CACHE_DIR}/onescript-codegen/m2:/m2" \
      -w /work -e HOME=/tmp \
      maven:3.9-eclipse-temurin-17 \
      mvn -q -Dmaven.repo.local=/m2 -DskipTests package

    cp "$(ls "${src}"/target/onescript-openapi-generator-*.jar | head -1)" "${jar}"
    rm -rf "${src}"
  fi

  ONESCRIPT_PLUGIN="${jar}"
  export ONESCRIPT_PLUGIN
}
