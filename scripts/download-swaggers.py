#!/usr/bin/env python3
"""Download the Wildberries OpenAPI specifications and write their checksums."""

import hashlib
import sys
import time
from pathlib import Path

import requests

REPO_ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = REPO_ROOT / "swaggers"
BASE_URL = "https://gitlab.com/ValeryVerkhoturov/wb-api-client-specs/-/raw/main/specs/ru"
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


def main() -> None:
    sys.stdout.reconfigure(line_buffering=True)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    print(f"Downloading {len(SPECS)} specs from {BASE_URL}")
    for spec in SPECS:
        print(f"  → {spec}")
        for attempt in range(4):
            try:
                response = requests.get(f"{BASE_URL}/{spec}")
            except requests.RequestException:
                if attempt == 3:
                    raise
            else:
                with response:
                    retryable = response.status_code in (408, 429, 500, 502, 503, 504)
                    if not retryable or attempt == 3:
                        response.raise_for_status()
                        (OUT_DIR / spec).write_bytes(response.content)
                        break
            time.sleep(2)

    checksums = []
    for path in sorted(OUT_DIR.glob("*.yaml"), key=lambda item: item.name):
        if path.is_file():
            digest = hashlib.sha256(path.read_bytes()).hexdigest()
            checksums.append(f"{digest}  {path.name}\n")
    (OUT_DIR / "checksums.txt").write_bytes("".join(checksums).encode("utf-8"))
    print(f"Done. Manifest: {OUT_DIR / 'checksums.txt'}")


if __name__ == "__main__":
    main()
