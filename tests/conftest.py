import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(REPO_ROOT / "scripts"))

from pipeline.core.yamlio import safe_yaml

FIXTURES = Path(__file__).resolve().parent / "fixtures"


def load_cases(fixture_name: str) -> list[dict]:
    path = FIXTURES / fixture_name
    return safe_yaml().load(path.read_text(encoding="utf-8"))["cases"]


def case_ids(cases: list[dict]) -> list[str]:
    return [c["name"] for c in cases]
