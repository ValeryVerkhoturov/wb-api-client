"""Compile-check every OneScript module and verify package loading."""

import os
import subprocess
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

from ..core.paths import CLIENTS_DIR
from .toolchain import ensure_onescript


def check_file(binary: Path, source: Path) -> str:
    result = subprocess.run(
        [binary, "-check", source],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        encoding="utf-8",
        errors="replace",
    )
    return result.stdout


def main() -> None:
    sys.stdout.reconfigure(line_buffering=True)
    package = Path(sys.argv[1]) if len(sys.argv) > 1 else CLIENTS_DIR / "onescript"
    binary, _ = ensure_onescript()

    if not (package / "src").is_dir():
        sys.stderr.write(f"no OneScript client at {package} — run ./scripts/generate.py first\n")
        raise SystemExit(1)
    package = package.resolve()

    sources = sorted((package / "src").glob("**/*.os"))
    with ThreadPoolExecutor(max_workers=os.cpu_count() or 4) as executor:
        futures = [executor.submit(check_file, binary, source) for source in sources]
        report = "".join(future.result() for future in futures)

    # Keep the existing output-based policy: OneScript diagnostics, not exit codes,
    # determine which files are reported as compile failures.
    failures = [line for line in report.splitlines() if "Ошибка" in line]
    if failures:
        print(f"  ✗ {len(failures)} file(s) failed to compile:")
        print("\n".join(failures[:20]))
        raise SystemExit(1)

    print(f"  ✓ oscript -check passes on all {len(sources)} files")
    with tempfile.TemporaryDirectory(prefix="onescript-load-") as temp_dir:
        loader = Path(temp_dir) / "loader.os"
        loader.write_text(
            f'#Использовать "{package}"\n'
            'Сообщить("  ✓ пакет загружается, Конфигурация доступна: " '
            '+ Строка(ТипЗнч(Новый Конфигурация())));\n',
            encoding="utf-8",
        )
        subprocess.run([binary, loader], check=True)


if __name__ == "__main__":
    main()
