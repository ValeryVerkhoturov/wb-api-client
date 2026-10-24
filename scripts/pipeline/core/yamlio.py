"""ruamel.yaml setup, guarded — the three old copies drifted in options."""

import sys

try:
    from ruamel.yaml import YAML
except ImportError:  # pragma: no cover - installed via requirements.txt
    sys.stderr.write(
        "ruamel.yaml is required. Install with `pip install ruamel.yaml`.\n"
    )
    raise


def round_trip_yaml() -> YAML:
    """For specs that get loaded and dumped back (post-process, readmes).

    Preserves ordering, comments and quotes; the wide column limit avoids
    line wrapping that fights with git diffs.
    """
    yaml = YAML()
    yaml.preserve_quotes = True
    yaml.width = 4096
    return yaml


def safe_yaml() -> YAML:
    """Load-only parsing (docs rendering) — no arbitrary-object tags."""
    yaml = YAML(typ="safe")
    yaml.width = 4096
    return yaml
