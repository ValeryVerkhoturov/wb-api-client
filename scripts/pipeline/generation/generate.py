import os
import shutil
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

from ..core.docker import docker_run
from ..core.naming import JAVA_ROOT_PATH as JAVA_GROUP_PATH
from ..core.naming import module_slug, pascal_from_snake
from ..core.paths import CLIENTS_DIR, CONFIG_DIR, REPO_ROOT, TEMPLATE_DIR
from ..core.paths import PROCESSED_DIR as SPEC_DIR
from ..core.paths import SCRATCH_DIR as SCRATCH
from ..core.proc import in_container, run
from ..core.python import PYTHON, SYSTEM_PYTHON, run_script
from ..onescript.toolchain import ensure_onescript_plugin

ONESCRIPT_RUNTIME = ("Конфигурация", "СекретнаяСтрока", "ТранспортHTTP", "ОтветAPI")
OPENAPI_GENERATOR_VERSION = os.environ.get("OPENAPI_GENERATOR_VERSION", "v7.10.0")
OPENAPI_GENERATOR_THREADS = os.environ.get("OPENAPI_GENERATOR_THREADS", "2")
BATCH_CONFIGS: list[str] = []


def yaml_string(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"


def write_template(
    source: Path, destination: Path, *replacements: tuple[str, str]
) -> None:
    text = source.read_text(encoding="utf-8")
    for old, new in replacements:
        text = text.replace(old, new)
    destination.write_text(text, encoding="utf-8")


def queue_generation(
    name: str,
    lang_config: Path,
    lang: str,
    spec: Path,
    out: Path,
    properties_csv: str,
    global_property: str = "",
    template_dir: Path | None = None,
) -> None:
    config = SCRATCH / "configs" / f"{name}.yaml"
    lines = [
        f"'!include': {yaml_string(in_container(lang_config))}",
        f"generatorName: {yaml_string(lang)}",
        f"inputSpec: {yaml_string('/work/' + in_container(spec))}",
        f"outputDir: {yaml_string('/work/' + in_container(out))}",
        "additionalProperties:",
    ]
    for prop in properties_csv.split(","):
        key, value = prop.split("=", 1)
        lines.append(f"  {key}: {yaml_string(value)}")
    if global_property:
        key, value = global_property.split("=", 1)
        lines.append(f"globalProperties:\n  {key}: {yaml_string(value)}")
    lines.append("skipValidateSpec: true")
    if template_dir is not None:
        lines.append(
            f"templateDir: {yaml_string('/work/' + in_container(template_dir))}"
        )
    config.write_text("\n".join(lines) + "\n", encoding="utf-8")
    BATCH_CONFIGS.append(in_container(config))


def prepare_clients() -> None:
    for name in ("python", "typescript", "java", "csharp"):
        shutil.rmtree(CLIENTS_DIR / name, ignore_errors=True)

    siblings = {
        "php": "wb-api-client-php",
        "onescript": "wb-api-client-1c",
        "go": "wb-api-client-go",
    }
    for submodule in ("php", "onescript", "go"):
        root = CLIENTS_DIR / submodule
        if (root / ".git").exists():
            if submodule in ("php", "onescript"):
                shutil.rmtree(root / "src", ignore_errors=True)
            else:
                for child in root.iterdir():
                    if child.is_dir() and not child.name.startswith("."):
                        shutil.rmtree(child)
                (root / "go.sum").unlink(missing_ok=True)
            continue

        sys.stderr.write(
            f"error: clients/{submodule} is not a git submodule mount ({root}/.git missing).\n"
            f"       Output would land in an orphaned directory, not the sibling {siblings[submodule]} repo.\n"
            f"       Initialize it with: git submodule update --init clients/{submodule}\n"
        )
        raise SystemExit(1)

    for directory in (
        CLIENTS_DIR / "python/wb_api_client",
        CLIENTS_DIR / "typescript/src",
        CLIENTS_DIR / "go",
        CLIENTS_DIR / "java/src/main/java" / JAVA_GROUP_PATH,
        CLIENTS_DIR / "php/src",
        CLIENTS_DIR / "csharp/src",
        CLIENTS_DIR / "onescript/src/Классы",
        CLIENTS_DIR / "onescript/src/Модели",
        SCRATCH / "configs",
    ):
        directory.mkdir(parents=True, exist_ok=True)


def queue_specs(specs: list[Path], version: str) -> list[str]:
    BATCH_CONFIGS.clear()
    slugs = []
    for spec in specs:
        slug = module_slug(spec.stem)
        snake = slug.replace("-", "_")
        pascal = pascal_from_snake(snake)
        common = (
            f"packageVersion={version},artifactVersion={version},npmVersion={version}"
        )
        java_pkg = f"io.github.valeryverkhoturov.wbapi.{snake}"
        php_ns = f"ValeryVerkhoturov\\WbApiClient\\{pascal}"
        slugs.append(slug)

        queue_generation(
            f"py-{snake}",
            CONFIG_DIR / "python.yaml",
            "python",
            spec,
            SCRATCH / f"py-{snake}",
            f"{common},packageName=wb_api_client.{snake},projectName=wb_api_client_{snake}",
            "skipFormModel=false",
        )
        queue_generation(
            f"ts-{slug}",
            CONFIG_DIR / "typescript.yaml",
            "typescript-axios",
            spec,
            SCRATCH / f"ts-{slug}",
            f"{common},npmName=@valeryverkhoturov/wb-api-client-{slug}",
            "skipFormModel=false",
        )
        queue_generation(
            f"go-{snake}",
            CONFIG_DIR / "go.yaml",
            "go",
            spec,
            SCRATCH / f"go-{snake}",
            f"{common},packageName={snake}",
            "skipFormModel=false",
        )
        queue_generation(
            f"java-{slug}",
            CONFIG_DIR / "java.yaml",
            "java",
            spec,
            SCRATCH / f"java-{slug}",
            f"{common},artifactId=wb-api-client-{slug},invokerPackage={java_pkg},"
            f"apiPackage={java_pkg}.api,modelPackage={java_pkg}.model",
            "skipFormModel=false",
        )
        queue_generation(
            f"php-{snake}",
            CONFIG_DIR / "php.yaml",
            "php",
            spec,
            SCRATCH / f"php-{snake}",
            f"{common},invokerPackage={php_ns},packageName=WbApiClient{pascal},"
            f"composerPackageName=valeryverkhoturov/wb-api-client-{slug}",
            "skipFormModel=false",
            TEMPLATE_DIR / "php",
        )
        queue_generation(
            f"cs-{snake}",
            CONFIG_DIR / "csharp.yaml",
            "csharp",
            spec,
            SCRATCH / f"cs-{snake}",
            f"{common},packageName=ValeryVerkhoturov.WbApiClient.{pascal}",
            "skipFormModel=false",
        )
        queue_generation(
            f"os-{snake}",
            CONFIG_DIR / "onescript.yaml",
            "onescript",
            spec,
            SCRATCH / f"os-{snake}",
            f"packageVersion={version},modelNamePrefix={pascal}",
        )
    return slugs


def run_batch(plugin: Path) -> None:
    print(
        f"→ {len(BATCH_CONFIGS)} generator tasks ({OPENAPI_GENERATOR_THREADS} threads)"
    )
    docker_run(
        f"openapitools/openapi-generator-cli:{OPENAPI_GENERATOR_VERSION}",
        [
            "-cp",
            "/plugin.jar:/opt/openapi-generator/modules/openapi-generator-cli/target/openapi-generator-cli.jar",
            "org.openapitools.codegen.OpenAPIGenerator",
            "batch",
            "--fail-fast",
            "--includes-base-dir",
            "/work",
            "--threads",
            OPENAPI_GENERATOR_THREADS,
            "--",
            *BATCH_CONFIGS,
        ],
        mounts=[f"{REPO_ROOT}:/work", f"{plugin}:/plugin.jar:ro"],
        workdir="/work",
        entrypoint="java",
        check=True,
        stdout=subprocess.DEVNULL,
    )


def splice_spec(spec: Path) -> None:
    slug = module_slug(spec.stem)
    snake = slug.replace("-", "_")
    pascal = pascal_from_snake(snake)
    print(f"→ {slug}")

    py_tmp = SCRATCH / f"py-{snake}"
    shutil.move(
        py_tmp / "wb_api_client" / snake, CLIENTS_DIR / "python/wb_api_client" / snake
    )

    ts_tmp = SCRATCH / f"ts-{slug}"
    ts_dest = CLIENTS_DIR / "typescript/src" / slug
    ts_dest.mkdir(parents=True, exist_ok=True)
    for source in sorted(ts_tmp.glob("*.ts")):
        shutil.copy(source, ts_dest / source.name)
    for sub in ("api", "models"):
        if (ts_tmp / sub).is_dir():
            shutil.copytree(ts_tmp / sub, ts_dest / sub)
    common = ts_dest / "common.ts"
    if common.is_file():
        text = common.read_text(encoding="utf-8")
        common.write_text(
            text.replace(
                "return axios.request<T, R>(axiosRequestArgs);",
                "return axios.request<T, R>(axiosRequestArgs) as unknown as Promise<R>;",
            ),
            encoding="utf-8",
        )

    go_tmp = SCRATCH / f"go-{snake}"
    go_dest = CLIENTS_DIR / "go" / snake
    go_dest.mkdir(parents=True, exist_ok=True)
    for source in sorted(go_tmp.glob("*.go")):
        shutil.copy(source, go_dest / source.name)

    java_tmp = SCRATCH / f"java-{slug}"
    java_src = java_tmp / "src/main/java" / JAVA_GROUP_PATH / snake
    java_dest = CLIENTS_DIR / "java/src/main/java" / JAVA_GROUP_PATH / snake
    shutil.move(java_src, java_dest)

    php_tmp = SCRATCH / f"php-{snake}"
    php_dest = CLIENTS_DIR / "php/src" / pascal
    php_dest.mkdir(parents=True, exist_ok=True)
    for source in (php_tmp / "src").iterdir():
        if not source.name.startswith("."):
            shutil.move(source, php_dest / source.name)

    cs_tmp = SCRATCH / f"cs-{snake}"
    cs_ns = f"ValeryVerkhoturov.WbApiClient.{pascal}"
    cs_dest = CLIENTS_DIR / "csharp/src" / pascal
    cs_dest.mkdir(parents=True, exist_ok=True)
    for sub in ("Api", "Client", "Model"):
        source = cs_tmp / "src" / cs_ns / sub
        if source.is_dir():
            shutil.move(source, cs_dest / sub)

    os_tmp = SCRATCH / f"os-{snake}"
    os_api_dest = CLIENTS_DIR / "onescript/src/Классы" / pascal
    os_model_dest = CLIENTS_DIR / "onescript/src/Модели" / pascal
    os_api_dest.mkdir(parents=True, exist_ok=True)
    os_model_dest.mkdir(parents=True, exist_ok=True)
    for source in sorted((os_tmp / "src/Классы").glob("*.os")):
        if source.stem not in ONESCRIPT_RUNTIME:
            shutil.move(source, os_api_dest / source.name)
    for source in sorted((os_tmp / "src/Модели").glob("*.os")):
        shutil.move(source, os_model_dest / source.name)

    runtime_dest = CLIENTS_DIR / "onescript/src/Классы"
    if not (runtime_dest / "Конфигурация.os").is_file():
        for runtime in ONESCRIPT_RUNTIME:
            shutil.copy(
                os_tmp / "src/Классы" / f"{runtime}.os", runtime_dest / f"{runtime}.os"
            )
        configuration = runtime_dest / "Конфигурация.os"
        lines = configuration.read_text(encoding="utf-8").splitlines(keepends=True)
        configuration.write_text(
            "".join(
                line
                for line in lines
                if "Адрес по умолчанию из спецификации" not in line
            ),
            encoding="utf-8",
        )


def finish_packages(slugs: list[str], version: str) -> None:
    write_template(
        TEMPLATE_DIR / "python/pyproject.toml",
        CLIENTS_DIR / "python/pyproject.toml",
        ("__VERSION__", version),
    )
    write_template(
        TEMPLATE_DIR / "python/__init__.py",
        CLIENTS_DIR / "python/wb_api_client/__init__.py",
        ("__VERSION__", version),
    )

    exports = (
        "{"
        + ",".join(
            f'"./{slug}": {{"types": "./dist/{slug}/index.d.ts", "default": "./dist/{slug}/index.js"}}'
            for slug in slugs
        )
        + "}"
    )
    write_template(
        TEMPLATE_DIR / "typescript/package.json",
        CLIENTS_DIR / "typescript/package.json",
        ("__VERSION__", version),
        ("__EXPORTS__", exports),
    )
    shutil.copy(
        TEMPLATE_DIR / "typescript/tsconfig.json",
        CLIENTS_DIR / "typescript/tsconfig.json",
    )
    index = 'export * from "./api";\nexport * from "./configuration";\nexport * from "./base";\nexport * from "./common";\n'
    for slug in slugs:
        (CLIENTS_DIR / "typescript/src" / slug / "index.ts").write_text(
            index, encoding="utf-8"
        )

    run_script(
        SYSTEM_PYTHON, REPO_ROOT / "scripts/inject-secrets.py", CLIENTS_DIR, check=True
    )
    shutil.copy(TEMPLATE_DIR / "go/go.mod", CLIENTS_DIR / "go/go.mod")
    write_template(
        TEMPLATE_DIR / "java/pom.xml",
        CLIENTS_DIR / "java/pom.xml",
        ("__VERSION__", version),
    )
    write_template(
        TEMPLATE_DIR / "php/composer.json",
        CLIENTS_DIR / "php/composer.json",
        ("__VERSION__", version),
    )
    write_template(
        TEMPLATE_DIR / "csharp/WbApiClient.csproj",
        CLIENTS_DIR / "csharp/WbApiClient.csproj",
        ("__VERSION__", version),
    )
    run_script(
        PYTHON,
        REPO_ROOT / "scripts/generate-onescript-manifests.py",
        REPO_ROOT,
        version,
        check=True,
    )


def warn_formatter(warning: str, action) -> None:
    try:
        action()
    except (OSError, subprocess.CalledProcessError):
        print(warning)


def format_go() -> None:
    if not shutil.which("docker"):
        return
    warn_formatter(
        "  ! go mod tidy / gofmt failed — run manually in clients/go before publish",
        lambda: docker_run(
            "golang:1.22-alpine",
            ["sh", "-c", "go mod tidy && gofmt -w . && gofmt -w ."],
            mounts=[f"{REPO_ROOT}:/work"],
            workdir="/work/clients/go",
            env=["HOME=/tmp", "GOCACHE=/tmp/.cache/go-build", "GOPATH=/tmp/go"],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        ),
    )


def format_python() -> None:
    black = REPO_ROOT / ".venv/bin/black"
    if os.access(black, os.X_OK):
        command = [black, "--quiet", CLIENTS_DIR / "python"]
    elif shutil.which("black"):
        command = ["black", "--quiet", CLIENTS_DIR / "python"]
    else:
        probe = run(
            [SYSTEM_PYTHON, "-c", "import black"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        if probe.returncode != 0:
            print(
                "  ! black not installed — skipping Python format (pip install -r scripts/requirements.txt)"
            )
            return
        command = [SYSTEM_PYTHON, "-m", "black", "--quiet", CLIENTS_DIR / "python"]
    run(command, check=True)


def format_typescript() -> None:
    if not shutil.which("docker"):
        return
    warn_formatter(
        "  ! prettier failed — run manually in clients/typescript before publish",
        lambda: docker_run(
            "node:20-alpine",
            [
                "sh",
                "-c",
                "npm install --silent --no-audit --no-fund && npx --no-install prettier --write --log-level=error 'src/**/*.ts'",
            ],
            mounts=[f"{REPO_ROOT}:/work"],
            workdir="/work/clients/typescript",
            env=["HOME=/tmp", "npm_config_cache=/tmp/.npm"],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        ),
    )


def format_java() -> None:
    if not shutil.which("docker"):
        return
    warn_formatter(
        "  ! mvn spotless:apply failed — run manually in clients/java before publish",
        lambda: docker_run(
            "maven:3.9-eclipse-temurin-17",
            ["mvn", "-q", "-Duser.home=/tmp", "spotless:apply"],
            mounts=[f"{REPO_ROOT}:/work"],
            workdir="/work/clients/java",
            env=["HOME=/tmp"],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        ),
    )


def format_php() -> None:
    if not shutil.which("docker"):
        return
    warn_formatter(
        "  ! php-cs-fixer failed — run manually in clients/php before publish",
        lambda: docker_run(
            "ghcr.io/php-cs-fixer/php-cs-fixer:3-php8.3",
            ["fix", "src", "--rules=@PSR12", "--using-cache=no"],
            mounts=[f"{REPO_ROOT}:/work"],
            workdir="/work/clients/php",
            env=["HOME=/tmp", "PHP_CS_FIXER_IGNORE_ENV=1"],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        ),
    )


def format_csharp() -> None:
    warning = "  ! dotnet format failed — run manually in clients/csharp before publish"
    if os.environ.get("CI") == "true" and shutil.which("dotnet"):
        warn_formatter(
            warning,
            lambda: run(
                ["dotnet", "format", "whitespace", "-v", "q"],
                check=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                cwd=CLIENTS_DIR / "csharp",
            ),
        )
    elif shutil.which("docker"):
        warn_formatter(
            warning,
            lambda: docker_run(
                "mcr.microsoft.com/dotnet/sdk:8.0",
                ["dotnet", "format", "whitespace", "-v", "q"],
                mounts=[f"{CLIENTS_DIR / 'csharp'}:/app"],
                workdir="/app",
                env=[
                    "HOME=/tmp",
                    "DOTNET_CLI_TELEMETRY_OPTOUT=1",
                    "DOTNET_NOLOGO=1",
                    "NUGET_PACKAGES=/tmp/.nuget",
                ],
                check=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            ),
        )


def format_clients() -> None:
    formatters = (
        format_go,
        format_python,
        format_typescript,
        format_java,
        format_php,
        format_csharp,
    )
    with ThreadPoolExecutor(max_workers=len(formatters)) as executor:
        futures = [executor.submit(formatter) for formatter in formatters]
        for future in futures:
            future.result()


def main() -> None:
    sys.stdout.reconfigure(line_buffering=True)
    if len(sys.argv) < 2:
        sys.stderr.write(f"usage: {sys.argv[0]} <version>\n")
        raise SystemExit(2)
    version = sys.argv[1]

    specs = sorted((SPEC_DIR / "ru").glob("*.yaml")) if SPEC_DIR.is_dir() else []
    if not specs:
        sys.stderr.write(
            f"no processed specs at {SPEC_DIR / 'ru'} — run process-specs.py first\n"
        )
        raise SystemExit(1)

    plugin = ensure_onescript_plugin()
    prepare_clients()
    slugs = queue_specs(specs, version)
    run_batch(plugin)
    for spec in specs:
        splice_spec(spec)
    finish_packages(slugs, version)
    format_clients()
    run_script(PYTHON, REPO_ROOT / "scripts/generate-readmes.py", REPO_ROOT, check=True)
    shutil.rmtree(SCRATCH)
    print(f"Generated 7 unified client libraries at version {version}")


if __name__ == "__main__":
    main()
