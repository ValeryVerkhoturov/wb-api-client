import io

from ..specs.postprocess import add_docs_links
from . import naming
from .paths import REPO_ROOT, SWAGGER_DIR
from .proc import run
from .yamlio import round_trip_yaml, safe_yaml


def check_naming() -> None:
    assert naming.module_slug("01-general") == "general"
    assert naming.module_slug("06-in-store-pickup") == "in-store-pickup"
    assert naming.module_class_name("01-general") == "General"
    assert naming.module_class_name("06-in-store-pickup") == "InStorePickup"
    assert naming.snake_slug("orders-fbs") == "orders_fbs"
    assert naming.pascal_slug("in-store-pickup") == "InStorePickup"
    assert naming.pascal_from_snake("orders_fbs") == "OrdersFbs"
    assert naming.go_alias("orders-fbs") == "wbordersfbs"
    assert naming.snake_case("getApiV3Orders") == "get_api_v3_orders"
    assert naming.camel_case("GetApiV3Orders") == "getApiV3Orders"
    assert naming.pascal_case("getApiV3Orders") == "GetApiV3Orders"
    assert (
        naming.page_slug("PATCH", "/content/v2/tag/{id}") == "patch-content-v2-tag-id"
    )


def check_docs_link_contract() -> None:
    spec = {
        "paths": {
            "/content/v2/tag/{id}": {
                "patch": {"operationId": "updateTag", "description": "d1"},
            },
            "/content/v2/tag/id": {
                "patch": {"operationId": "updateTagById", "description": "d2"},
            },
        }
    }
    assert add_docs_links(spec, "items") == 2
    first = spec["paths"]["/content/v2/tag/{id}"]["patch"]["description"]
    second = spec["paths"]["/content/v2/tag/id"]["patch"]["description"]
    url1 = f"{naming.DOCS_SITE}/reference/api/items/patch-content-v2-tag-id"
    url2 = f"{url1}-update-tag-by-id"
    assert first == f"d1\n\n{naming.DOCS_LINK_LABEL}: {url1}"
    assert second == f"d2\n\n{naming.DOCS_LINK_LABEL}: {url2}"

    from ..docs.reference import strip_docs_link

    assert strip_docs_link(second) == "d2"


def check_yamlio() -> None:
    text = "a: 'quoted'\n# comment stays\nb: [1, 2]\n"
    yaml = round_trip_yaml()
    loaded = yaml.load(text)
    assert loaded["a"] == "quoted" and loaded["b"] == [1, 2]
    out = io.StringIO()
    yaml.dump(loaded, out)
    assert "'quoted'" in out.getvalue()
    assert safe_yaml().load(text)["a"] == "quoted"


def check_paths_and_proc() -> None:
    assert REPO_ROOT.is_dir() and SWAGGER_DIR.is_dir()
    result = run(["echo", "ok"], capture_output=True, text=True)
    assert result.stdout.strip() == "ok"


def main() -> None:
    check_naming()
    check_docs_link_contract()
    check_yamlio()
    check_paths_and_proc()
    print("pipeline core self-checks: OK")


if __name__ == "__main__":
    main()
