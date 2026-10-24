import hashlib
import sys
import time
from pathlib import Path

import requests

from ..core.paths import SWAGGER_DIR

BASE_URL = "https://gitlab.com/ValeryVerkhoturov/wb-api-client-specs/-/raw/main/specs"
SPECS = (
    "01-general.yaml",
    "02-items.yaml",
    "03-orders-fbs.yaml",
    "04-orders-dbw.yaml",
    "05-dbs.yaml",
    "06-in-store-pickup.yaml",
    "07-orders-fbw.yaml",
    "08-promotion.yaml",
    "09-communications.yaml",
    "10-rates.yaml",
    "11-analytics.yaml",
    "12-reports.yaml",
    "13-finances.yaml",
)

LOCALES = {"ru": SWAGGER_DIR / "ru", "en": SWAGGER_DIR / "en"}


def fetch(url: str, target: Path) -> None:
    for attempt in range(4):
        try:
            response = requests.get(url)
        except requests.RequestException:
            if attempt == 3:
                raise
        else:
            with response:
                retryable = response.status_code in (408, 429, 500, 502, 503, 504)
                if not retryable or attempt == 3:
                    response.raise_for_status()
                    target.write_bytes(response.content)
                    return
        time.sleep(2)


def write_checksums(out_dir: Path) -> None:
    checksums = []
    for path in sorted(out_dir.glob("*.yaml"), key=lambda item: item.name):
        if path.is_file():
            digest = hashlib.sha256(path.read_bytes()).hexdigest()
            checksums.append(f"{digest}  {path.name}\n")
    (out_dir / "checksums.txt").write_bytes("".join(checksums).encode("utf-8"))


def main() -> None:
    sys.stdout.reconfigure(line_buffering=True)
    for locale, out_dir in LOCALES.items():
        out_dir.mkdir(parents=True, exist_ok=True)
        base = f"{BASE_URL}/{locale}"
        print(f"Downloading {len(SPECS)} {locale} specs from {base}")
        for spec in SPECS:
            print(f"  → {spec}")
            fetch(f"{base}/{spec}", out_dir / spec)
        write_checksums(out_dir)
        print(f"Done. Manifest: {out_dir / 'checksums.txt'}")


if __name__ == "__main__":
    main()
