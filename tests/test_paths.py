import pytest

from pipeline.core.paths import go_module_path


def test_go_module_path_reads_module_line(tmp_path):
    go_mod = tmp_path / "go.mod"
    go_mod.write_text(
        "module github.com/ValeryVerkhoturov/wb-api-client-go/v3\n\ngo 1.21\n"
    )
    assert go_module_path(go_mod) == "github.com/ValeryVerkhoturov/wb-api-client-go/v3"


def test_go_module_path_without_module_line_raises(tmp_path):
    go_mod = tmp_path / "go.mod"
    go_mod.write_text("go 1.21\n")
    with pytest.raises(RuntimeError):
        go_module_path(go_mod)
