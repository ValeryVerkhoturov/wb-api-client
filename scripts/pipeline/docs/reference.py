#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path

from ..core.naming import DOCS_LINK_LABEL, DOCS_SITE
from ..core.naming import JAVA_ROOT_PKG as JAVA_PKG
from ..core.naming import (
    camel_case,
    go_alias,
    module_slug,
    page_slug,
    pascal_case,
    pascal_slug,
    snake_case,
    snake_slug,
)
from ..core.paths import REPO_ROOT
from ..core.proc import run
from ..core.yamlio import safe_yaml

yaml = safe_yaml()

HTTP_METHODS = ("get", "post", "put", "patch", "delete")

LANGS = ("python", "typescript", "go", "java", "php", "onescript", "csharp")

LANG_LABELS = {
    "python": ("Python", "python"),
    "typescript": ("TypeScript", "ts"),
    "go": ("Go", "go"),
    "java": ("Java", "java"),
    "php": ("PHP", "php"),
    "onescript": ("OneScript", "bsl"),
    "csharp": ("C#", "csharp"),
}

WB_DOCS = "https://dev.wildberries.ru/en/docs/openapi"

TOKEN = {"ru": "<ваш JWT WB>", "en": "<your WB JWT>"}


@dataclass
class Param:
    name: str
    location: str
    type: str
    required: bool
    description: str


@dataclass
class Response:
    code: str
    description: str
    schema: str


@dataclass
class Operation:
    module: str
    method: str
    path: str
    op_id: str
    summary: str
    description: str
    tag: str
    tag_key: str
    server: str
    page: str
    params: list[Param] = field(default_factory=list)
    body_schema: str = ""
    body_required: bool = False
    body_type: str = ""
    responses: list[Response] = field(default_factory=list)


@dataclass
class Module:
    slug: str
    title: str
    description: str
    portal: str
    operations: list[Operation] = field(default_factory=list)


_PORTAL_RE = re.compile(r"https://dev\.wildberries\.ru/openapi/([a-z0-9-]+)")

_DOCS_LINK_RE = re.compile(rf"\s*{DOCS_LINK_LABEL}: {re.escape(DOCS_SITE)}/\S+\s*$")


def strip_docs_link(text: str) -> str:
    return _DOCS_LINK_RE.sub("", text)


_PORTAL_REL_LINK = re.compile(r"\]\(\.{1,2}/([^)]+)\)")


def absolutize(text: str) -> str:
    return _PORTAL_REL_LINK.sub(r"](https://dev.wildberries.ru/openapi/\1)", text)


def _schema_name(schema: dict | None) -> str:
    if not schema:
        return ""
    ref = schema.get("$ref")
    if ref:
        return ref.rsplit("/", 1)[-1]
    if schema.get("type") == "array":
        inner = _schema_name(schema.get("items"))
        return f"{inner}[]" if inner else "array"
    return schema.get("type", "object")


def _param_type(schema: dict | None) -> str:
    if not schema:
        return "—"
    if "$ref" in schema:
        return _schema_name(schema)
    t = schema.get("type", "object")
    if t == "array":
        return f"{_param_type(schema.get('items'))}[]"
    fmt = schema.get("format")
    return f"{t}<{fmt}>" if fmt else t


def _first_content(content: dict | None) -> tuple[str, dict]:
    if not content:
        return "", {}
    media, body = next(iter(content.items()))
    return media, (body or {}).get("schema") or {}


def load_modules(spec_dir: Path) -> list[Module]:
    modules: list[Module] = []

    for spec_path in sorted(spec_dir.glob("*.yaml")):
        with open(spec_path, encoding="utf-8") as fh:
            spec = yaml.load(fh)

        slug = module_slug(spec_path.stem)
        info = spec.get("info") or {}
        raw_desc = absolutize((info.get("description") or "").strip())
        portal_match = _PORTAL_RE.search(raw_desc)

        module = Module(
            slug=slug,
            title=info.get("title", slug),
            description=raw_desc,
            portal=portal_match.group(1) if portal_match else slug,
        )

        shared_responses = (spec.get("components") or {}).get("responses") or {}
        spec_server = ((spec.get("servers") or [{}])[0] or {}).get("url", "")

        seen_pages: set[str] = set()

        for path, item in (spec.get("paths") or {}).items():
            common_params = item.get("parameters") or []

            for method, op in item.items():
                if method.lower() not in HTTP_METHODS or not isinstance(op, dict):
                    continue

                op_server = (
                    (op.get("servers") or item.get("servers") or [{}])[0] or {}
                ).get("url", spec_server)

                page = page_slug(method, path)
                if page in seen_pages:
                    page = f"{page}-{snake_case(op['operationId']).replace('_', '-')}"
                seen_pages.add(page)

                params = [
                    Param(
                        name=p.get("name", ""),
                        location=p.get("in", ""),
                        type=_param_type(p.get("schema")),
                        required=bool(p.get("required")),
                        description=absolutize((p.get("description") or "").strip()),
                    )
                    for p in (common_params + (op.get("parameters") or []))
                    if isinstance(p, dict) and "$ref" not in p
                ]

                body = op.get("requestBody") or {}
                body_type, body_schema = _first_content(body.get("content"))

                responses = []
                for code, resp in (op.get("responses") or {}).items():
                    resp = resp or {}
                    if "$ref" in resp:
                        resolved = (
                            shared_responses.get(resp["$ref"].rsplit("/", 1)[-1]) or {}
                        )
                    else:
                        resolved = resp
                    _, schema = _first_content(resolved.get("content"))
                    responses.append(
                        Response(
                            code=str(code),
                            description=absolutize(
                                (resolved.get("description") or "").strip()
                            ),
                            schema=_schema_name(schema),
                        )
                    )
                responses.sort(key=lambda r: (not r.code.isdigit(), r.code))

                module.operations.append(
                    Operation(
                        module=slug,
                        method=method.upper(),
                        path=path,
                        op_id=op["operationId"],
                        summary=(op.get("summary") or op["operationId"]).strip(),
                        description=absolutize(
                            strip_docs_link((op.get("description") or "").strip())
                        ),
                        tag=(op.get("x-original-tags") or op.get("tags") or [""])[0],
                        tag_key=op.get("x-tagKey", ""),
                        server=op_server,
                        page=page,
                        params=params,
                        body_schema=_schema_name(body_schema),
                        body_required=bool(body.get("required")),
                        body_type=body_type,
                        responses=responses,
                    )
                )

        modules.append(module)

    return modules


@dataclass
class Binding:
    cls: str
    method: str
    args: list[str]


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def _signature(text: str, open_paren: int) -> tuple[str, int]:
    depth = 0
    for i in range(open_paren, len(text)):
        if text[i] == "(":
            depth += 1
        elif text[i] == ")":
            depth -= 1
            if depth == 0:
                return text[open_paren + 1 : i], i
    return "", open_paren


def _split_params(sig: str) -> list[str]:
    out, depth, current = [], 0, ""
    for ch in sig:
        if ch in "<([{":
            depth += 1
        elif ch in ">)]}":
            depth -= 1
        if ch == "," and depth == 0:
            out.append(current)
            current = ""
        else:
            current += ch
    if current.strip():
        out.append(current)
    return [p.strip() for p in out if p.strip()]


def bind_python(root: Path, slug: str) -> dict[str, Binding]:
    out: dict[str, Binding] = {}
    for f in sorted(
        (root / "clients/python/wb_api_client" / snake_slug(slug) / "api").glob("*.py")
    ):
        text = _read(f)
        cls_match = re.search(r"^class (\w+):", text, re.M)
        cls = cls_match.group(1) if cls_match else f.stem
        for m in re.finditer(r"^    def (\w+)\(", text, re.M):
            name = m.group(1)
            if name.startswith("_") or name.endswith(
                ("_with_http_info", "_without_preload_content", "_serialize")
            ):
                continue
            sig, _ = _signature(text, m.end() - 1)
            args = []
            for p in _split_params(sig):
                arg = re.match(r"(\w+)", p)
                if arg and arg.group(1) != "self" and not arg.group(1).startswith("_"):
                    args.append(arg.group(1))
            out.setdefault(name, Binding(cls, name, args))
    return out


def bind_typescript(root: Path, slug: str) -> dict[str, Binding]:
    out: dict[str, Binding] = {}
    api = root / "clients/typescript/src" / slug / "api.ts"
    if not api.is_file():
        return out
    text = _read(api)
    chunks = re.split(r"^export class ", text, flags=re.M)[1:]
    for chunk in chunks:
        cls = chunk.split(None, 1)[0]
        if not cls.endswith("Api"):
            continue
        for m in re.finditer(r"^\s{2}public (\w+)\(", chunk, re.M):
            sig, _ = _signature(chunk, m.end() - 1)
            args = []
            for p in _split_params(sig):
                arg = re.match(r"(\w+)\??:", p.strip())
                if arg and arg.group(1) != "options":
                    args.append(arg.group(1))
            out.setdefault(m.group(1), Binding(cls, m.group(1), args))
    return out


def bind_go(root: Path, slug: str) -> dict[str, Binding]:
    out: dict[str, Binding] = {}
    for f in sorted((root / "clients/go" / snake_slug(slug)).glob("api_*.go")):
        text = _read(f)
        for m in re.finditer(
            r"^func \(a \*(\w+)Service\) (\w+)\(ctx context\.Context", text, re.M
        ):
            cls, name = m.group(1), m.group(2)
            sig, _ = _signature(text, m.end() - len("(ctx context.Context"))
            args = [p.split()[0] for p in _split_params(sig)[1:]]
            out.setdefault(name, Binding(cls, name, args))
    return out


def go_request_fields(root: Path, slug: str, op_id: str) -> list[str]:
    for f in sorted((root / "clients/go" / snake_slug(slug)).glob("api_*.go")):
        text = _read(f)
        m = re.search(
            rf"^type Api{re.escape(pascal_case(op_id))}Request struct \{{\n((?:.*\n)*?)\}}",
            text,
            re.M,
        )
        if not m:
            continue
        fields = []
        for line in m.group(1).splitlines():
            fm = re.match(r"^\t(\w+)\s+\S", line)
            if fm and fm.group(1) not in ("ctx", "ApiService"):
                fields.append(fm.group(1))
        return fields
    return []


def bind_java(root: Path, slug: str) -> dict[str, Binding]:
    out: dict[str, Binding] = {}
    api_dir = (
        root
        / "clients/java/src/main/java"
        / JAVA_PKG.replace(".", "/")
        / snake_slug(slug)
        / "api"
    )
    for f in sorted(api_dir.glob("*.java")):
        text = _read(f)
        cls_match = re.search(r"^public class (\w+)", text, re.M)
        cls = cls_match.group(1) if cls_match else f.stem
        for m in re.finditer(r"^  public [\w<>,\[\]\.?\s]+?(\w+)\(", text, re.M):
            name = m.group(1)
            if name.endswith(("Call", "WithHttpInfo", "Async", "ValidateBeforeCall")):
                continue
            sig, close = _signature(text, m.end() - 1)
            if "ApiCallback" in sig or not text[close + 1 :].lstrip().startswith(
                "throws ApiException"
            ):
                continue
            args = [p.split()[-1] for p in _split_params(sig)]
            out.setdefault(name, Binding(cls, name, args))
    return out


def bind_php(root: Path, slug: str) -> dict[str, Binding]:
    out: dict[str, Binding] = {}
    for f in sorted(
        (root / "clients/php/src" / pascal_slug(slug) / "Api").glob("*.php")
    ):
        text = _read(f)
        cls_match = re.search(r"^class (\w+)", text, re.M)
        cls = cls_match.group(1) if cls_match else f.stem
        for m in re.finditer(r"^    public function (\w+)\(", text, re.M):
            name = m.group(1)
            if name.startswith("__") or name.endswith(
                ("WithHttpInfo", "Async", "AsyncWithHttpInfo", "Request")
            ):
                continue
            sig, _ = _signature(text, m.end() - 1)
            args = []
            for p in _split_params(sig):
                if "=" in p:
                    continue
                var = re.search(r"\$(\w+)", p)
                if var:
                    args.append(var.group(1))
            out.setdefault(name, Binding(cls, name, args))
    return out


def bind_csharp(root: Path, slug: str) -> dict[str, Binding]:
    out: dict[str, Binding] = {}
    for f in sorted(
        (root / "clients/csharp/src" / pascal_slug(slug) / "Api").glob("*.cs")
    ):
        text = _read(f)
        cls_match = re.search(r"^    public partial class (\w+) :", text, re.M)
        cls = cls_match.group(1) if cls_match else f.stem
        for m in re.finditer(r"^        public [\w<>,\?\.\[\] ]+? (\w+)\(", text, re.M):
            name = m.group(1)
            if (
                name.endswith(("WithHttpInfo", "Async", "AsyncWithHttpInfo"))
                or name == cls
            ):
                continue
            sig, _ = _signature(text, m.end() - 1)
            args = []
            for p in _split_params(sig):
                if "=" in p:
                    continue
                parts = p.split()
                if parts:
                    args.append(parts[-1])
            out.setdefault(name, Binding(cls, name, args))
    return out


def bind_onescript(root: Path, slug: str) -> dict[str, Binding]:
    out: dict[str, Binding] = {}
    for f in sorted(
        (root / "clients/onescript/src/Классы" / pascal_slug(slug)).glob("*.os")
    ):
        text = _read(f)
        cls = f.stem
        for m in re.finditer(r"^Функция (\w+)\(", text, re.M):
            name = m.group(1)
            sig, _ = _signature(text, m.end() - 1)
            args = [
                p.strip().removeprefix("Знач ").strip()
                for p in _split_params(sig)
                if "=" not in p
            ]
            out.setdefault(name, Binding(cls, name, args))
    return out


BINDERS = {
    "python": (bind_python, snake_case),
    "typescript": (bind_typescript, camel_case),
    "go": (bind_go, pascal_case),
    "java": (bind_java, camel_case),
    "php": (bind_php, camel_case),
    "onescript": (bind_onescript, pascal_case),
    "csharp": (bind_csharp, pascal_case),
}


def build_index(root: Path, modules: list[Module]) -> dict[str, dict[str, Binding]]:
    index: dict[str, dict[str, Binding]] = {lang: {} for lang in LANGS}
    for module in modules:
        for lang, (binder, convert) in BINDERS.items():
            table = binder(root, module.slug)
            for op in module.operations:
                binding = table.get(convert(op.op_id))
                if binding:
                    index[lang][f"{module.slug}:{op.op_id}"] = binding
    return index


def snippet_python(op: Operation, b: Binding, locale: str) -> str:
    pkg = f"wb_api_client.{snake_slug(op.module)}"
    call = f"{', '.join(f'{a}=...' for a in b.args)}"
    return (
        f"from {pkg} import Configuration, ApiClient\n"
        f"from {pkg}.api import {b.cls}\n\n"
        f'cfg = Configuration(access_token="{TOKEN[locale]}")\n'
        f"api = {b.cls}(ApiClient(cfg))\n\n"
        f"result = api.{b.method}({call})\n"
        f"print(result)"
    )


def snippet_typescript(op: Operation, b: Binding, locale: str) -> str:
    call = ", ".join(b.args)
    return (
        f"import {{\n  Configuration,\n  {b.cls},\n}} "
        f'from "@valeryverkhoturov/wb-api-client/{op.module}";\n\n'
        f"const cfg = new Configuration({{}});\n"
        f'cfg.setAccessToken("{TOKEN[locale]}");\n'
        f"const api = new {b.cls}(cfg);\n\n"
        f"const {{ data }} = await api.{b.method}({call});\n"
        f"console.log(data);"
    )


def snippet_go(op: Operation, b: Binding, locale: str, setters: list[str]) -> str:
    alias = go_alias(op.module)
    chain = "".join(f".{s}({s[0].lower() + s[1:]})" for s in setters)
    args = "".join(f", {a}" for a in b.args)
    return (
        f"import (\n"
        f'\t"context"\n'
        f'\t"fmt"\n\n'
        f'\t{alias} "github.com/ValeryVerkhoturov/wb-api-client-go/{snake_slug(op.module)}"\n'
        f")\n\n"
        f"cfg := {alias}.NewConfiguration()\n"
        f'cfg.SetAccessToken("{TOKEN[locale]}")\n'
        f"client := {alias}.NewAPIClient(cfg)\n\n"
        f"result, _, err := client.{b.cls}.{b.method}(context.Background(){args}){chain}.Execute()\n"
        f"if err != nil {{\n    panic(err)\n}}\n"
        f'fmt.Printf("%+v\\n", result)'
    )


def snippet_java(op: Operation, b: Binding, locale: str) -> str:
    pkg = f"{JAVA_PKG}.{snake_slug(op.module)}"
    call = ", ".join(b.args)
    return (
        f"import {pkg}.ApiClient;\n"
        f"import {pkg}.SecretString;\n"
        f"import {pkg}.api.{b.cls};\n\n"
        f"ApiClient client = new ApiClient();\n"
        f'client.setBearerToken(new SecretString("{TOKEN[locale]}"));\n'
        f"{b.cls} api = new {b.cls}(client);\n\n"
        f"System.out.println(api.{b.method}({call}));"
    )


def snippet_php(op: Operation, b: Binding, locale: str) -> str:
    ns = f"ValeryVerkhoturov\\WbApiClient\\{pascal_slug(op.module)}"
    call = ", ".join(f"${a}" for a in b.args)
    return (
        f"use {ns}\\Configuration;\n"
        f"use {ns}\\SecretString;\n"
        f"use {ns}\\Api\\{b.cls};\n"
        f"use GuzzleHttp\\Client;\n\n"
        f"$config = (new Configuration())\n"
        f"    ->setAccessTokenSecret(new SecretString('{TOKEN[locale]}'));\n"
        f"$api = new {b.cls}(new Client(), $config);\n\n"
        f"print_r($api->{b.method}({call}));"
    )


def snippet_onescript(op: Operation, b: Binding, locale: str) -> str:
    call = ", ".join(b.args)
    return (
        f'#Использовать "wb-api-client"\n\n'
        f"Настройки = Новый Конфигурация();\n"
        f'Настройки.УстановитьТокен("{TOKEN[locale]}");\n'
        f"Клиент = Новый {b.cls}(Настройки);\n\n"
        f"Сообщить(Клиент.{b.method}({call}).Тело);"
    )


def snippet_csharp(op: Operation, b: Binding, locale: str) -> str:
    ns = f"ValeryVerkhoturov.WbApiClient.{pascal_slug(op.module)}"
    call = ", ".join(b.args)
    return (
        f"using {ns}.Api;\n"
        f"using {ns}.Client;\n\n"
        f"var config = new Configuration();\n"
        f'config.AccessTokenSecret = new SecretString("{TOKEN[locale]}");\n'
        f"var api = new {b.cls}(config);\n\n"
        f"Console.WriteLine(api.{b.method}({call}));"
    )


def render_examples(
    root: Path,
    op: Operation,
    index: dict[str, dict[str, Binding]],
    locale: str,
) -> list[str]:
    key = f"{op.module}:{op.op_id}"
    lines: list[str] = []

    for lang in LANGS:
        binding = index[lang].get(key)
        if not binding:
            continue

        if lang == "python":
            code = snippet_python(op, binding, locale)
        elif lang == "typescript":
            code = snippet_typescript(op, binding, locale)
        elif lang == "go":
            fields = go_request_fields(root, op.module, op.op_id)
            setters = [
                f[0].upper() + f[1:]
                for f in fields
                if f not in binding.args
                and (
                    op.body_required
                    or any(p.required and p.name == f for p in op.params)
                )
            ]
            code = snippet_go(op, binding, locale, setters)
        elif lang == "java":
            code = snippet_java(op, binding, locale)
        elif lang == "php":
            code = snippet_php(op, binding, locale)
        elif lang == "onescript":
            code = snippet_onescript(op, binding, locale)
        else:
            code = snippet_csharp(op, binding, locale)

        label, fence = LANG_LABELS[lang]
        lines.append(f"```{fence} [{label}]\n{code}\n```\n")

    return lines


STRINGS = {
    "ru": {
        "section": "Справочник API",
        "section_lede": (
            "Все {n} операций Wildberries Seller API, сгруппированные по {m} модулям пакета. "
            "Страницы генерируются из спецификаций OpenAPI и исходников сгенерированных "
            "клиентов, поэтому примеры вызова соответствуют коду той же версии."
        ),
        "module": "Модуль",
        "category": "Категория",
        "ops": "Операций",
        "operations": "Операции",
        "op_count": "Операций модуля `{slug}` — {n}.",
        "method": "Метод",
        "path": "Путь",
        "operation": "Операция",
        "section_col": "Раздел",
        "params": "Параметры",
        "p_name": "Имя",
        "p_in": "Где",
        "p_type": "Тип",
        "p_required": "Обяз.",
        "p_desc": "Описание",
        "body": "Тело запроса",
        "body_line": "`{type}` — схема `{schema}`{req}",
        "body_req": ", обязательно",
        "body_opt": ", необязательно",
        "responses": "Ответы",
        "r_code": "Код",
        "r_desc": "Описание",
        "r_schema": "Схема",
        "examples": "Примеры вызова",
        "examples_lede": (
            "Аргументы показаны именами параметров — подставьте свои значения. "
            "Языки, в клиенте которых этой операции нет, не показаны."
        ),
        "no_examples": (
            "Эта операция не представлена ни в одном из сгенерированных клиентов — "
            "вызывайте её напрямую по HTTP."
        ),
        "base": "База",
        "spec_docs": "Документация спецификации",
        "back": "Все модули",
        "yes": "да",
        "no": "нет",
        "generated": (
            "Страница сгенерирована из спецификации Wildberries. "
            "Правки вносите в [wb-api-client](https://github.com/ValeryVerkhoturov/wb-api-client)."
        ),
    },
    "en": {
        "section": "API reference",
        "section_lede": (
            "All {n} Wildberries Seller API operations, grouped into the package's {m} modules. "
            "Pages are generated from the OpenAPI specs and from the generated client sources, "
            "so every call example matches the code of the same release."
        ),
        "module": "Module",
        "category": "Category",
        "ops": "Operations",
        "operations": "Operations",
        "op_count": "Module `{slug}` has {n} operations.",
        "method": "Method",
        "path": "Path",
        "operation": "Operation",
        "section_col": "Section",
        "params": "Parameters",
        "p_name": "Name",
        "p_in": "In",
        "p_type": "Type",
        "p_required": "Req.",
        "p_desc": "Description",
        "body": "Request body",
        "body_line": "`{type}` — schema `{schema}`{req}",
        "body_req": ", required",
        "body_opt": ", optional",
        "responses": "Responses",
        "r_code": "Code",
        "r_desc": "Description",
        "r_schema": "Schema",
        "examples": "Call examples",
        "examples_lede": (
            "Arguments are shown as parameter names — substitute your own values. "
            "Languages whose client does not expose this operation are omitted."
        ),
        "no_examples": (
            "This operation is not exposed by any generated client — call it over plain HTTP."
        ),
        "base": "Base URL",
        "spec_docs": "Specification doc",
        "back": "All modules",
        "yes": "yes",
        "no": "no",
        "generated": (
            "Generated from the Wildberries specification. Send fixes to "
            "[wb-api-client](https://github.com/ValeryVerkhoturov/wb-api-client)."
        ),
    },
}


def esc_cell(text: str) -> str:
    return text.replace("|", "\\|").replace("\n", " ").strip()


def yaml_quote(text: str) -> str:
    return '"' + text.replace("\\", "\\\\").replace('"', '\\"') + '"'


def normalize_markdown(text: str) -> str:
    lines = [line.rstrip() for line in text.split("\n")]

    folded: list[str] = []
    pending: str | None = None
    for line in lines:
        if pending is not None:
            pending += "<br>" + line.strip()
            if line.endswith("|"):
                folded.append(pending)
                pending = None
            continue
        if line.lstrip().startswith("|") and not line.endswith("|"):
            pending = line
            continue
        folded.append(line)
    if pending is not None:
        folded.append(pending)

    out: list[str] = []
    for line in folded:
        previous = out[-1] if out else ""
        if (
            line.lstrip().startswith("|")
            and previous.strip()
            and not previous.lstrip().startswith("|")
        ):
            out.append("")
        out.append(line)

    return "\n".join(out)


def lede(op: Operation) -> str:
    first = op.description.split("\n\n", 1)[0]
    first = "\n".join(
        line for line in first.split("\n") if not line.lstrip().startswith("|")
    )
    plain = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", first)
    plain = re.sub(r"<[^>]+>", "", plain)
    plain = re.sub(r"[`*_#>]", "", plain).replace("\n", " ")
    plain = re.sub(r"\s+", " ", plain).strip()
    if not plain:
        return f"{op.summary} — {op.method} {op.path}"
    if len(plain) <= 160:
        return plain
    cut = plain[:160]
    return cut[: cut.rfind(" ")] + "…"


def base_path(locale: str) -> str:
    return "/reference/api" if locale == "ru" else "/en/reference/api"


def render_operation(
    root: Path,
    module: Module,
    op: Operation,
    index: dict[str, dict[str, Binding]],
    locale: str,
) -> str:
    s = STRINGS[locale]
    out: list[str] = []

    out.append("---")
    out.append(f"title: {yaml_quote(op.summary)}")
    out.append(f"description: {yaml_quote(lede(op))}")
    out.append("---")
    out.append("")
    out.append(f"# {op.summary}")
    out.append("")
    out.append(f"```http\n{op.method} {op.path}\n```")
    out.append("")

    meta = [f"**{s['base']}:** `{op.server}`"] if op.server else []
    meta.append(
        f"**{s['module']}:** [`{module.slug}`]({base_path(locale)}/{module.slug}/)"
    )
    if op.tag:
        meta.append(f"**{s['section_col']}:** {op.tag}")
    wb = f"{WB_DOCS}/{module.portal}"
    if op.tag_key:
        wb += f"#tag/{op.tag_key}/operation/{op.op_id}"
    meta.append(f"[{s['spec_docs']} ↗]({wb})")
    out.append(" · ".join(meta))
    out.append("")

    if op.description:
        out.append(normalize_markdown(op.description))
        out.append("")

    if op.params:
        out.append(f"## {s['params']}")
        out.append("")
        out.append(
            f"| {s['p_name']} | {s['p_in']} | {s['p_type']} | {s['p_required']} | {s['p_desc']} |"
        )
        out.append("| --- | --- | --- | --- | --- |")
        for p in op.params:
            out.append(
                f"| `{p.name}` | {p.location} | `{p.type}` | "
                f"{s['yes'] if p.required else s['no']} | {esc_cell(p.description)} |"
            )
        out.append("")

    if op.body_schema:
        out.append(f"## {s['body']}")
        out.append("")
        out.append(
            s["body_line"].format(
                type=op.body_type or "application/json",
                schema=op.body_schema,
                req=s["body_req"] if op.body_required else s["body_opt"],
            )
        )
        out.append("")

    if op.responses:
        out.append(f"## {s['responses']}")
        out.append("")
        out.append(f"| {s['r_code']} | {s['r_desc']} | {s['r_schema']} |")
        out.append("| --- | --- | --- |")
        for r in op.responses:
            schema = f"`{r.schema}`" if r.schema else "—"
            out.append(f"| `{r.code}` | {esc_cell(r.description)} | {schema} |")
        out.append("")

    out.append(f"## {s['examples']}")
    out.append("")
    examples = render_examples(root, op, index, locale)
    if examples:
        out.append(s["examples_lede"])
        out.append("")
        out.append("::: code-group")
        out.append("")
        out.extend(examples)
        out.append(":::")
    else:
        out.append(f"::: warning\n{s['no_examples']}\n:::")
    out.append("")

    return "\n".join(out).rstrip() + "\n"


def render_module_index(module: Module, locale: str) -> str:
    s = STRINGS[locale]
    out: list[str] = []

    out.append("---")
    out.append(f"title: {yaml_quote(module.title)}")
    out.append(
        "description: "
        + yaml_quote(s["op_count"].format(slug=module.slug, n=len(module.operations)))
    )
    out.append("---")
    out.append("")
    out.append(f"# {module.title} · `{module.slug}`")
    out.append("")
    out.append(s["op_count"].format(slug=module.slug, n=len(module.operations)))
    out.append("")
    out.append(
        f"[{s['spec_docs']} ↗]({WB_DOCS}/{module.portal}) · "
        f"[{s['back']}]({base_path(locale)}/)"
    )
    out.append("")

    if module.description:
        out.append(normalize_markdown(module.description))
        out.append("")

    by_tag: dict[str, list[Operation]] = {}
    for op in module.operations:
        by_tag.setdefault(op.tag, []).append(op)

    for tag, ops in by_tag.items():
        if tag:
            out.append(f"## {tag}")
            out.append("")
        out.append(f"| {s['method']} | {s['path']} | {s['operation']} |")
        out.append("| --- | --- | --- |")
        for op in ops:
            link = f"{base_path(locale)}/{module.slug}/{op.page}"
            out.append(
                f"| `{op.method}` | `{op.path}` | [{esc_cell(op.summary)}]({link}) |"
            )
        out.append("")

    return "\n".join(out).rstrip() + "\n"


def render_section_index(modules: list[Module], locale: str) -> str:
    s = STRINGS[locale]
    total = sum(len(m.operations) for m in modules)
    out: list[str] = []

    out.append("---")
    out.append(f"title: {yaml_quote(s['section'])}")
    out.append(
        "description: " + yaml_quote(s["section_lede"].format(n=total, m=len(modules)))
    )
    out.append("---")
    out.append("")
    out.append(f"# {s['section']}")
    out.append("")
    out.append(s["section_lede"].format(n=total, m=len(modules)))
    out.append("")
    out.append(f"| {s['module']} | {s['category']} | {s['ops']} |")
    out.append("| --- | --- | --- |")
    for m in modules:
        out.append(
            f"| [`{m.slug}`]({base_path(locale)}/{m.slug}/) | {esc_cell(m.title)} | "
            f"{len(m.operations)} |"
        )
    out.append("")

    return "\n".join(out).rstrip() + "\n"


def render_sidebar(modules: list[Module]) -> str:

    def items(locale: str):
        groups = [{"text": STRINGS[locale]["section"], "link": f"{base_path(locale)}/"}]
        for m in modules:
            groups.append(
                {
                    "text": f"{m.title} · {m.slug}",
                    "collapsed": True,
                    "items": [
                        {
                            "text": op.summary,
                            "link": f"{base_path(locale)}/{m.slug}/{op.page}",
                        }
                        for op in m.operations
                    ],
                }
            )
        return groups

    body = {"ru": items("ru"), "en": items("en")}

    return (
        "// GENERATED by scripts/gen-api-reference.py in\n"
        "// https://github.com/ValeryVerkhoturov/wb-api-client — do not edit.\n"
        "// Sidebar for the endpoint reference: one collapsed group per API\n"
        "// module, one entry per operation.\n\n"
        'import type { DefaultTheme } from "vitepress";\n\n'
        "export const apiSidebar: Record<string, DefaultTheme.SidebarItem[]> =\n"
        + json.dumps(body, ensure_ascii=False, indent=2)
        + ";\n"
    )


def prettier_command(repo: Path) -> list[str]:
    local = repo / "node_modules" / ".bin" / "prettier"
    if local.is_file():
        return [str(local)]

    try:
        manifest = json.loads((repo / "package.json").read_text(encoding="utf-8"))
        pinned = (manifest.get("devDependencies") or {}).get("prettier", "")
    except (OSError, ValueError):
        pinned = ""
    version = pinned.lstrip("^~") or "latest"
    return ["npx", "--yes", f"prettier@{version}"]


def format_with_prettier(repo: Path, targets: list[Path]) -> None:
    cmd = prettier_command(repo) + [
        "--write",
        "--log-level",
        "warn",
        *[str(t.relative_to(repo)) for t in targets],
    ]
    try:
        run(cmd, cwd=repo, check=True)
    except FileNotFoundError:
        sys.stderr.write(
            "prettier not runnable — install Node, or run `npm install` in "
            f"{repo}. The generated pages must match that repo's "
            "`npm run format:check`.\n"
        )
        raise
    except subprocess.CalledProcessError:
        sys.stderr.write(f"prettier failed on the generated tree in {repo}\n")
        raise


def write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def main() -> int:
    if len(sys.argv) != 2:
        sys.stderr.write("usage: gen-api-reference.py <wb-api-client-docs>/docs\n")
        return 2

    root = REPO_ROOT
    docs = Path(sys.argv[1]).resolve()
    if not (docs / ".vitepress").is_dir():
        sys.stderr.write(
            f"{docs} does not look like the docs/ dir of wb-api-client-docs\n"
        )
        return 1

    modules = load_modules(root / "swaggers" / "processed")
    if not modules:
        sys.stderr.write("no processed specs — run post-process.py first\n")
        return 1

    index = build_index(root, modules)

    for locale in ("ru", "en"):
        section = docs / base_path(locale).lstrip("/")
        if section.exists():
            shutil.rmtree(section)

        write(section / "index.md", render_section_index(modules, locale))
        for module in modules:
            write(
                section / module.slug / "index.md", render_module_index(module, locale)
            )
            for op in module.operations:
                write(
                    section / module.slug / f"{op.page}.md",
                    render_operation(root, module, op, index, locale),
                )

    sidebar = docs / ".vitepress" / "api-sidebar.ts"
    write(sidebar, render_sidebar(modules))

    format_with_prettier(
        docs.parent,
        [docs / base_path(loc).lstrip("/") for loc in ("ru", "en")] + [sidebar],
    )

    total = sum(len(m.operations) for m in modules)
    print(f"{total} operations across {len(modules)} modules → {docs}")
    for lang in LANGS:
        found = len(index[lang])
        flag = "" if found == total else f"  ← {total - found} operations not exposed"
        print(f"  {lang:<11} {found:>3}/{total}{flag}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
