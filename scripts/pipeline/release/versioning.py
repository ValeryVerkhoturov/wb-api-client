import json
import os
import re
import subprocess
import sys

import requests

DEEPSEEK_URL = "https://api.deepseek.com/chat/completions"
DEEPSEEK_MODEL = "deepseek-chat"
DIFF_LIMIT = 60_000
BASELINE = (2, 0, 0)

SYSTEM_PROMPT = (
    "You classify OpenAPI specification diffs by the semantic-versioning impact "
    "they have on client libraries generated from the spec.\n"
    'Answer with JSON only: {"bump": "major"|"minor"|"patch", "reason": "<one short sentence>"}.\n'
    "Rules:\n"
    "- major: removed or renamed paths, operations, parameters, schemas or fields; "
    "narrowed types; new required fields; removed enum values; changed response "
    "semantics — anything that breaks existing consumer code.\n"
    "- minor: added paths, operations, optional parameters or fields, schemas, "
    "enum values; deprecations — backward-compatible functionality.\n"
    "- patch: description, example or typo fixes; non-semantic reordering — "
    "no functional change at all."
)

VERSION_TAG_RE = re.compile(r"^v(\d+)\.(\d+)\.(\d+)$")


def git(*args: str) -> str:
    return subprocess.run(
        ["git", *args], capture_output=True, text=True, check=True
    ).stdout


def latest_version(tags: list[str]) -> tuple[int, int, int] | None:
    versions = [
        tuple(int(g) for g in m.groups())
        for tag in tags
        if (m := VERSION_TAG_RE.match(tag)) and int(m.group(1)) >= BASELINE[0]
    ]
    return max(versions) if versions else None


def bump(version: tuple[int, int, int], kind: str) -> tuple[int, int, int]:
    major, minor, patch = version
    if kind == "major":
        return (major + 1, 0, 0)
    if kind == "minor":
        return (major, minor + 1, 0)
    return (major, minor, patch + 1)


def spec_diff() -> str:
    return git("diff", "HEAD", "--", "specs/unprocessed/ru")[:DIFF_LIMIT]


def classify(diff: str) -> str:
    if not diff.strip():
        return "patch"
    key = os.environ.get("DEEPSEEK_API_KEY")
    if not key:
        print("DEEPSEEK_API_KEY not set — defaulting bump to minor", file=sys.stderr)
        return "minor"
    try:
        response = requests.post(
            DEEPSEEK_URL,
            headers={"Authorization": f"Bearer {key}"},
            json={
                "model": DEEPSEEK_MODEL,
                "messages": [
                    {"role": "system", "content": SYSTEM_PROMPT},
                    {"role": "user", "content": diff},
                ],
                "response_format": {"type": "json_object"},
                "temperature": 0,
            },
            timeout=60,
        )
        response.raise_for_status()
        content = response.json()["choices"][0]["message"]["content"]
        payload = json.loads(content)
        kind = str(payload["bump"]).strip().lower()
        print(f"DeepSeek: {payload.get('reason', kind)}", file=sys.stderr)
    except Exception as exc:
        print(f"DeepSeek classification failed ({exc}) — defaulting to minor", file=sys.stderr)
        return "minor"
    if kind not in ("major", "minor", "patch"):
        print(f"DeepSeek returned {kind!r} — defaulting to minor", file=sys.stderr)
        return "minor"
    return kind


def next_version(tags: list[str], diff: str) -> tuple[str, str]:
    prev = latest_version(tags)
    if prev is None:
        return "baseline", ".".join(str(n) for n in BASELINE)
    kind = classify(diff)
    return kind, ".".join(str(n) for n in bump(prev, kind))


def main() -> int:
    kind, version = next_version(git("tag", "--list", "v*.*.*").split(), spec_diff())
    print(f"bump={kind}")
    print(f"version={version}")
    print(f"tag=v{version}")
    return 0
