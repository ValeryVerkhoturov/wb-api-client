import pytest

from conftest import case_ids, load_cases
from pipeline.docs import readmes

CASES = load_cases("readmes.yaml")


@pytest.mark.parametrize("case", CASES, ids=case_ids(CASES))
def test_readmes(case):
    func = getattr(readmes, case["function"])
    assert func(*case["args"]) == case["expected"]
