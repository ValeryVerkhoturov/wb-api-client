"""Resolve and cache the OneScript runtime and OpenAPI Generator plugin."""

import os
import platform
import shutil
import subprocess
import zipfile
from pathlib import Path

import requests

from ..core.paths import CACHE_DIR
from ..core.proc import run

ONESCRIPT_VERSION = os.environ.get("ONESCRIPT_VERSION", "2.2.0")
ONESCRIPT_CONNECTOR_VERSION = os.environ.get("ONESCRIPT_CONNECTOR_VERSION", "2.3.3")
ONESCRIPT_JASON_VERSION = os.environ.get("ONESCRIPT_JASON_VERSION", "0.6.0")
ONESCRIPT_CODEGEN_REPO = os.environ.get(
    "ONESCRIPT_CODEGEN_REPO",
    "https://github.com/ValeryVerkhoturov/onescript-openapi-generator.git",
)
ONESCRIPT_CODEGEN_REF = os.environ.get(
    "ONESCRIPT_CODEGEN_REF", "70fd9f920900dabd9f7c3293a21106ec98fceb65"
)


def onescript_platform() -> str:
    system = platform.system()
    if system == "Darwin":
        os_name = "osx"
    elif system == "Linux":
        os_name = "linux"
    else:
        raise SystemExit(f"unsupported OS: {system}")

    machine = platform.machine()
    if machine in ("arm64", "aarch64"):
        arch = "arm64"
    elif machine in ("x86_64", "amd64"):
        arch = "x64"
    else:
        raise SystemExit(f"unsupported architecture: {machine}")

    # Upstream has no linux-arm64 archive; x64 runs under emulation there.
    if os_name == "linux" and arch == "arm64":
        arch = "x64"
    return f"{os_name}-{arch}"


def ensure_onescript_package(name: str, version: str) -> None:
    home = Path(os.environ["ONESCRIPT_HOME"])
    if (home / "lib" / name).is_dir():
        return

    print(f"→ installing {name} {version}")
    run(
        [
            os.environ["ONESCRIPT_BIN"],
            home / "lib/opm/src/cmd/opm.os",
            "install",
            f"{name}@{version}",
        ],
        check=True,
        stdout=subprocess.DEVNULL,
    )


def ensure_onescript() -> tuple[Path, Path]:
    override = os.environ.get("OSCRIPT")
    if override and os.access(override, os.X_OK):
        home = (Path(override).parent / "..").resolve()
        os.environ["ONESCRIPT_BIN"] = override
        os.environ["ONESCRIPT_HOME"] = os.fspath(home)
        return Path(override), home

    platform_name = onescript_platform()
    home = CACHE_DIR / "onescript" / f"{ONESCRIPT_VERSION}-{platform_name}"
    binary = home / "bin/oscript"

    if not os.access(binary, os.X_OK):
        print(f"→ fetching OneScript {ONESCRIPT_VERSION} ({platform_name})")
        home.mkdir(parents=True, exist_ok=True)
        archive = CACHE_DIR / "onescript" / f"OneScript-{ONESCRIPT_VERSION}-{platform_name}.zip"
        archive_url = (
            f"https://github.com/EvilBeaver/OneScript/releases/download/v{ONESCRIPT_VERSION}/"
            f"OneScript-{ONESCRIPT_VERSION}-{platform_name}.zip"
        )
        with requests.get(archive_url, stream=True) as response:
            response.raise_for_status()
            with archive.open("wb") as output:
                shutil.copyfileobj(response.raw, output)

        # zipfile keeps the archive's UTF-8 Cyrillic entry names intact.
        with zipfile.ZipFile(archive) as distribution:
            distribution.extractall(home)
        archive.unlink()
        binary.chmod(binary.stat().st_mode | 0o111)

        if platform.system() == "Darwin":
            # Clear quarantine and ad-hoc sign so Gatekeeper does not kill the binary.
            for command in (["xattr", "-cr", home], ["codesign", "--force", "--sign", "-", binary]):
                try:
                    run(command, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                except OSError:
                    pass
            for dylib in (home / "bin").glob("*.dylib"):
                try:
                    run(
                        ["codesign", "--force", "--sign", "-", dylib],
                        stdout=subprocess.DEVNULL,
                        stderr=subprocess.DEVNULL,
                    )
                except OSError:
                    pass

    os.environ["ONESCRIPT_BIN"] = os.fspath(binary)
    os.environ["ONESCRIPT_HOME"] = os.fspath(home)
    ensure_onescript_package("1connector", ONESCRIPT_CONNECTOR_VERSION)
    ensure_onescript_package("jason", ONESCRIPT_JASON_VERSION)
    return binary, home


def ensure_onescript_plugin() -> Path:
    short = ONESCRIPT_CODEGEN_REF[:12]
    jar = CACHE_DIR / "onescript-codegen" / short / "onescript-openapi-generator.jar"

    if not jar.is_file():
        print(f"→ building onescript-openapi-generator @ {short}")
        src = CACHE_DIR / "onescript-codegen" / short / "src"
        shutil.rmtree(src, ignore_errors=True)
        src.mkdir(parents=True, exist_ok=True)
        run(
            [
                "git",
                "-c",
                "advice.detachedHead=false",
                "clone",
                "--quiet",
                ONESCRIPT_CODEGEN_REPO,
                src,
            ],
            check=True,
        )
        run(
            [
                "git",
                "-C",
                src,
                "-c",
                "advice.detachedHead=false",
                "checkout",
                "--quiet",
                ONESCRIPT_CODEGEN_REF,
            ],
            check=True,
        )

        maven_cache = CACHE_DIR / "onescript-codegen/m2"
        maven_cache.mkdir(parents=True, exist_ok=True)
        run(
            [
                "docker",
                "run",
                "--rm",
                "-u",
                f"{os.getuid()}:{os.getgid()}",
                "-v",
                f"{src}:/work",
                "-v",
                f"{maven_cache}:/m2",
                "-w",
                "/work",
                "-e",
                "HOME=/tmp",
                "maven:3.9-eclipse-temurin-17",
                "mvn",
                "-q",
                "-Dmaven.repo.local=/m2",
                "-DskipTests",
                "package",
            ],
            check=True,
        )

        jars = sorted(src.glob("target/onescript-openapi-generator-*.jar"))
        if not jars:
            raise RuntimeError("OneScript plugin build produced no jar")
        shutil.copy(jars[0], jar)
        shutil.rmtree(src)

    os.environ["ONESCRIPT_PLUGIN"] = os.fspath(jar)
    return jar
