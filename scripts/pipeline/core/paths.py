from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]
SPEC_DIR = REPO_ROOT / "specs"
UNPROCESSED_DIR = SPEC_DIR / "unprocessed"
PROCESSED_DIR = SPEC_DIR / "processed"
CLIENTS_DIR = REPO_ROOT / "clients"
CONFIG_DIR = REPO_ROOT / "generator-configs"
TEMPLATE_DIR = REPO_ROOT / "templates"
CACHE_DIR = REPO_ROOT / ".cache"
SCRATCH_DIR = CLIENTS_DIR / ".tmp"


def go_module_path(go_mod: Path | None = None) -> str:
    path = go_mod or CLIENTS_DIR / "go" / "go.mod"
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.startswith("module "):
            return line.split()[1]
    raise RuntimeError(f"no module line in {path}")
