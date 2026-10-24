import re

JAVA_ROOT_PKG = "io.github.valeryverkhoturov.wbapi"
JAVA_ROOT_PATH = "io/github/valeryverkhoturov/wbapi"

DOCS_SITE = "https://valeryverkhoturov.github.io/wb-api-client-docs"
DOCS_LINK_LABEL = "Library doc"


def module_slug(stem: str) -> str:
    return stem.split("-", 1)[1]


def module_class_name(stem: str) -> str:
    return pascal_slug(module_slug(stem))


def snake_slug(slug: str) -> str:
    return slug.replace("-", "_")


def pascal_slug(slug: str) -> str:
    return "".join(part.capitalize() for part in slug.split("-"))


def pascal_from_snake(snake: str) -> str:
    return "".join(part[:1].upper() + part[1:] for part in snake.split("_"))


def go_alias(slug: str) -> str:
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
    cleaned = re.sub(r"[{}]", "", path)
    parts = [p for p in re.split(r"[^A-Za-z0-9]+", cleaned) if p]
    return "-".join([method.lower(), *parts]).lower()
