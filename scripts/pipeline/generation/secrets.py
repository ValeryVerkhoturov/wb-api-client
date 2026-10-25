#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path

from ..core.naming import JAVA_ROOT_PKG, JAVA_ROOT_PATH


def patch_python_configuration(text: str) -> str:
    if "SecretStr" in text:
        return text

    text = re.sub(
        r"(\s+access_token: Optional\[)str(\]=None,)",
        r"\1Union[str, SecretStr]\2",
        text,
        count=1,
    )

    text = re.sub(
        r"(\n(\s+))self\.access_token = access_token\n",
        (
            r"\1if access_token is not None and not isinstance(access_token, SecretStr):"
            "\n\\2    access_token = SecretStr(access_token)"
            r"\1self.access_token = access_token"
            "\n"
        ),
        text,
        count=1,
    )

    text = re.sub(
        r"'value': 'Bearer ' \+ self\.access_token",
        "'value': 'Bearer ' + self.access_token.get_secret_value()",
        text,
        count=1,
    )

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
    for sub in sorted(
        p for p in pkg.iterdir() if p.is_dir() and not p.name.startswith("_")
    ):
        cfg = sub / "configuration.py"
        if not cfg.exists():
            continue
        cfg.write_text(patch_python_configuration(cfg.read_text()))
        n += 1
    return n


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
    text = re.sub(
        r"(constructor\(param: ConfigurationParameters[^\n]*\{\n(?:.*?\n)*?    \})",
        r"\1\n" + _TS_SETTER,
        text,
        count=1,
    )
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
        '    @Override public String toString() { return "<REDACTED>"; }\n'
        "}\n"
    )


_JAVA_BEARER_DECL = (
    "    public void setBearerToken(String bearerToken) {\n"
    "        setBearerToken(() -> bearerToken);\n"
    "    }\n"
)

_JAVA_BEARER_REPLACEMENT = (
    "    public void setAccessToken(String bearerToken) {\n"
    "        SecretString secret = new SecretString(bearerToken);\n"
    "        setAccessToken(secret::exposeSecret);\n"
    "    }\n"
)

_JAVA_DEAD_OAUTH_SETTER_RE = re.compile(
    r"( *)/\*\*(?:\n\1 \*[^\n]*)*\n\1 \*/\n"
    r"\1public void setAccessToken\(String accessToken\) \{\n"
    r'\1 +throw new RuntimeException\("No OAuth2 authentication configured!"\);\n'
    r"\1\}\n\n?"
)


def patch_java_apiclient(text: str) -> str:
    if "new SecretString(bearerToken)" not in text:
        text = text.replace(_JAVA_BEARER_DECL, _JAVA_BEARER_REPLACEMENT, 1)
    text = _JAVA_DEAD_OAUTH_SETTER_RE.sub("", text)
    return text.replace("setBearerToken", "setAccessToken")


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
        auth = sub / "auth" / "HttpBearerAuth.java"
        if auth.exists():
            auth.write_text(
                auth.read_text().replace("setBearerToken", "setAccessToken")
            )
        n += 1
    return n


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


_PHP_ACCESS_TOKEN_PROPERTY = "    protected $accessToken = '';"
_PHP_ACCESS_TOKEN_PROPERTY_PATCHED = "    protected $accessToken;"
_PHP_ACCESS_TOKEN_SETTER = "        $this->accessToken = $accessToken;"
_PHP_ACCESS_TOKEN_SETTER_PATCHED = (
    "        $this->accessToken = new SecretString($accessToken);"
)
_PHP_ACCESS_TOKEN_GETTER = "        return $this->accessToken;"
_PHP_ACCESS_TOKEN_GETTER_PATCHED = "        return $this->accessToken?->exposeSecret();"


def patch_php_configuration(text: str) -> str:

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

    if _PHP_ACCESS_TOKEN_SETTER_PATCHED.strip() not in text:
        text = text.replace(
            "     * @var string\n     */\n" + _PHP_ACCESS_TOKEN_PROPERTY,
            "     * @var SecretString|null\n     */\n"
            + _PHP_ACCESS_TOKEN_PROPERTY_PATCHED,
            1,
        )
        text = text.replace(
            _PHP_ACCESS_TOKEN_SETTER, _PHP_ACCESS_TOKEN_SETTER_PATCHED, 1
        )
        text = text.replace(
            "     * @return string Access token for OAuth",
            "     * @return string|null Access token for OAuth",
            1,
        )
        text = text.replace(
            _PHP_ACCESS_TOKEN_GETTER, _PHP_ACCESS_TOKEN_GETTER_PATCHED, 1
        )
    return text


def patch_php(root: Path) -> int:
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


_CS_ROOT_NS = "ValeryVerkhoturov.WbApiClient"
_CS_USER_AGENT = "ValeryVerkhoturov/wb-api-client/csharp"


def _csharp_secret_string(ns: str) -> str:
    return (
        "// Generated by scripts/inject-secrets.py. Do not edit.\n"
        "using System;\n\n"
        f"namespace {ns}.Client\n"
        "{\n"
        "    /// <summary>\n"
        "    /// Wraps a secret so it does not leak when the containing object is\n"
        "    /// printed, interpolated or serialized by a logger.\n"
        "    /// </summary>\n"
        "    /// <remarks>\n"
        "    /// ToString() is what makes this work: string interpolation,\n"
        "    /// Console.WriteLine and most logging frameworks go through it.\n"
        "    /// Call ExposeSecret() to get the real value.\n"
        "    /// </remarks>\n"
        "    public sealed class SecretString\n"
        "    {\n"
        "        private readonly string _value;\n\n"
        "        public SecretString(string value)\n"
        "        {\n"
        "            _value = value ?? string.Empty;\n"
        "        }\n\n"
        "        /// <summary>Returns the protected value.</summary>\n"
        "        public string ExposeSecret() => _value;\n\n"
        "        /// <summary>True when no value was supplied.</summary>\n"
        "        public bool IsEmpty => _value.Length == 0;\n\n"
        '        /// <summary>Always "&lt;REDACTED&gt;" — never the value.</summary>\n'
        '        public override string ToString() => "<REDACTED>";\n'
        "    }\n"
        "}\n"
    )


_CS_ACCESS_TOKEN_DECL = "        public virtual string AccessToken { get; set; }"

_CS_ACCESS_TOKEN_REPLACEMENT = """        private SecretString _accessToken = new SecretString(string.Empty);

        /// <summary>
        /// Stores the WB bearer JWT in a redacting wrapper.
        /// </summary>
        /// <remarks>
        /// There is deliberately no getter on Configuration: the token leaves
        /// the wrapper only through the explicit IReadableConfiguration member
        /// that the generated Api classes consume internally.
        /// </remarks>
        /// <param name="token">The access token.</param>
        public virtual void SetAccessToken(string token)
        {
            _accessToken = new SecretString(token ?? string.Empty);
        }

        string IReadableConfiguration.AccessToken => _accessToken.ExposeSecret();"""

_CS_MERGE_TOKEN_LINE = (
    "                AccessToken = second.AccessToken ?? first.AccessToken,\n"
)
_CS_MERGE_RETURN = "            };\n            return config;"
_CS_MERGE_RETURN_PATCHED = (
    "            };\n"
    "            config.SetAccessToken(second.AccessToken ?? first.AccessToken);\n"
    "            return config;"
)


def patch_csharp_configuration(text: str) -> str:
    if (
        "public virtual void SetAccessToken(" not in text
        and _CS_ACCESS_TOKEN_DECL in text
    ):
        text = text.replace(_CS_ACCESS_TOKEN_DECL, _CS_ACCESS_TOKEN_REPLACEMENT, 1)
        text = text.replace(_CS_MERGE_TOKEN_LINE, "", 1)
        text = text.replace(_CS_MERGE_RETURN, _CS_MERGE_RETURN_PATCHED, 1)

    text = re.sub(
        r'UserAgent = WebUtility\.UrlEncode\("[^"]*"\);',
        f'UserAgent = "{_CS_USER_AGENT}";',
        text,
        count=1,
    )
    return text


_CS_SHADOWED_LOOP_RE = re.compile(
    r"foreach \(var (?P<name>[A-Za-z_][A-Za-z0-9_]*) in (?P=name)\)"
    r"(?P<gap>\s*\{)(?P<body>.*?)(?P<close>\n\s*\})",
    re.DOTALL,
)


def _rename_outside_strings(text: str, old: str, new: str) -> str:
    out = []
    for index, chunk in enumerate(re.split(r'("(?:[^"\\]|\\.)*")', text)):
        if index % 2 == 0:
            chunk = re.sub(rf"\b{re.escape(old)}\b", new, chunk)
        out.append(chunk)
    return "".join(out)


def fix_csharp_shadowed_loops(text: str) -> str:
    def rewrite(match: "re.Match[str]") -> str:
        name = match.group("name")
        item = f"{name}Item"
        body = _rename_outside_strings(match.group("body"), name, item)
        return (
            f"foreach (var {item} in {name})"
            f"{match.group('gap')}{body}{match.group('close')}"
        )

    return _CS_SHADOWED_LOOP_RE.sub(rewrite, text)


_CS_BYTE_ARRAY_EXAMPLE_RE = re.compile(
    r"^[ \t]*/\*\n[ \t]*<example>\[B@[0-9a-f]+</example>\n[ \t]*\*/\n",
    re.MULTILINE,
)


def patch_csharp(root: Path) -> int:
    src = root / "src"
    if not src.is_dir():
        return 0

    n = 0
    for sub in sorted(p for p in src.iterdir() if p.is_dir()):
        ns = f"{_CS_ROOT_NS}.{sub.name}"
        client = sub / "Client"
        if not client.is_dir():
            continue
        (client / "SecretString.cs").write_text(_csharp_secret_string(ns))
        config = client / "Configuration.cs"
        if config.exists():
            config.write_text(patch_csharp_configuration(config.read_text()))

        for source in (
            sorted((sub / "Api").glob("*.cs")) if (sub / "Api").is_dir() else []
        ):
            text = source.read_text()
            fixed = fix_csharp_shadowed_loops(text)
            if fixed != text:
                source.write_text(fixed)

        for source in (
            sorted((sub / "Model").glob("*.cs")) if (sub / "Model").is_dir() else []
        ):
            text = source.read_text()
            fixed = _CS_BYTE_ARRAY_EXAMPLE_RE.sub("", text)
            if fixed != text:
                source.write_text(fixed)
        n += 1
    return n


_RUST_SECRET_STRING = """/// Wrapper around a bearer JWT that redacts under Debug and Display.
/// Call [`SecretString::expose_secret`] to get the raw value — deliberately
/// awkward so accidental leaks (logs, `println!("{:?}", config)`) become explicit.
#[derive(Clone)]
pub struct SecretString(String);

impl SecretString {
    pub fn new<S: Into<String>>(value: S) -> Self {
        SecretString(value.into())
    }

    pub fn expose_secret(&self) -> &str {
        &self.0
    }
}

impl std::fmt::Debug for SecretString {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str("<REDACTED>")
    }
}

impl std::fmt::Display for SecretString {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str("<REDACTED>")
    }
}

"""

_RUST_SETTER = """
    /// Store the WB bearer JWT wrapped in a [`SecretString`] so it redacts
    /// under Debug/Display; the raw value leaves only via `expose_secret()`.
    pub fn set_access_token(&mut self, token: &str) {
        self.bearer_access_token = Some(SecretString::new(token));
    }
"""


def patch_rust_configuration(text: str) -> str:
    if "pub struct SecretString" not in text:
        text = re.sub(
            r"(#\[derive\(Debug, Clone\)\]\npub struct Configuration \{)",
            _RUST_SECRET_STRING + r"\1",
            text,
            count=1,
        )
        text = text.replace(
            "pub bearer_access_token: Option<String>,",
            "pub bearer_access_token: Option<SecretString>,",
            1,
        )
        text = re.sub(
            r"(impl Configuration \{\n    pub fn new\(\) -> Configuration \{\n"
            r"        Configuration::default\(\)\n    \}\n)",
            r"\1" + _RUST_SETTER,
            text,
            count=1,
        )

    text = re.sub(
        r'user_agent: Some\("OpenAPI-Generator/[^"]*"\.to_owned\(\)\)',
        'user_agent: Some("ValeryVerkhoturov/wb-api-client/rust".to_owned())',
        text,
        count=1,
    )
    return text


def patch_rust_api(text: str) -> str:
    return text.replace(
        ".bearer_auth(local_var_token.to_owned())",
        ".bearer_auth(local_var_token.expose_secret())",
    )


def patch_rust(root: Path) -> int:
    src = root / "src"
    if not src.is_dir():
        return 0
    n = 0
    for sub in sorted(p for p in src.iterdir() if p.is_dir()):
        apis = sub / "apis"
        if not apis.is_dir():
            continue
        cfg = apis / "configuration.rs"
        if cfg.exists():
            cfg.write_text(patch_rust_configuration(cfg.read_text()))
        for source in sorted(apis.glob("*.rs")):
            if source.name in ("configuration.rs", "mod.rs"):
                continue
            text = source.read_text()
            patched = patch_rust_api(text)
            if patched != text:
                source.write_text(patched)
        n += 1
    return n


def main() -> int:
    if len(sys.argv) != 2:
        sys.stderr.write("usage: inject-secrets.py <clients dir>\n")
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
    cs = patch_csharp(clients / "csharp")
    print(f"  patched {cs} C# sub-namespaces    (SecretString class)")
    rs = patch_rust(clients / "rust")
    print(f"  patched {rs} Rust modules         (SecretString struct)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
