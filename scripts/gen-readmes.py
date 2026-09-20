#!/usr/bin/env python3
"""Generate a README.md under each generated client (Python, TypeScript,
Go, Java). Each README shows install + shared auth setup once, then a
per-module section with import snippet and a link to the WB dev-portal
docs. Runs from generate.sh after the four language trees are laid down.

The content is derived from:
  - swaggers/processed/*.yaml     — title + first-para description per slug
  - clients/<lang>/…              — enumerate concrete Api class names

so a spec addition surfaces automatically on the next regeneration.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

try:
    from ruamel.yaml import YAML
except ImportError:
    sys.stderr.write("ruamel.yaml required. `pip install -r scripts/requirements.txt`.\n")
    raise

JAVA_ROOT_PATH = "io/github/valeryverkhoturov/wbapi"
JAVA_ROOT_PKG = "io.github.valeryverkhoturov.wbapi"

yaml = YAML()
yaml.width = 4096


def load_specs(spec_dir: Path) -> list[dict]:
    """Return one dict per spec: slug, snake, title, blurb, docs_hint."""
    out = []
    for p in sorted(spec_dir.glob("*.yaml")):
        with open(p) as f:
            s = yaml.load(f)
        slug = p.stem.split("-", 1)[1]           # "02-items" → "items"
        snake = slug.replace("-", "_")
        info = s.get("info", {}) or {}
        title = info.get("title", slug)
        desc = (info.get("description") or "").strip()
        # First non-empty line, stripped of trailing punctuation, capped
        # at ~200 chars so tables/sections stay readable.
        blurb = _first_line(desc)
        out.append({
            "slug": slug,
            "snake": snake,
            "title": title,
            "blurb": blurb,
            "raw_desc": desc,
        })
    return out


def _first_line(md: str) -> str:
    # Take the first paragraph, strip Markdown list markers, collapse
    # whitespace, cap length.
    para = md.split("\n\n", 1)[0]
    para = re.sub(r"^\s*[-*]\s+", "", para, flags=re.M)
    para = re.sub(r"\s+", " ", para).strip()
    if len(para) > 240:
        para = para[:237].rstrip() + "…"
    return para


# ────────── API-class enumeration ──────────

def python_apis(root: Path, snake: str) -> list[str]:
    api_dir = root / "wb_api_client" / snake / "api"
    if not api_dir.is_dir():
        return []
    names: set[str] = set()
    for f in api_dir.glob("*.py"):
        # `\w*Api` intentionally matches `Api` alone as well as `XxxApi`;
        # some specs emit a plain `class Api` when no operation carries a
        # tag prefix.
        for m in re.finditer(r"^class (\w*Api)\b", f.read_text(), re.M):
            names.add(m.group(1))
    return sorted(names)


def ts_apis(root: Path, slug: str) -> list[str]:
    apis: set[str] = set()
    api_dir = root / "src" / slug / "api"
    api_file = root / "src" / slug / "api.ts"
    for f in (list(api_dir.glob("*.ts")) if api_dir.is_dir() else []) + \
             ([api_file] if api_file.exists() else []):
        for m in re.finditer(r"export class (\w*Api)\b[^{]*\{", f.read_text()):
            apis.add(m.group(1))
    return sorted(apis)


def go_apis(root: Path, snake: str) -> list[str]:
    pkg_dir = root / snake
    if not pkg_dir.is_dir():
        return []
    apis: set[str] = set()
    for f in pkg_dir.glob("api_*.go"):
        # Go template uses either `XxxApi` or all-caps `XxxAPI` for
        # interface names — accept both.
        for m in re.finditer(r"^type (\w*(?:Api|API)) interface", f.read_text(), re.M):
            apis.add(m.group(1))
    return sorted(apis)


def java_apis(root: Path, snake: str) -> list[str]:
    api_dir = root / "src/main/java" / JAVA_ROOT_PATH / snake / "api"
    if not api_dir.is_dir():
        return []
    return sorted(p.stem for p in api_dir.glob("*.java"))


def php_apis(root: Path, pascal: str) -> list[str]:
    api_dir = root / "src" / pascal / "Api"
    if not api_dir.is_dir():
        return []
    return sorted(p.stem for p in api_dir.glob("*.php"))


# ────────── per-language README rendering ──────────

_HEADER = """# wb-api-client — {lang_display}

Auto-generated {lang_display} client for the [Wildberries Seller API](https://dev.wildberries.ru/). One package, thirteen sub-modules — one per API category. This README is regenerated on every release, so it always matches the code in this tree.

## Install

```bash
{install}
```

## Authentication

Every module accepts the same WB bearer JWT. The token is stored in a redacting wrapper — {wrapper_note} — so it does not leak under logs / `{log_call}` unless you explicitly ask for the raw value with `{expose_call}`.

```{lang_code}
{auth_snippet}
```

## Modules

Each row below is a sub-module you can import independently. Import path is `{import_prefix}<slug>`.

| Slug | Category | APIs |
|---|---|---|
{module_table}

## Per-module usage

"""


def _pysnippet(slug: str, apis: list[str]) -> str:
    api = apis[0] if apis else "DefaultApi"
    return (
        f"from wb_api_client.{slug} import Configuration, ApiClient\n"
        f"from wb_api_client.{slug}.api import {api}\n\n"
        f"cfg = Configuration(access_token=\"<your WB JWT>\")\n"
        f"api = {api}(ApiClient(cfg))"
    )


def _tssnippet(slug: str, apis: list[str]) -> str:
    api = apis[0] if apis else "DefaultApi"
    return (
        f"import {{ Configuration, {api} }} from \"@valeryverkhoturov/wb-api-client/{slug}\";\n\n"
        f"const cfg = new Configuration({{}});\n"
        f"cfg.setAccessToken(\"<your WB JWT>\");\n"
        f"const api = new {api}(cfg);"
    )


def _gosnippet(snake: str, apis: list[str]) -> str:
    # In Go each Api is exposed as an interface + Api service instance;
    # api := client.<Api-name-without-'Api'>Api works for openapi-generator
    # output, so we point users at the client itself rather than a
    # standalone constructor.
    return (
        f"import wb{snake} \"github.com/ValeryVerkhoturov/wb-api-client/clients/go/{snake}\"\n\n"
        f"cfg := wb{snake}.NewConfiguration()\n"
        f"cfg.SetAccessToken(\"<your WB JWT>\")\n"
        f"client := wb{snake}.NewAPIClient(cfg)"
    )


def _javasnippet(snake: str, apis: list[str]) -> str:
    api = apis[0] if apis else "DefaultApi"
    pkg = f"{JAVA_ROOT_PKG}.{snake}"
    return (
        f"import {pkg}.ApiClient;\n"
        f"import {pkg}.SecretString;\n"
        f"import {pkg}.api.{api};\n\n"
        f"ApiClient client = new ApiClient();\n"
        f"client.setBearerToken(new SecretString(\"<your WB JWT>\"));\n"
        f"{api} api = new {api}(client);"
    )


def _phpsnippet(pascal: str, apis: list[str]) -> str:
    api = apis[0] if apis else "DefaultApi"
    ns = f"ValeryVerkhoturov\\WbApiClient\\{pascal}"
    return (
        f"use {ns}\\Configuration;\n"
        f"use {ns}\\SecretString;\n"
        f"use {ns}\\Api\\{api};\n"
        f"use GuzzleHttp\\Client;\n\n"
        f"$config = (new Configuration())\n"
        f"    ->setAccessTokenSecret(new SecretString('<your WB JWT>'));\n"
        f"$api = new {api}(new Client(), $config);"
    )


def write_readme(path: Path, header_ctx: dict, specs: list[dict],
                 apis_fn, snippet_fn, code_fence: str, docs_url: callable) -> None:
    # Module table
    rows = []
    for spec in specs:
        apis = apis_fn(spec)
        apis_str = ", ".join(f"`{a}`" for a in apis) or "—"
        docs = docs_url(spec)
        rows.append(
            f"| [`{spec['slug']}`]({docs}) | {spec['title']} | {apis_str} |"
        )
    header_ctx["module_table"] = "\n".join(rows)

    body = [_HEADER.format(**header_ctx)]
    for spec in specs:
        apis = apis_fn(spec)
        body.append(f"### {spec['slug']} — {spec['title']}\n\n")
        body.append(f"{spec['blurb']}\n\n")
        body.append(f"**Reference:** {docs_url(spec)}\n\n")
        if apis:
            body.append(f"**APIs:** {', '.join(f'`{a}`' for a in apis)}\n\n")
        body.append(f"```{code_fence}\n{snippet_fn(spec, apis)}\n```\n\n")

    path.write_text("".join(body))


# ────────── language-specific docs-URL heuristic ──────────
# The WB dev portal doesn't expose a machine-readable slug↔URL map, so we
# use the mapping WB uses in the descriptions themselves (extracted from
# the first `#/openapi/<name>` link we see, or fall back to the module
# slug). This produces deep-links for every category.

_WB_DOCS_RE = re.compile(r"https://dev\.wildberries\.ru/openapi/([a-z0-9-]+)")


def docs_url_for(spec: dict) -> str:
    m = _WB_DOCS_RE.search(spec["raw_desc"])
    portal_slug = m.group(1) if m else spec["slug"]
    return f"https://dev.wildberries.ru/openapi/{portal_slug}"


# ────────── entrypoint ──────────

def main() -> int:
    if len(sys.argv) != 2:
        sys.stderr.write("usage: gen-readmes.py <repo root>\n")
        return 2
    root = Path(sys.argv[1]).resolve()
    specs = load_specs(root / "swaggers" / "processed")
    if not specs:
        sys.stderr.write("no processed specs — run post-process.py first\n")
        return 1

    # ── Python ──
    py_root = root / "clients" / "python"
    write_readme(
        py_root / "README.md",
        header_ctx={
            "lang_display": "Python",
            "install": "pip install valeryverkhoturov-wb-api-client",
            "wrapper_note": "`pydantic.SecretStr`",
            "log_call": "print",
            "expose_call": ".get_secret_value()",
            "lang_code": "python",
            "auth_snippet": (
                "from wb_api_client.items import Configuration, ApiClient\n\n"
                "cfg = Configuration(access_token=\"<your WB JWT>\")\n"
                "client = ApiClient(cfg)"
            ),
            "import_prefix": "wb_api_client.",
        },
        specs=specs,
        apis_fn=lambda s: python_apis(py_root, s["snake"]),
        snippet_fn=lambda s, apis: _pysnippet(s["snake"], apis),
        code_fence="python",
        docs_url=docs_url_for,
    )

    # ── TypeScript ──
    ts_root = root / "clients" / "typescript"
    write_readme(
        ts_root / "README.md",
        header_ctx={
            "lang_display": "TypeScript",
            "install": "npm install @valeryverkhoturov/wb-api-client",
            "wrapper_note": "an internal `SecretString` class",
            "log_call": "console.log",
            "expose_call": ".exposeSecret()",
            "lang_code": "ts",
            "auth_snippet": (
                "import { Configuration } from \"@valeryverkhoturov/wb-api-client/items\";\n\n"
                "const cfg = new Configuration({});\n"
                "cfg.setAccessToken(\"<your WB JWT>\");"
            ),
            "import_prefix": "@valeryverkhoturov/wb-api-client/",
        },
        specs=specs,
        apis_fn=lambda s: ts_apis(ts_root, s["slug"]),
        snippet_fn=lambda s, apis: _tssnippet(s["slug"], apis),
        code_fence="ts",
        docs_url=docs_url_for,
    )

    # ── Go ──
    go_root = root / "clients" / "go"
    write_readme(
        go_root / "README.md",
        header_ctx={
            "lang_display": "Go",
            "install": "go get github.com/ValeryVerkhoturov/wb-api-client/clients/go@latest",
            "wrapper_note": "[`secrecy.SecretString`](https://github.com/negrel/secrecy)",
            "log_call": "fmt.Printf",
            "expose_call": ".ExposeSecret()",
            "lang_code": "go",
            "auth_snippet": (
                "import wbitems \"github.com/ValeryVerkhoturov/wb-api-client/clients/go/items\"\n\n"
                "cfg := wbitems.NewConfiguration()\n"
                "cfg.SetAccessToken(\"<your WB JWT>\")\n"
                "client := wbitems.NewAPIClient(cfg)"
            ),
            "import_prefix": "github.com/ValeryVerkhoturov/wb-api-client/clients/go/",
        },
        specs=specs,
        apis_fn=lambda s: go_apis(go_root, s["snake"]),
        snippet_fn=lambda s, apis: _gosnippet(s["snake"], apis),
        code_fence="go",
        docs_url=docs_url_for,
    )

    # ── Java ──
    ja_root = root / "clients" / "java"
    write_readme(
        ja_root / "README.md",
        header_ctx={
            "lang_display": "Java",
            "install": (
                "<dependency>\n"
                "  <groupId>io.github.valeryverkhoturov</groupId>\n"
                "  <artifactId>wb-api-client</artifactId>\n"
                "  <version>0.0.0.dev0</version>\n"
                "</dependency>"
            ),
            "wrapper_note": "a per-sub-module `SecretString` class",
            "log_call": "System.out.println",
            "expose_call": ".exposeSecret()",
            "lang_code": "java",
            "auth_snippet": (
                "import io.github.valeryverkhoturov.wbapi.items.ApiClient;\n"
                "import io.github.valeryverkhoturov.wbapi.items.SecretString;\n\n"
                "ApiClient client = new ApiClient();\n"
                "client.setBearerToken(new SecretString(\"<your WB JWT>\"));"
            ),
            "import_prefix": f"{JAVA_ROOT_PKG}.",
        },
        specs=specs,
        apis_fn=lambda s: java_apis(ja_root, s["snake"]),
        snippet_fn=lambda s, apis: _javasnippet(s["snake"], apis),
        code_fence="java",
        docs_url=docs_url_for,
    )

    # ── PHP ──
    ph_root = root / "clients" / "php"
    def _pascal(snake: str) -> str:
        return "".join(p[:1].upper() + p[1:] for p in snake.split("_"))
    for spec in specs:
        spec["_pascal"] = _pascal(spec["snake"])
    write_readme(
        ph_root / "README.md",
        header_ctx={
            "lang_display": "PHP",
            "install": "composer require valeryverkhoturov/wb-api-client",
            "wrapper_note": "a per-sub-module `SecretString` class",
            "log_call": "var_dump",
            "expose_call": "->exposeSecret()",
            "lang_code": "php",
            "auth_snippet": (
                "use ValeryVerkhoturov\\WbApiClient\\Items\\Configuration;\n"
                "use ValeryVerkhoturov\\WbApiClient\\Items\\SecretString;\n\n"
                "$config = (new Configuration())\n"
                "    ->setAccessTokenSecret(new SecretString('<your WB JWT>'));"
            ),
            "import_prefix": "ValeryVerkhoturov\\\\WbApiClient\\\\",
        },
        specs=specs,
        apis_fn=lambda s: php_apis(ph_root, s["_pascal"]),
        snippet_fn=lambda s, apis: _phpsnippet(s["_pascal"], apis),
        code_fence="php",
        docs_url=docs_url_for,
    )

    print(f"  wrote 5 per-language READMEs covering {len(specs)} modules each")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
