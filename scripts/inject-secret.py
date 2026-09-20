#!/usr/bin/env python3
"""Post-process every generated language client so the WB bearer JWT is
stored on `Configuration` (or `ApiClient` in Java) wrapped in a
"secret-string" type that redacts under log/print unless the caller
explicitly asks for the raw value. Same ergonomics across all four
languages.

Per-language mechanism:

  Python  — pydantic.SecretStr wraps the token; `__init__` normalizes a
            plain str to SecretStr; the `auth_settings()` block unwraps
            with `.get_secret_value()` when building the header.
  TS      — a small `SecretString` class inlined in configuration.ts,
            plus `Configuration.setAccessToken(token)` which stores the
            SecretString and wires `this.accessToken` to a callback
            returning `secret.exposeSecret()`. The generated request
            builder already invokes the callback at request time.
  Go      — Configuration gains an `AccessToken *secrecy.SecretString`
            field (github.com/negrel/secrecy) plus a
            `SetAccessToken(token string)` setter; the request builder
            reads it via `.ExposeSecret()`.
  Java    — a small `SecretString` class per sub-module; `ApiClient`
            gains a `setBearerToken(SecretString)` overload that binds
            to the existing `Supplier<String>` path with
            `secret::exposeSecret`.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

JAVA_ROOT_PKG = "io.github.valeryverkhoturov.wbapi"
JAVA_ROOT_PATH = "io/github/valeryverkhoturov/wbapi"


# ────────── Python ──────────

def patch_python_configuration(text: str) -> str:
    if "SecretStr" in text:
        return text

    # Widen the type hint on the __init__ parameter.
    text = re.sub(
        r"(\s+access_token: Optional\[)str(\]=None,)",
        r"\1Union[str, SecretStr]\2",
        text,
        count=1,
    )

    # Wrap a plain string on assignment so the field is always SecretStr.
    text = re.sub(
        r"(\n(\s+))self\.access_token = access_token\n",
        (
            r"\1if access_token is not None and not isinstance(access_token, SecretStr):"
            "\n\\2    access_token = SecretStr(access_token)"
            r"\1self.access_token = access_token" "\n"
        ),
        text,
        count=1,
    )

    # Unwrap when composing the Authorization header.
    text = re.sub(
        r"'value': 'Bearer ' \+ self\.access_token",
        "'value': 'Bearer ' + self.access_token.get_secret_value()",
        text,
        count=1,
    )

    # Imports: add Union to typing if missing, add pydantic SecretStr.
    text = re.sub(
        r"^(from typing import [^\n]+)$",
        lambda m: m.group(1) if "Union" in m.group(1) else m.group(1) + ", Union",
        text,
        count=1,
        flags=re.M,
    )
    if "from pydantic import SecretStr" not in text:
        text = re.sub(
            r"^(from typing_extensions [^\n]+\n)",
            r"\1from pydantic import SecretStr\n",
            text,
            count=1,
            flags=re.M,
        )
    return text


def patch_python(root: Path) -> int:
    n = 0
    pkg = root / "wb_api_client"
    if not pkg.is_dir():
        return 0
    for sub in sorted(p for p in pkg.iterdir() if p.is_dir() and not p.name.startswith("_")):
        cfg = sub / "configuration.py"
        if not cfg.exists():
            continue
        cfg.write_text(patch_python_configuration(cfg.read_text()))
        n += 1
    return n


# ────────── TypeScript ──────────

_TS_SECRET_CLASS = """/**
 * Small wrapper around a string that hides its value under console.log,
 * util.inspect, and template literals. Call {@link exposeSecret} to get
 * the raw value — this is intentionally a friction point so that leaks
 * become explicit.
 */
export class SecretString {
    private readonly _value: string;
    constructor(value: string) { this._value = value; }
    exposeSecret(): string { return this._value; }
    toString(): string { return "<REDACTED>"; }
    toJSON(): string { return "<REDACTED>"; }
    [Symbol.for("nodejs.util.inspect.custom")](): string { return "<REDACTED>"; }
}

"""

_TS_SETTER = """
    /**
     * Store the WB bearer JWT on this Configuration wrapped in a
     * {@link SecretString} so it redacts under logs, and wire the
     * accessToken field to a callback that {@link SecretString.exposeSecret}s
     * the value at request time.
     */
    setAccessToken(token: string): void {
        const secret = new SecretString(token);
        this.accessToken = () => secret.exposeSecret();
    }
"""


def patch_typescript_configuration(text: str) -> str:
    if "class SecretString" in text:
        return text

    text = re.sub(
        r"(export class Configuration \{)",
        _TS_SECRET_CLASS + r"\1",
        text,
        count=1,
    )
    # Insert setAccessToken() right after the constructor body's closing
    # brace. Anchor on the constructor signature line, then match its
    # body up to the first line that is exactly `    }` — the constructor's
    # end at 4-space indent.
    text = re.sub(
        r"(constructor\(param: ConfigurationParameters[^\n]*\{\n(?:.*?\n)*?    \})",
        r"\1\n" + _TS_SETTER,
        text,
        count=1,
    )
    # Seed a default User-Agent on baseOptions. openapi-generator's
    # typescript-axios template doesn't accept `httpUserAgent` like the
    # other generators do, so we inject it here. Caller-supplied
    # baseOptions.headers still win via spread order below.
    text = re.sub(
        r"(this\.baseOptions = param\.baseOptions;)",
        r"""\1
        this.baseOptions = {
            ...this.baseOptions,
            headers: {
                "User-Agent": "ValeryVerkhoturov/wb-api-client/typescript",
                ...this.baseOptions?.headers,
            },
        };""",
        text,
        count=1,
    )
    return text


def patch_typescript(root: Path) -> int:
    n = 0
    src = root / "src"
    if not src.is_dir():
        return 0
    for sub in sorted(p for p in src.iterdir() if p.is_dir()):
        cfg = sub / "configuration.ts"
        if not cfg.exists():
            continue
        cfg.write_text(patch_typescript_configuration(cfg.read_text()))
        n += 1
    return n


# ────────── Go ──────────

SECRECY_IMPORT = '\t"github.com/negrel/secrecy"'


def patch_go_configuration(text: str) -> str:
    if "github.com/negrel/secrecy" not in text:
        text = re.sub(
            r'(import \((?:\n\t"[^"]+")+)\n\)',
            lambda m: m.group(1) + "\n\n" + SECRECY_IMPORT + "\n)",
            text,
            count=1,
        )

    if "*secrecy.SecretString" not in text:
        text = re.sub(
            r"(type Configuration struct \{\n)",
            r'\1\tAccessToken      *secrecy.SecretString `json:"-"`' + "\n",
            text,
            count=1,
        )

    if "func (c *Configuration) SetAccessToken(" not in text:
        text += (
            "\n"
            "// SetAccessToken stores the WB bearer JWT on the Configuration,\n"
            "// wrapped in a secrecy.SecretString so it redacts under fmt/log.\n"
            "func (c *Configuration) SetAccessToken(token string) {\n"
            "\ts := secrecy.NewSecretString([]byte(token))\n"
            "\tc.AccessToken = &s\n"
            "}\n"
        )

    text = re.sub(
        r"\n\t// ContextAccessToken takes[^\n]*\n"
        r"\tContextAccessToken = contextKey\(\"accesstoken\"\)\n",
        "\n",
        text,
        count=1,
    )
    return text


_GO_AUTH_BLOCK_RE = re.compile(
    r"(\t{2,3})// AccessToken Authentication\n"
    r"\1if auth, ok := ctx\.Value\(ContextAccessToken\)\.\(string\); ok \{\n"
    r"\1\tlocalVarRequest\.Header\.Add\(\"Authorization\", \"Bearer \"\+auth\)\n"
    r"\1\}\n"
)


def patch_go_client(text: str) -> str:
    def replace(m: re.Match) -> str:
        indent = m.group(1)
        return (
            f"{indent}// AccessToken Authentication — sourced from\n"
            f"{indent}// c.cfg.AccessToken (a secrecy.SecretString) only.\n"
            f"{indent}if c.cfg.AccessToken != nil {{\n"
            f'{indent}\tlocalVarRequest.Header.Add("Authorization", "Bearer "+c.cfg.AccessToken.ExposeSecret())\n'
            f"{indent}}}\n"
        )
    return _GO_AUTH_BLOCK_RE.sub(replace, text)


def patch_go(root: Path) -> int:
    n = 0
    for sub in sorted(p for p in root.iterdir() if p.is_dir()):
        cfg = sub / "configuration.go"
        cli = sub / "client.go"
        if cfg.exists():
            cfg.write_text(patch_go_configuration(cfg.read_text()))
        if cli.exists():
            cli.write_text(patch_go_client(cli.read_text()))
        n += 1
    return n


# ────────── Java ──────────

def _java_secret_string(pkg: str) -> str:
    return (
        f"package {pkg};\n"
        "\n"
        "/**\n"
        " * Wrapper around a bearer JWT that redacts under toString().\n"
        " * Use {@link #exposeSecret} to get the raw value — deliberately\n"
        " * awkward so accidental leaks become explicit.\n"
        " */\n"
        "public final class SecretString {\n"
        "    private final String value;\n"
        "\n"
        "    public SecretString(String value) { this.value = value; }\n"
        "\n"
        "    public String exposeSecret() { return value; }\n"
        "\n"
        "    @Override public String toString() { return \"<REDACTED>\"; }\n"
        "}\n"
    )


_JAVA_APICLIENT_INSERT = (
    "\n"
    "    /**\n"
    "     * Store the WB bearer JWT wrapped in a {@link SecretString} so it\n"
    "     * redacts under toString(). Internally binds to the existing\n"
    "     * Supplier&lt;String&gt; path via secret::exposeSecret.\n"
    "     */\n"
    "    public void setBearerToken(SecretString bearerToken) {\n"
    "        setBearerToken(bearerToken::exposeSecret);\n"
    "    }\n"
)


def patch_java_apiclient(text: str) -> str:
    if "setBearerToken(SecretString" in text:
        return text
    text = re.sub(
        r"(public void setBearerToken\(String bearerToken\) \{\n"
        r"        setBearerToken\(\(\) -> bearerToken\);\n"
        r"    \}\n)",
        r"\1" + _JAVA_APICLIENT_INSERT,
        text,
        count=1,
    )
    return text


def patch_java(root: Path) -> int:
    n = 0
    base = root / "src/main/java" / JAVA_ROOT_PATH
    if not base.is_dir():
        return 0
    for sub in sorted(p for p in base.iterdir() if p.is_dir()):
        pkg = f"{JAVA_ROOT_PKG}.{sub.name}"
        (sub / "SecretString.java").write_text(_java_secret_string(pkg))
        api = sub / "ApiClient.java"
        if api.exists():
            api.write_text(patch_java_apiclient(api.read_text()))
        n += 1
    return n


# ────────── PHP ──────────

_PHP_ROOT_NS = "ValeryVerkhoturov\\WbApiClient"


def _php_secret_string(ns: str) -> str:
    return (
        "<?php\n"
        "\n"
        f"namespace {ns};\n"
        "\n"
        "/**\n"
        " * Wrapper around a bearer JWT that redacts under __toString().\n"
        " * Use exposeSecret() to get the raw value — deliberately awkward\n"
        " * so accidental leaks (var_dump/print_r/log) become explicit.\n"
        " */\n"
        "final class SecretString\n"
        "{\n"
        "    private string $value;\n"
        "\n"
        "    public function __construct(string $value)\n"
        "    {\n"
        "        $this->value = $value;\n"
        "    }\n"
        "\n"
        "    public function exposeSecret(): string\n"
        "    {\n"
        "        return $this->value;\n"
        "    }\n"
        "\n"
        "    public function __toString(): string\n"
        "    {\n"
        "        return '<REDACTED>';\n"
        "    }\n"
        "\n"
        "    public function __debugInfo(): array\n"
        "    {\n"
        "        return ['value' => '<REDACTED>'];\n"
        "    }\n"
        "}\n"
    )


_PHP_SETTER_METHOD = """
    /**
     * Store the WB bearer JWT wrapped in a {@link SecretString} so it
     * redacts under __toString/var_dump. Internally forwards to
     * setAccessToken() with the exposed value.
     */
    public function setAccessTokenSecret(SecretString $secret): self
    {
        $this->setAccessToken($secret->exposeSecret());
        return $this;
    }
"""


def patch_php_configuration(text: str) -> str:
    """Inject a setAccessTokenSecret() method on the generated
    Configuration class, and replace the User-Agent default with our
    ValeryVerkhoturov/wb-api-client/php string (openapi-generator's PHP
    template doesn't accept the `httpUserAgent` config option like the
    other language generators do)."""

    # 1. User-Agent default. Both the property default and the docstring
    # get updated so the type inspection stays honest.
    text = re.sub(
        r"protected \$userAgent = 'OpenAPI-Generator/[^']*';",
        "protected $userAgent = 'ValeryVerkhoturov/wb-api-client/php';",
        text,
        count=1,
    )
    text = re.sub(
        r'User agent of the HTTP request, set to "OpenAPI-Generator/\{version\}/PHP" by default',
        'User agent of the HTTP request, set to "ValeryVerkhoturov/wb-api-client/php" by default',
        text,
        count=1,
    )

    # 2. setAccessTokenSecret setter (idempotent).
    if "setAccessTokenSecret" not in text:
        text = re.sub(
            r"(\n})\s*\Z",
            _PHP_SETTER_METHOD + r"\1",
            text,
        )
    return text


def patch_php(root: Path) -> int:
    """Drop SecretString.php into every sub-module and patch its
    Configuration to add setAccessTokenSecret()."""
    n = 0
    src = root / "src"
    if not src.is_dir():
        return 0
    for sub in sorted(p for p in src.iterdir() if p.is_dir()):
        ns = f"{_PHP_ROOT_NS}\\{sub.name}"
        (sub / "SecretString.php").write_text(_php_secret_string(ns))
        cfg = sub / "Configuration.php"
        if cfg.exists():
            cfg.write_text(patch_php_configuration(cfg.read_text()))
        n += 1
    return n


# ────────── entry point ──────────

def main() -> int:
    if len(sys.argv) != 2:
        sys.stderr.write("usage: inject-secret.py <clients dir>\n")
        return 2
    clients = Path(sys.argv[1]).resolve()
    if not clients.is_dir():
        sys.stderr.write(f"not a dir: {clients}\n")
        return 1

    py = patch_python(clients / "python")
    print(f"  patched {py} Python sub-modules   (SecretStr via pydantic)")
    ts = patch_typescript(clients / "typescript")
    print(f"  patched {ts} TypeScript sub-modules (SecretString class)")
    go = patch_go(clients / "go")
    print(f"  patched {go} Go sub-packages       (secrecy.SecretString)")
    ja = patch_java(clients / "java")
    print(f"  patched {ja} Java sub-modules      (SecretString class)")
    ph = patch_php(clients / "php")
    print(f"  patched {ph} PHP sub-modules       (SecretString class)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
