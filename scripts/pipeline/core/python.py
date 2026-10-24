import os
import shutil
import sys
from pathlib import Path

from .paths import REPO_ROOT
from .proc import run

VENV_PYTHON = REPO_ROOT / ".venv/bin/python"
PYTHON = (
    VENV_PYTHON
    if os.access(VENV_PYTHON, os.X_OK)
    else Path(shutil.which("python3") or sys.executable)
)
SYSTEM_PYTHON = Path(shutil.which("python3") or sys.executable)


def run_script(interpreter, script, *args, **kwargs):
    return run([interpreter, script, *args], **kwargs)
