import os
import subprocess
from pathlib import Path

from .paths import REPO_ROOT


def run(args: list[object], **kwargs: object) -> subprocess.CompletedProcess:
    return subprocess.run([os.fspath(arg) for arg in args], **kwargs)


def in_container(path: Path) -> str:
    return path.relative_to(REPO_ROOT).as_posix()
