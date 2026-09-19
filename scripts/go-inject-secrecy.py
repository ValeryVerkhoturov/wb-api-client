#!/usr/bin/env python3
"""Post-process each generated Go sub-package to move the WB bearer token
from a context.Value onto the Configuration struct, wrapped in
`github.com/negrel/secrecy` for accidental-log protection.

Openapi-generator's Go template emits:
    // AccessToken Authentication
    if auth, ok := ctx.Value(ContextAccessToken).(string); ok {
        localVarRequest.Header.Add("Authorization", "Bearer "+auth)
    }

We patch each sub-package to read `c.cfg.AccessToken` instead and drop
the `ContextAccessToken` var entirely — a single, obvious place to set
the token. The token field itself is a `*secrecy.SecretString`, which
redacts under fmt/log unless the caller explicitly `.ExposeSecret()`s it.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

SECRECY_IMPORT = '\t"github.com/negrel/secrecy"'


def patch_configuration(text: str) -> str:
    # 1. Add secrecy import if missing.
    if "github.com/negrel/secrecy" not in text:
        # Anchor on the last stdlib import line inside the `import (...)`
        # block, then append secrecy on a new line, separated by a blank
        # line — matches the Go convention of grouping stdlib vs third-party.
        text = re.sub(
            r'(import \((?:\n\t"[^"]+")+)\n\)',
            lambda m: m.group(1) + "\n\n" + SECRECY_IMPORT + "\n)",
            text,
            count=1,
        )

    # 2. Insert AccessToken field at the top of the Configuration struct.
    # Guard against the substring "AccessToken " also appearing inside
    # `ContextAccessToken ` — check for the exact field declaration instead.
    if "*secrecy.SecretString" not in text:
        text = re.sub(
            r"(type Configuration struct \{\n)",
            r'\1\tAccessToken      *secrecy.SecretString `json:"-"`' + "\n",
            text,
            count=1,
        )
    # Add a SetAccessToken convenience method — negrel/secrecy's
    # `NewSecretString` takes `[]byte` and returns a value, so wrapping it
    # by hand is fiddly. This setter hides that.
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

    # Remove the ContextAccessToken var declaration + its comment line.
    # Only that specific entry — leave the other Context* vars alone.
    text = re.sub(
        r"\n\t// ContextAccessToken takes[^\n]*\n"
        r"\tContextAccessToken = contextKey\(\"accesstoken\"\)\n",
        "\n",
        text,
        count=1,
    )
    return text


# Matches the 3-line block openapi-generator emits for bearer auth.
_AUTH_BLOCK_RE = re.compile(
    r"(\t{2,3})// AccessToken Authentication\n"
    r"\1if auth, ok := ctx\.Value\(ContextAccessToken\)\.\(string\); ok \{\n"
    r"\1\tlocalVarRequest\.Header\.Add\(\"Authorization\", \"Bearer \"\+auth\)\n"
    r"\1\}\n"
)


def patch_client(text: str) -> str:
    def replace(m: re.Match) -> str:
        indent = m.group(1)
        return (
            f"{indent}// AccessToken Authentication — sourced from\n"
            f"{indent}// c.cfg.AccessToken (a secrecy.SecretString) only.\n"
            f"{indent}if c.cfg.AccessToken != nil {{\n"
            f'{indent}\tlocalVarRequest.Header.Add("Authorization", "Bearer "+c.cfg.AccessToken.ExposeSecret())\n'
            f"{indent}}}\n"
        )
    return _AUTH_BLOCK_RE.sub(replace, text)


def main() -> int:
    if len(sys.argv) != 2:
        sys.stderr.write("usage: go-inject-secrecy.py <clients/go dir>\n")
        return 2
    root = Path(sys.argv[1]).resolve()
    if not root.is_dir():
        sys.stderr.write(f"not a dir: {root}\n")
        return 1

    patched = 0
    for sub in sorted(p for p in root.iterdir() if p.is_dir()):
        cfg = sub / "configuration.go"
        cli = sub / "client.go"
        if cfg.exists():
            cfg.write_text(patch_configuration(cfg.read_text()))
        if cli.exists():
            cli.write_text(patch_client(cli.read_text()))
        patched += 1
    print(f"  patched {patched} Go sub-packages with secrecy-wrapped AccessToken")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
