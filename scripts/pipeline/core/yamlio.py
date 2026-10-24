import sys

try:
    from ruamel.yaml import YAML
except ImportError:
    sys.stderr.write(
        "ruamel.yaml is required. Install with `pip install ruamel.yaml`.\n"
    )
    raise


def round_trip_yaml() -> YAML:
    yaml = YAML()
    yaml.preserve_quotes = True
    yaml.width = 4096
    return yaml


def safe_yaml() -> YAML:
    yaml = YAML(typ="safe")
    yaml.width = 4096
    return yaml
