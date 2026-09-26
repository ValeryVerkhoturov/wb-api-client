#!/usr/bin/env python3
"""Build the unified OneScript package manifests.

openapi-generator emits a standalone opm package per spec, each with its own
``packagedef`` and ``lib.config``. generate.sh splices the 13 trees into one
package, so those per-spec manifests are discarded and replaced by a single
pair built here from ``templates/onescript/``.

Both manifests are a registry of ``class name -> file path``. OneScript
resolves classes only through ``lib.config`` (not by directory convention),
so a class missing from it is invisible to ``Новый`` no matter where the file
sits.

Usage: gen-onescript-manifests.py <repo-root> <version>
"""

import re
import sys
from pathlib import Path

# A class file declares no name of its own — the name comes from the registry,
# and the generator names the file after the class. Guard that assumption so a
# generator change can't silently produce an unreachable class.
CLASS_NAME = re.compile(r"^[^\W\d]\w*$", re.UNICODE)


def collect_classes(src_dir: Path) -> list[tuple[str, str]]:
    """Return (class name, POSIX path relative to the package root) pairs."""
    classes: dict[str, str] = {}

    for path in sorted(src_dir.rglob("*.os")):
        name = path.stem
        if not CLASS_NAME.match(name):
            raise SystemExit(f"not a legal BSL class name: {path}")

        # BSL identifiers are case-insensitive, so two files differing only in
        # case would register as one class and one of them would be silently
        # unreachable.
        key = name.casefold()
        if key in classes:
            raise SystemExit(
                f"class name collision (BSL ignores case): {path} vs {classes[key][1]}"
            )
        classes[key] = (name, path.relative_to(src_dir.parent).as_posix())

    # Sort by name so both manifests are byte-stable across runs: pr-check.yml
    # regenerates and diffs, and rglob order is not guaranteed.
    return sorted(classes.values(), key=lambda row: row[0])


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("usage: gen-onescript-manifests.py <repo-root> <version>")

    repo_root = Path(sys.argv[1]).resolve()
    version = sys.argv[2]

    package = repo_root / "clients" / "onescript"
    templates = repo_root / "templates" / "onescript"

    classes = collect_classes(package / "src")
    if not classes:
        raise SystemExit(f"no .os sources under {package / 'src'}")

    lib_config = "".join(
        f'    <class name="{name}" file="{path}"/>\n' for name, path in classes
    )
    (package / "lib.config").write_text(
        (templates / "lib.config").read_text().replace("__CLASSES__", lib_config),
        encoding="utf-8",
    )

    packagedef = "".join(
        f'\t.ОпределяетКласс("{name}", "{path}")\n' for name, path in classes
    )
    (package / "packagedef").write_text(
        (templates / "packagedef")
        .read_text()
        .replace("__VERSION__", version)
        .replace("__CLASSES__", packagedef.rstrip("\n")),
        encoding="utf-8",
    )

    print(f"  ✓ OneScript manifests: {len(classes)} classes registered")


if __name__ == "__main__":
    main()
