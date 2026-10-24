"""Identity of specs, modules, languages and docs pages.

These functions decide generated package names, class names and docs URLs,
so every context derives them from here — a drift between two copies used to
break the docs-link contract silently (see `page_slug`).
"""

import re

# Java package identity, shared by generation, secrets and docs contexts.
JAVA_ROOT_PKG = "io.github.valeryverkhoturov.wbapi"
JAVA_ROOT_PATH = "io/github/valeryverkhoturov/wbapi"

# Docs-link contract: specs.postprocess.add_docs_links appends the marker
# line, docs.reference.strip_docs_link removes exactly it again.
DOCS_SITE = "https://valeryverkhoturov.github.io/wb-api-client-docs"
DOCS_LINK_LABEL = "Library doc"


def module_slug(stem: str) -> str:
    """`01-general` → `general`, `06-in-store-pickup` → `in-store-pickup`."""
    return stem.split("-", 1)[1]


def module_class_name(stem: str) -> str:
    """`01-general` → `General`, `06-in-store-pickup` → `InStorePickup`."""
    return pascal_slug(module_slug(stem))


def snake_slug(slug: str) -> str:
    """`orders-fbs` → `orders_fbs` (Python package, Go package, Java package)."""
    return slug.replace("-", "_")


def pascal_slug(slug: str) -> str:
    """`orders-fbs` → `OrdersFbs` (PHP, C#, OneScript directory)."""
    return "".join(part.capitalize() for part in slug.split("-"))


def pascal_from_snake(snake: str) -> str:
    """`orders_fbs` → `OrdersFbs` (keeps inner case, unlike str.capitalize)."""
    return "".join(part[:1].upper() + part[1:] for part in snake.split("_"))


def go_alias(slug: str) -> str:
    """`orders-fbs` → `wbordersfbs`, the import alias used across the docs."""
    return "wb" + slug.replace("-", "")


def snake_case(op_id: str) -> str:
    s = re.sub(r"(.)([A-Z][a-z]+)", r"\1_\2", op_id)
    s = re.sub(r"([a-z0-9])([A-Z])", r"\1_\2", s)
    return s.lower()


def camel_case(op_id: str) -> str:
    return op_id[0].lower() + op_id[1:]


def pascal_case(op_id: str) -> str:
    return op_id[0].upper() + op_id[1:]


def page_slug(method: str, path: str) -> str:
    """`PATCH /content/v2/tag/{id}` → `patch-content-v2-tag-id`.

    Path templating braces are dropped rather than encoded — `{id}` and a
    literal `id` segment never collide in these specs, and the result stays
    readable in the URL bar and the sidebar. specs.postprocess relies on the
    same slug when appending docs links, so the URL matches the page.
    """
    cleaned = re.sub(r"[{}]", "", path)
    parts = [p for p in re.split(r"[^A-Za-z0-9]+", cleaned) if p]
    return "-".join([method.lower(), *parts]).lower()
