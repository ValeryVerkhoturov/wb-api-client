#!/usr/bin/env python3
"""Post-process downloaded WB OpenAPI specs before code generation.

Passes applied to every spec:

1. `inject_bearer_auth` — WB requires a JWT in the `Authorization` header
   for every endpoint but upstream declares no security scheme. We add a
   global `BearerAuth` (HTTP bearer, JWT) so generated clients expose an
   `access_token` / `accessToken` config parameter.

2. `fix_untyped_arrays` — arrays missing an `items` clause make the Go
   template emit `[]Array` (undefined) and TS fall back to `any[]`. We
   default missing inner types to `{type: string}`.

3. `inline_top_level_arrays` — WB defines schemas like `DaysV3` at the
   root as `type: array`. Java/Go/TS templates all mishandle a `$ref` to
   an array-at-root (Go emits `*Array`, Java calls `.validateJsonElement()`
   on `List<>`). We inline every array-schema $ref at its use site and
   delete the top-level entry.

4. `name_inline_response_schemas` — anonymous inline schemas under 4xx/5xx
   responses get auto-named `_409SupplyDeliverErrorData` by the generator,
   which is an invalid Go identifier (leading digit). We hoist each inline
   response schema to `#/components/schemas/<OperationId>Response<code>`
   so the generator uses a stable, language-safe name.

5. `sanitize_non_ascii_enums` — string enums whose values are non-ASCII
   (e.g. `["Склад WB", "Склад продавца"]`) produce empty JS/Go/Java
   identifiers. We add `x-enum-varnames: [Value1, Value2, ...]` so the
   generator has a fallback ASCII name for every value.

6. `htmlize_descriptions_to_markdown` — WB descriptions are HTML (with
   `<div class="api-block">`, `<a href>`, `<strong>`, `<br>`, `<ul>`, etc.)
   which reads badly in generated code doc-comments. Convert every
   `description` string to Markdown so docstrings and Javadoc/JSDoc render
   as intended.

7. `absolutize_description_links` — Markdown links in descriptions point
   at relative paths on the WB developer portal (e.g.
   `[warehouses inventory](/openapi/reports#tag/warehousesInventoryReport)`).
   Those don't resolve outside the portal, so we prefix them with
   `https://dev.wildberries.ru`. Runs after the HTML→Markdown pass so it
   sees the final link form.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path
from typing import Any

try:
    from ruamel.yaml import YAML  # preserves ordering & comments
except ImportError:  # pragma: no cover - installed via requirements.txt
    sys.stderr.write(
        "ruamel.yaml is required. Install with `pip install ruamel.yaml`.\n"
    )
    raise

try:
    from markdownify import markdownify as _html_to_markdown
except ImportError:  # pragma: no cover - installed via requirements.txt
    sys.stderr.write(
        "markdownify is required. Install with `pip install markdownify`.\n"
    )
    raise

SECURITY_SCHEME_NAME = "BearerAuth"

yaml = YAML()
yaml.preserve_quotes = True
yaml.width = 4096  # avoid line wrapping that fights with git diffs


def inject_bearer_auth(spec: dict) -> None:
    components = spec.setdefault("components", {})
    schemes = components.setdefault("securitySchemes", {})
    schemes[SECURITY_SCHEME_NAME] = {
        "type": "http",
        "scheme": "bearer",
        "bearerFormat": "JWT",
        "description": (
            "Wildberries API token (JWT). Create in the seller portal → "
            "Настройки → Доступ к API. Sent as `Authorization: Bearer <token>`."
        ),
    }
    spec["security"] = [{SECURITY_SCHEME_NAME: []}]


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


def _walk_refs(node: Any, visitor):
    """Depth-first walk. Calls visitor(parent_container, key_or_index, node)
    for every mapping/list encountered. Visitor may mutate `parent_container[key]`.
    """
    if isinstance(node, dict):
        for k in list(node.keys()):
            _walk_refs(node[k], visitor)
            visitor(node, k, node[k])
    elif isinstance(node, list):
        for i in range(len(node)):
            _walk_refs(node[i], visitor)
            visitor(node, i, node[i])


def inline_top_level_arrays(spec: dict) -> int:
    """Inline every $ref pointing at a top-level array schema, then drop
    the array schema from components. Returns the number of schemas inlined.

    After inlining, also collapses any `allOf: [array, description-only]`
    wrapper into a plain array schema — openapi-generator's Java/Go/TS
    templates emit a bogus `*Array` type when they see an allOf combining
    an array-typed subschema with siblings.
    """
    schemas = spec.get("components", {}).get("schemas", {}) or {}
    array_schemas = {
        name: sch for name, sch in schemas.items()
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
            name = ref[len(ref_prefix):]
            parent[key] = _deep_copy_yaml(array_schemas[name])
            replaced_count[0] += 1

    # Inlined array schemas can themselves contain $refs to other array
    # schemas that were placed after the walker visited that subtree. Loop
    # until no more replacements happen.
    while True:
        before = replaced_count[0]
        _walk_refs(spec, visit_inline)
        if replaced_count[0] == before:
            break

    for name in array_schemas:
        del schemas[name]

    # Second pass: collapse `allOf` wrappers that contain exactly one
    # array-typed sub-schema plus items that only carry metadata (they have
    # no `type` / `properties` / `$ref` / composition keywords of their own).
    _collapse_array_alloofs(spec)
    return len(array_schemas)


_METADATA_ONLY_KEYS = {"description", "title", "example", "examples", "readOnly",
                       "writeOnly", "deprecated", "nullable", "default"}


def _collapse_array_alloofs(root: Any) -> None:
    def visit(parent, key, node):
        if not isinstance(node, dict):
            return
        all_of = node.get("allOf")
        if not isinstance(all_of, list):
            return
        arrays = [s for s in all_of if isinstance(s, dict) and s.get("type") == "array"]
        others = [s for s in all_of if not (isinstance(s, dict) and s.get("type") == "array")]
        if len(arrays) != 1:
            return
        # Every non-array sibling must be metadata-only (no schema shape).
        if not all(
            isinstance(s, dict) and set(s.keys()).issubset(_METADATA_ONLY_KEYS)
            for s in others
        ):
            return
        merged = _deep_copy_yaml(arrays[0])
        for sib in others:
            for k, v in sib.items():
                merged.setdefault(k, v)
        # Preserve any metadata keys that were on the allOf wrapper itself
        # (e.g. `description` on the parent property).
        for k, v in node.items():
            if k == "allOf":
                continue
            merged.setdefault(k, v)
        parent[key] = merged

    _walk_refs(root, visit)


def _deep_copy_yaml(node: Any) -> Any:
    """Deep-copy ruamel yaml nodes (they aren't safe to share references
    across the tree if a later pass mutates them).
    """
    if isinstance(node, dict):
        return {k: _deep_copy_yaml(v) for k, v in node.items()}
    if isinstance(node, list):
        return [_deep_copy_yaml(v) for v in node]
    return node


_INVALID_IDENT_RE = re.compile(r"[^A-Za-z0-9]")


def _ident(text: str) -> str:
    """Turn arbitrary text into a PascalCase identifier fragment. Empty
    result → 'X' so we always emit something a code generator can consume.
    """
    parts = [p for p in _INVALID_IDENT_RE.split(text) if p]
    joined = "".join(p[:1].upper() + p[1:] for p in parts)
    return joined or "X"


def rename_digit_prefixed_schemas(spec: dict) -> int:
    """Rename components.schemas whose names start with (`_?<digit>`) —
    invalid Go identifiers. WB literally has entries like `409SupplyDeliverError`
    in its spec. Rewrite as `HttpNNN...` and update every $ref site.
    """
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

    # Rewrite the components map.
    for old, new in rename.items():
        schemas[new] = schemas.pop(old)

    # Rewrite every $ref pointing at a renamed schema.
    old_to_new_ref = {ref_prefix + o: ref_prefix + n for o, n in rename.items()}

    def visit(parent, key, node):
        if isinstance(node, dict):
            ref = node.get("$ref")
            if isinstance(ref, str) and ref in old_to_new_ref:
                node["$ref"] = old_to_new_ref[ref]

    _walk_refs(spec, visit)
    return len(rename)


def name_inline_response_schemas(spec: dict) -> int:
    """Hoist inline response schemas to named components. Reason: the
    generator auto-names inline `'409'` response bodies as `_409Foo`, which
    is not a valid Go identifier. We give them stable names like
    `<OperationId>Response409` first.
    """
    components = spec.setdefault("components", {})
    schemas = components.setdefault("schemas", {})
    ref_prefix = "#/components/schemas/"
    hoisted = 0

    for path, path_item in (spec.get("paths") or {}).items():
        if not isinstance(path_item, dict):
            continue
        for method, op in path_item.items():
            if method not in {"get", "post", "put", "patch", "delete", "head", "options"}:
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
                        continue  # already named
                    # Only hoist object/array schemas — primitives don't
                    # need a class.
                    if schema.get("type") not in {"object", "array"} and "properties" not in schema and "allOf" not in schema:
                        continue
                    name = f"{_ident(op_id)}Response{code}"
                    # Avoid collisions if the same shape is reused.
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
    # markdownify emits a lot of consecutive blank lines when converting
    # nested divs; collapse runs of >2 newlines and strip trailing spaces
    # per line so generated doc comments don't look scattered.
    md = re.sub(r"[ \t]+\n", "\n", md)
    md = re.sub(r"\n{3,}", "\n\n", md)
    return md.strip()


def htmlize_descriptions_to_markdown(node: Any) -> int:
    """Convert every string-valued `description` field from HTML to Markdown.

    WB descriptions embed `<div>`, `<a>`, `<strong>`, `<br>`, `<ul>`/`<li>`,
    `<code>`, `<pre>`, `<hr>` — none of which render in a Python docstring
    or Javadoc. Converted Markdown is what OpenAPI-style tooling expects
    and what generators will faithfully pass through into doc comments.
    """
    converted = 0
    if isinstance(node, dict):
        for k, v in list(node.items()):
            if k == "description" and isinstance(v, str) and _has_html(v):
                # Do NOT pass strip=["div"]: stripping the div tag also
                # strips its block-level semantics, collapsing adjacent
                # `<div>…</div><div>…</div>` blocks into one line with no
                # paragraph break. markdownify's default handling of
                # `<div>` already emits `\n\n` between blocks.
                node[k] = _clean_markdown(
                    _html_to_markdown(v, heading_style="ATX")
                )
                converted += 1
            else:
                converted += htmlize_descriptions_to_markdown(v)
    elif isinstance(node, list):
        for v in node:
            converted += htmlize_descriptions_to_markdown(v)
    return converted


WB_DEV_BASE = "https://dev.wildberries.ru"
# Matches a Markdown link whose destination starts with `/` — a site-root
# relative URL on the WB dev portal. Excludes `//host/...` protocol-relative
# links and preserves any leading whitespace / punctuation before `[`.
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
    """For string enums with any non-ASCII value, add x-enum-varnames so
    generators have a valid identifier for each value.
    """
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


def process_file(src: Path, dst: Path) -> dict:
    with src.open("r", encoding="utf-8") as f:
        spec = yaml.load(f)
    if not isinstance(spec, dict):
        raise SystemExit(f"{src}: root is not a mapping")

    inject_bearer_auth(spec)
    stats = {
        "arrays": fix_untyped_arrays(spec),
        "inlined_arrays": inline_top_level_arrays(spec),
        "renamed_schemas": rename_digit_prefixed_schemas(spec),
        "hoisted_responses": name_inline_response_schemas(spec),
        "enums": sanitize_non_ascii_enums(spec),
        "descriptions_md": htmlize_descriptions_to_markdown(spec),
        "links_absolutized": absolutize_description_links(spec),
    }

    dst.parent.mkdir(parents=True, exist_ok=True)
    with dst.open("w", encoding="utf-8") as f:
        yaml.dump(spec, f)
    return stats


def main() -> int:
    repo_root = Path(__file__).resolve().parent.parent
    src_dir = repo_root / "swaggers"
    dst_dir = src_dir / "processed"

    specs = sorted(p for p in src_dir.glob("*.yaml") if p.parent == src_dir)
    if not specs:
        sys.stderr.write(f"No specs found in {src_dir}. Run download-swaggers.sh first.\n")
        return 1

    totals = {"arrays": 0, "inlined_arrays": 0, "renamed_schemas": 0,
              "hoisted_responses": 0, "enums": 0, "descriptions_md": 0,
              "links_absolutized": 0}
    for spec_path in specs:
        target = dst_dir / spec_path.name
        stats = process_file(spec_path, target)
        for k, v in stats.items():
            totals[k] += v
        print(
            f"  {spec_path.name:28s} "
            f"arrays={stats['arrays']:>2} "
            f"inlined-arrays={stats['inlined_arrays']:>2} "
            f"renamed={stats['renamed_schemas']:>2} "
            f"hoisted-responses={stats['hoisted_responses']:>3} "
            f"enums={stats['enums']:>2} "
            f"desc-md={stats['descriptions_md']:>4} "
            f"abs-links={stats['links_absolutized']:>4}"
        )

    print(
        f"Processed {len(specs)} specs → {dst_dir} "
        f"(totals: {totals})"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
