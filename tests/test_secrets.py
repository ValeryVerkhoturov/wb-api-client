import pytest

from conftest import case_ids, load_cases
from pipeline.generation import secrets

FIXTURES = [
    "secrets_python.yaml",
    "secrets_typescript.yaml",
    "secrets_go.yaml",
    "secrets_java.yaml",
    "secrets_php.yaml",
    "secrets_csharp.yaml",
    "secrets_rust.yaml",
]

CASES = [(name, case) for name in FIXTURES for case in load_cases(name)]


@pytest.mark.parametrize(
    "fixture,case", CASES, ids=[f"{f}:{c['name']}" for f, c in CASES]
)
def test_secrets(fixture, case):
    func = getattr(secrets, case["function"])
    assert func(case["input"]) == case["expected"]
