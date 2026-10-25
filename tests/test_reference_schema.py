import pytest

from conftest import case_ids, load_cases
from pipeline.docs.reference import STRINGS, schema_root_type, schema_tree_lines

CASES = load_cases("reference_schema.yaml")


@pytest.mark.parametrize("case", CASES, ids=case_ids(CASES))
def test_schema_tree(case):
    lines = schema_tree_lines(case["schema"], case["components"], STRINGS["ru"])
    assert "\n".join(lines) == case["expected"]
    if "root" in case:
        assert schema_root_type(case["schema"], case["components"]) == case["root"]
