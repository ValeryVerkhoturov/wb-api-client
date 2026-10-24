#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path
from typing import Any

from ..core.naming import (
    DOCS_LINK_LABEL,
    DOCS_SITE,
    module_class_name,
    module_slug,
    page_slug,
    snake_case,
)
from ..core.paths import PROCESSED_DIR, SWAGGER_DIR
from ..core.yamlio import round_trip_yaml

try:
    from markdownify import markdownify as _html_to_markdown
except ImportError:
    sys.stderr.write(
        "markdownify is required. Install with `pip install markdownify`.\n"
    )
    raise

SECURITY_SCHEME_NAME = "BearerAuth"

yaml = round_trip_yaml()


def inject_bearer_auth(spec: dict) -> None:
    components = spec.setdefault("components", {})
    schemes = components.setdefault("securitySchemes", {})
    existing = [name for name in schemes.keys() if name != SECURITY_SCHEME_NAME]

    schemes[SECURITY_SCHEME_NAME] = {
        "type": "http",
        "scheme": "bearer",
        "bearerFormat": "JWT",
        "description": (
            "Wildberries API token (JWT). Create in the seller portal → "
            "Настройки → Доступ к API. Sent as `Authorization: Bearer <token>`."
        ),
    }
    for name in existing:
        del schemes[name]

    spec["security"] = [{SECURITY_SCHEME_NAME: []}]

    for path_item in (spec.get("paths") or {}).values():
        if not isinstance(path_item, dict):
            continue
        for method, op in path_item.items():
            if method not in {
                "get",
                "post",
                "put",
                "patch",
                "delete",
                "head",
                "options",
            }:
                continue
            if isinstance(op, dict) and "security" in op:
                op["security"] = [{SECURITY_SCHEME_NAME: []}]


def fix_untyped_arrays(node: Any) -> int:
    fixed = 0
    if isinstance(node, dict):
        if node.get("type") == "array" and not node.get("items"):
            node["items"] = {"type": "string"}
            fixed += 1
        for v in node.values():
            fixed += fix_untyped_arrays(v)
    elif isinstance(node, list):
        for v in node:
            fixed += fix_untyped_arrays(v)
    return fixed


def widen_integer_formats(node: Any) -> int:
    fixed = 0
    if isinstance(node, dict):
        fmt = node.get("format")
        if node.get("type") == "integer" and (
            fmt is None
            or fmt in {"uint32", "uint64"}
            or (isinstance(fmt, str) and fmt.lower().startswith("unix"))
        ):
            node["format"] = "int64"
            fixed += 1
        for v in node.values():
            fixed += widen_integer_formats(v)
    elif isinstance(node, list):
        for v in node:
            fixed += widen_integer_formats(v)
    return fixed


def _walk_refs(node: Any, visitor):
    if isinstance(node, dict):
        for k in list(node.keys()):
            _walk_refs(node[k], visitor)
            visitor(node, k, node[k])
    elif isinstance(node, list):
        for i in range(len(node)):
            _walk_refs(node[i], visitor)
            visitor(node, i, node[i])


def inline_top_level_arrays(spec: dict) -> int:
    schemas = spec.get("components", {}).get("schemas", {}) or {}
    array_schemas = {
        name: sch
        for name, sch in schemas.items()
        if isinstance(sch, dict) and sch.get("type") == "array"
    }
    if not array_schemas:
        return 0

    ref_prefix = "#/components/schemas/"
    target_refs = {ref_prefix + name for name in array_schemas}
    replaced_count = [0]

    def visit_inline(parent, key, node):
        if not isinstance(node, dict):
            return
        ref = node.get("$ref")
        if isinstance(ref, str) and ref in target_refs:
            name = ref[len(ref_prefix) :]
            parent[key] = _deep_copy_yaml(array_schemas[name])
            replaced_count[0] += 1

    while True:
        before = replaced_count[0]
        _walk_refs(spec, visit_inline)
        if replaced_count[0] == before:
            break

    for name in array_schemas:
        del schemas[name]

    _collapse_array_alloofs(spec)
    return len(array_schemas)


_METADATA_ONLY_KEYS = {
    "description",
    "title",
    "example",
    "examples",
    "readOnly",
    "writeOnly",
    "deprecated",
    "nullable",
    "default",
}


def _collapse_array_alloofs(root: Any) -> None:
    def visit(parent, key, node):
        if not isinstance(node, dict):
            return
        all_of = node.get("allOf")
        if not isinstance(all_of, list):
            return
        arrays = [s for s in all_of if isinstance(s, dict) and s.get("type") == "array"]
        others = [
            s for s in all_of if not (isinstance(s, dict) and s.get("type") == "array")
        ]
        if len(arrays) != 1:
            return
        if not all(
            isinstance(s, dict) and set(s.keys()).issubset(_METADATA_ONLY_KEYS)
            for s in others
        ):
            return
        merged = _deep_copy_yaml(arrays[0])
        for sib in others:
            for k, v in sib.items():
                merged.setdefault(k, v)
        for k, v in node.items():
            if k == "allOf":
                continue
            merged.setdefault(k, v)
        parent[key] = merged

    _walk_refs(root, visit)


def _deep_copy_yaml(node: Any) -> Any:
    if isinstance(node, dict):
        return {k: _deep_copy_yaml(v) for k, v in node.items()}
    if isinstance(node, list):
        return [_deep_copy_yaml(v) for v in node]
    return node


_INVALID_IDENT_RE = re.compile(r"[^A-Za-z0-9]")


def _ident(text: str) -> str:
    parts = [p for p in _INVALID_IDENT_RE.split(text) if p]
    joined = "".join(p[:1].upper() + p[1:] for p in parts)
    return joined or "X"


def rename_digit_prefixed_schemas(spec: dict) -> int:
    schemas = spec.get("components", {}).get("schemas", {}) or {}
    ref_prefix = "#/components/schemas/"

    rename: dict[str, str] = {}
    for name in list(schemas.keys()):
        m = re.match(r"^_?(\d+)(.*)$", name)
        if m:
            new_name = f"Http{m.group(1)}{_ident(m.group(2))}"
            base = new_name
            n = 2
            while new_name in schemas or new_name in rename.values():
                new_name = f"{base}V{n}"
                n += 1
            rename[name] = new_name

    if not rename:
        return 0

    for old, new in rename.items():
        schemas[new] = schemas.pop(old)

    old_to_new_ref = {ref_prefix + o: ref_prefix + n for o, n in rename.items()}

    def visit(parent, key, node):
        if isinstance(node, dict):
            ref = node.get("$ref")
            if isinstance(ref, str) and ref in old_to_new_ref:
                node["$ref"] = old_to_new_ref[ref]

    _walk_refs(spec, visit)
    return len(rename)


def name_inline_response_schemas(spec: dict) -> int:
    components = spec.setdefault("components", {})
    schemas = components.setdefault("schemas", {})
    ref_prefix = "#/components/schemas/"
    hoisted = 0

    for path, path_item in (spec.get("paths") or {}).items():
        if not isinstance(path_item, dict):
            continue
        for method, op in path_item.items():
            if method not in {
                "get",
                "post",
                "put",
                "patch",
                "delete",
                "head",
                "options",
            }:
                continue
            if not isinstance(op, dict):
                continue
            op_id = op.get("operationId") or (_ident(path) + method.title())
            responses = op.get("responses") or {}
            for code, resp in responses.items():
                if not isinstance(resp, dict):
                    continue
                content = resp.get("content") or {}
                for mime, media in content.items():
                    if not isinstance(media, dict):
                        continue
                    schema = media.get("schema")
                    if not isinstance(schema, dict):
                        continue
                    if "$ref" in schema:
                        continue
                    if (
                        schema.get("type") not in {"object", "array"}
                        and "properties" not in schema
                        and "allOf" not in schema
                    ):
                        continue
                    name = f"{_ident(op_id)}Response{code}"
                    base = name
                    n = 2
                    while name in schemas:
                        name = f"{base}V{n}"
                        n += 1
                    schemas[name] = schema
                    media["schema"] = {"$ref": ref_prefix + name}
                    hoisted += 1
    return hoisted


_HTML_TAG_RE = re.compile(r"<[a-zA-Z/!][^<>]*>")


def _has_html(text: str) -> bool:
    return bool(_HTML_TAG_RE.search(text))


def _clean_markdown(md: str) -> str:
    md = re.sub(r"[ \t]+\n", "\n", md)
    md = re.sub(r"\n{3,}", "\n\n", md)
    return md.strip()


def htmlize_descriptions_to_markdown(node: Any) -> int:
    converted = 0
    if isinstance(node, dict):
        for k, v in list(node.items()):
            if k == "description" and isinstance(v, str) and _has_html(v):
                node[k] = _clean_markdown(_html_to_markdown(v, heading_style="ATX"))
                converted += 1
            else:
                converted += htmlize_descriptions_to_markdown(v)
    elif isinstance(node, list):
        for v in node:
            converted += htmlize_descriptions_to_markdown(v)
    return converted


WB_DEV_BASE = "https://dev.wildberries.ru"
_REL_LINK_RE = re.compile(r"(\]\()(/(?!/)[^)\s]*)(\))")


def absolutize_description_links(node: Any) -> int:
    fixed = 0
    if isinstance(node, dict):
        for k, v in list(node.items()):
            if k == "description" and isinstance(v, str) and "](/" in v:
                new = _REL_LINK_RE.sub(rf"\g<1>{WB_DEV_BASE}\g<2>\g<3>", v)
                if new != v:
                    node[k] = new
                    fixed += 1
            else:
                fixed += absolutize_description_links(v)
    elif isinstance(node, list):
        for v in node:
            fixed += absolutize_description_links(v)
    return fixed


def sanitize_non_ascii_enums(node: Any) -> int:
    fixed = 0
    if isinstance(node, dict):
        enum = node.get("enum")
        if (
            isinstance(enum, list)
            and node.get("type") in (None, "string")
            and "x-enum-varnames" not in node
            and any(isinstance(v, str) and not v.isascii() for v in enum)
        ):
            varnames = []
            seen = set()
            for i, v in enumerate(enum, start=1):
                ident = _ident(str(v)) if isinstance(v, str) else f"Value{i}"
                if not ident or ident in seen:
                    ident = f"Value{i}"
                seen.add(ident)
                varnames.append(ident)
            node["x-enum-varnames"] = varnames
            fixed += 1
        for v in node.values():
            fixed += sanitize_non_ascii_enums(v)
    elif isinstance(node, list):
        for v in node:
            fixed += sanitize_non_ascii_enums(v)
    return fixed


def drop_date_formats(node: Any) -> int:
    fixed = 0
    if isinstance(node, dict):
        if node.get("type") == "string" and node.get("format") in ("date", "date-time"):
            del node["format"]
            fixed += 1
        for v in node.values():
            fixed += drop_date_formats(v)
    elif isinstance(node, list):
        for v in node:
            fixed += drop_date_formats(v)
    return fixed


_REF_PREFIX = "#/components/schemas/"


def _collect_schema_refs(node: Any, out: set) -> None:
    if isinstance(node, dict):
        ref = node.get("$ref")
        if isinstance(ref, str) and ref.startswith(_REF_PREFIX):
            out.add(ref[len(_REF_PREFIX) :])
        for v in node.values():
            _collect_schema_refs(v, out)
    elif isinstance(node, list):
        for v in node:
            _collect_schema_refs(v, out)


def drop_response_required(spec: dict) -> int:
    schemas = spec.get("components", {}).get("schemas", {}) or {}
    if not schemas:
        return 0

    reachable: set = set()
    for path_item in (spec.get("paths") or {}).values():
        if not isinstance(path_item, dict):
            continue
        for method, op in path_item.items():
            if method not in {
                "get",
                "post",
                "put",
                "patch",
                "delete",
                "head",
                "options",
            }:
                continue
            if isinstance(op, dict):
                _collect_schema_refs(op.get("responses") or {}, reachable)

    queue = list(reachable)
    while queue:
        schema = schemas.get(queue.pop())
        if not isinstance(schema, dict):
            continue
        refs: set = set()
        _collect_schema_refs(schema, refs)
        for ref in refs - reachable:
            reachable.add(ref)
            queue.append(ref)

    dropped = 0

    def strip(node: Any) -> None:
        nonlocal dropped
        if isinstance(node, dict):
            if isinstance(node.get("required"), list):
                del node["required"]
                dropped += 1
            for v in node.values():
                strip(v)
        elif isinstance(node, list):
            for v in node:
                strip(v)

    for name in reachable:
        schema = schemas.get(name)
        if isinstance(schema, dict):
            strip(schema)
    return dropped


def rename_tags_to_module(spec: dict, module: str) -> int:
    renamed = 0
    for path_item in (spec.get("paths") or {}).values():
        if not isinstance(path_item, dict):
            continue
        for method, op in path_item.items():
            if method not in {
                "get",
                "post",
                "put",
                "patch",
                "delete",
                "head",
                "options",
            }:
                continue
            if not isinstance(op, dict):
                continue
            tags = op.get("tags")
            if isinstance(tags, list) and tags:
                op["x-original-tags"] = tags
            op["tags"] = [module]
            renamed += 1
    return renamed


def add_docs_links(spec: dict, slug: str) -> int:
    linked = 0
    seen_pages: set = set()
    for path, path_item in (spec.get("paths") or {}).items():
        if not isinstance(path_item, dict):
            continue
        for method, op in path_item.items():
            if method not in {
                "get",
                "post",
                "put",
                "patch",
                "delete",
                "head",
                "options",
            }:
                continue
            if not isinstance(op, dict):
                continue
            page = page_slug(method, path)
            if page in seen_pages:
                page = (
                    f"{page}-{snake_case(op.get('operationId', '')).replace('_', '-')}"
                )
            seen_pages.add(page)
            url = f"{DOCS_SITE}/reference/api/{slug}/{page}"
            desc = (op.get("description") or "").rstrip()
            op["description"] = (
                f"{desc}\n\n{DOCS_LINK_LABEL}: {url}"
                if desc
                else f"{DOCS_LINK_LABEL}: {url}"
            )
            linked += 1
    return linked


def process_file(src: Path, dst: Path) -> dict:
    with src.open("r", encoding="utf-8") as f:
        spec = yaml.load(f)
    if not isinstance(spec, dict):
        raise SystemExit(f"{src}: root is not a mapping")

    inject_bearer_auth(spec)
    stats = {
        "arrays": fix_untyped_arrays(spec),
        "integers_widened": widen_integer_formats(spec),
        "inlined_arrays": inline_top_level_arrays(spec),
        "renamed_schemas": rename_digit_prefixed_schemas(spec),
        "hoisted_responses": name_inline_response_schemas(spec),
        "required_dropped": drop_response_required(spec),
        "enums": sanitize_non_ascii_enums(spec),
        "tags_renamed": rename_tags_to_module(spec, module_class_name(src.stem)),
        "date_formats_dropped": drop_date_formats(spec),
        "descriptions_md": htmlize_descriptions_to_markdown(spec),
        "links_absolutized": absolutize_description_links(spec),
        "docs_links": add_docs_links(spec, module_slug(src.stem)),
    }

    dst.parent.mkdir(parents=True, exist_ok=True)
    with dst.open("w", encoding="utf-8") as f:
        yaml.dump(spec, f)
    return stats


def main() -> int:
    src_dir = SWAGGER_DIR
    dst_dir = PROCESSED_DIR

    specs = sorted(p for p in src_dir.glob("*.yaml") if p.parent == src_dir)
    if not specs:
        sys.stderr.write(
            f"No specs found in {src_dir}. Run download-swaggers.py first.\n"
        )
        return 1

    totals = {
        "arrays": 0,
        "integers_widened": 0,
        "inlined_arrays": 0,
        "renamed_schemas": 0,
        "hoisted_responses": 0,
        "required_dropped": 0,
        "enums": 0,
        "tags_renamed": 0,
        "date_formats_dropped": 0,
        "descriptions_md": 0,
        "links_absolutized": 0,
        "docs_links": 0,
    }
    for spec_path in specs:
        target = dst_dir / spec_path.name
        stats = process_file(spec_path, target)
        for k, v in stats.items():
            totals[k] += v
        print(
            f"  {spec_path.name:28s} "
            f"arrays={stats['arrays']:>2} "
            f"integers-widened={stats['integers_widened']:>4} "
            f"inlined-arrays={stats['inlined_arrays']:>2} "
            f"renamed={stats['renamed_schemas']:>2} "
            f"hoisted-responses={stats['hoisted_responses']:>3} "
            f"required-dropped={stats['required_dropped']:>2} "
            f"enums={stats['enums']:>2} "
            f"tags-renamed={stats['tags_renamed']:>3} "
            f"date-formats={stats['date_formats_dropped']:>2} "
            f"desc-md={stats['descriptions_md']:>4} "
            f"abs-links={stats['links_absolutized']:>4} "
            f"docs-links={stats['docs_links']:>3}"
        )

    print(f"Processed {len(specs)} specs → {dst_dir} " f"(totals: {totals})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
