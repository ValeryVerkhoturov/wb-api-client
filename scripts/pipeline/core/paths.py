from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]
SWAGGER_DIR = REPO_ROOT / "swaggers"
PROCESSED_DIR = SWAGGER_DIR / "processed"
CLIENTS_DIR = REPO_ROOT / "clients"
CONFIG_DIR = REPO_ROOT / "generator-configs"
TEMPLATE_DIR = REPO_ROOT / "templates"
CACHE_DIR = REPO_ROOT / ".cache"
SCRATCH_DIR = CLIENTS_DIR / ".tmp"
