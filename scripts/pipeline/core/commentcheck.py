import ast
import io
import tokenize
from pathlib import Path

from .paths import REPO_ROOT

SCRIPTS_DIR = REPO_ROOT / "scripts"


def comments_in(path: Path) -> list[str]:
    tokens = tokenize.generate_tokens(
        io.StringIO(path.read_text(encoding="utf-8")).readline
    )
    return [
        f"{path.relative_to(SCRIPTS_DIR)}:{tok.start[0]}: comment: {tok.string}"
        for tok in tokens
        if tok.type == tokenize.COMMENT
        and not (tok.start[0] == 1 and tok.string.startswith("#!"))
    ]


def docstrings_in(path: Path) -> list[str]:
    tree = ast.parse(path.read_text(encoding="utf-8"))
    found = []
    for node in ast.walk(tree):
        if not isinstance(
            node, (ast.Module, ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)
        ):
            continue
        body = getattr(node, "body", [])
        if (
            body
            and isinstance(body[0], ast.Expr)
            and isinstance(body[0].value, ast.Constant)
            and isinstance(body[0].value.value, str)
        ):
            found.append(
                f"{path.relative_to(SCRIPTS_DIR)}:{body[0].lineno}: docstring: "
                f"{body[0].value.value.strip().splitlines()[0][:60]}"
            )
    return found


def main() -> int:
    offenders = []
    for path in sorted(SCRIPTS_DIR.rglob("*.py")):
        if "__pycache__" in path.parts:
            continue
        offenders.extend(comments_in(path))
        offenders.extend(docstrings_in(path))
    if offenders:
        print(
            "no `#` comments or docstrings under scripts/ — the code must speak for itself:"
        )
        print("\n".join(offenders))
        return 1
    print("comment/docstring check: OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
