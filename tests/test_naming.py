import pytest

from conftest import case_ids, load_cases
from pipeline.core import naming

CASES = load_cases("naming.yaml")


@pytest.mark.parametrize("case", CASES, ids=case_ids(CASES))
def test_naming(case):
    func = getattr(naming, case["function"])
    assert func(*case["args"]) == case["expected"]
