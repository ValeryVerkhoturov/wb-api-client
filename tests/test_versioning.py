from pipeline.release.versioning import bump, classify, latest_version, next_version


def test_latest_version_ignores_v1_and_picks_highest_v2():
    tags = ["v1.20261120.0", "v2.0.0", "v2.1.3", "v2.10.0", "not-a-tag", "v2.1.x"]
    assert latest_version(tags) == (2, 10, 0)


def test_latest_version_none_without_v2_tags():
    assert latest_version(["v1.20261120.0", "v1.20261120.1"]) is None


def test_bump_kinds():
    assert bump((2, 1, 3), "major") == (3, 0, 0)
    assert bump((2, 1, 3), "minor") == (2, 2, 0)
    assert bump((2, 1, 3), "patch") == (2, 1, 4)


def test_classify_empty_diff_is_patch():
    assert classify("   ") == "patch"


def test_classify_without_api_key_defaults_to_minor(monkeypatch):
    monkeypatch.delenv("DEEPSEEK_API_KEY", raising=False)
    assert classify("-old\n+new") == "minor"


def test_next_version_baseline_is_2_0_0():
    assert next_version(["v1.20261120.0"], "") == ("baseline", "2.0.0")
