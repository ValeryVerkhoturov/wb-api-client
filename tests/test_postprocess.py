import copy

import pytest

from conftest import case_ids, load_cases
from pipeline.specs import postprocess

CASES = load_cases("postprocess.yaml")


@pytest.mark.parametrize("case", CASES, ids=case_ids(CASES))
def test_postprocess(case):
    func = getattr(postprocess, case["function"])
    spec = copy.deepcopy(case["input"])
    result = func(spec, *case.get("args", []))
    if "returns" in case:
        assert result == case["returns"]
    assert spec == case["expected"]
