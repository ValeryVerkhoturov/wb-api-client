# wb-api-client

Auto-generated client libraries for the [Wildberries Seller API](https://dev.wildberries.ru/) in **Python**, **TypeScript**, **Go**, **Java**, **PHP**, and **OneScript**. Specs are pulled daily from `dev.wildberries.ru`; when they change, new packages are cut and pushed to each language's package manager.

## What's in the box

- **One package per language**, with all 13 WB API categories as sub-modules: `general`, `items`, `orders_fbs`, `orders_dbw`, `dbs`, `in_store_pickup`, `orders_fbw`, `promotion`, `communications`, `rates`, `analytics`, `reports`, `finances`.
- **Bearer JWT authorization** is injected into every spec before generation, even though upstream YAMLs omit a security scheme. All generated clients expose an `Authorization` parameter.
- Stable-semver releases (`1.YYYYMMDD.N` — MAJOR fixed at 1, MINOR is the release date as an int, PATCH is a same-day counter) — one string covers all 6 languages so versions line up across ecosystems, and `npm/pip/mvn/composer/go get @latest` all auto-pick the highest.

## Install & import

**Python (PyPI):**
```bash
pip install valeryverkhoturov-wb-api-client
```
```python
from wb_api_client.items import Configuration, ApiClient
from wb_api_client.items.api import DefaultApi

cfg = Configuration(access_token="<your WB JWT>")  # auto-wrapped in pydantic.SecretStr
api = DefaultApi(ApiClient(cfg))
```

**TypeScript (npm):**
```bash
npm install @valeryverkhoturov/wb-api-client
```
```ts
import { Configuration, DefaultApi } from "@valeryverkhoturov/wb-api-client/items";

const cfg = new Configuration({});
cfg.setAccessToken("<your WB JWT>");                // wraps in SecretString internally
const api = new DefaultApi(cfg);
```

**Go:**
```bash
go get github.com/ValeryVerkhoturov/wb-api-client/clients/go@latest
```
```go
import wbitems "github.com/ValeryVerkhoturov/wb-api-client/clients/go/items"

cfg := wbitems.NewConfiguration()
cfg.SetAccessToken("<your WB JWT>")                 // stored as *secrecy.SecretString
client := wbitems.NewAPIClient(cfg)
```

**Java (Maven Central):**
```xml
<dependency>
  <groupId>io.github.valeryverkhoturov</groupId>
  <artifactId>wb-api-client</artifactId>
  <version>1.20260921.0</version>
</dependency>
```
```java
import io.github.valeryverkhoturov.wbapi.items.ApiClient;
import io.github.valeryverkhoturov.wbapi.items.SecretString;
import io.github.valeryverkhoturov.wbapi.items.api.DefaultApi;

ApiClient client = new ApiClient();
client.setBearerToken(new SecretString("<your WB JWT>"));
DefaultApi api = new DefaultApi(client);
```

**PHP (Packagist):**
```bash
composer require valeryverkhoturov/wb-api-client
```
```php
use ValeryVerkhoturov\WbApiClient\Items\Configuration;
use ValeryVerkhoturov\WbApiClient\Items\SecretString;
use ValeryVerkhoturov\WbApiClient\Items\Api\DefaultApi;
use GuzzleHttp\Client;

$config = (new Configuration())
    ->setAccessTokenSecret(new SecretString('<your WB JWT>'));
$api = new DefaultApi(new Client(), $config);
```

**OneScript ([hub.oscript.io](https://hub.oscript.io)):**
```bash
opm install wb-api-client
```
```bsl
#Использовать "wb-api-client"

Настройки = Новый Конфигурация();
Настройки.УстановитьТокен("<your WB JWT>");
Клиент = Новый КарточкиТоваровApi(Настройки);
```

OneScript has no namespaces, so categories are separated by class name rather
than import path: API classes keep the spec's tag (`КарточкиТоваровApi`), and
model classes carry the category as a prefix (`ItemsResponse4XX`). The package
also lives in its own repo, [`wb-api-client-1c`](https://github.com/ValeryVerkhoturov/wb-api-client-1c),
so you can clone it at a tag instead of going through the hub.

### Per-language module reference

Each generated client has its own README with an install snippet, the auth block, and a per-module import + instantiate example for all 13 API categories. The six READMEs are regenerated on every release, so they never drift from the code:

- **Python** — [`clients/python/README.md`](clients/python/README.md)
- **TypeScript** — [`clients/typescript/README.md`](clients/typescript/README.md)
- **Go** — [`clients/go/README.md`](clients/go/README.md)
- **Java** — [`clients/java/README.md`](clients/java/README.md)
- **PHP** — [`ValeryVerkhoturov/wb-api-client-php`](https://github.com/ValeryVerkhoturov/wb-api-client-php#readme) (separate repo, mounted here as the `clients/php` submodule)
- **OneScript** — [`ValeryVerkhoturov/wb-api-client-1c`](https://github.com/ValeryVerkhoturov/wb-api-client-1c#readme) (separate repo, mounted here as the `clients/onescript` submodule)

### Secret redaction

In every language the bearer JWT is stored inside a "secret-string" wrapper so it redacts under logs / `print` / `console.log` / `System.out.println` / `fmt.Printf` unless you explicitly ask for the raw value:

| Language | Wrapper type | Redacted under | Explicit expose |
|---|---|---|---|
| Python | [`pydantic.SecretStr`](https://docs.pydantic.dev/latest/api/types/#pydantic.types.SecretStr) | `print(cfg.access_token)` → `**********` | `.get_secret_value()` |
| TypeScript | `SecretString` class (internal, exposed) | `console.log(new SecretString("…"))` → `<REDACTED>` | `.exposeSecret()` |
| Go | [`secrecy.SecretString`](https://github.com/negrel/secrecy) | `fmt.Printf("%v", cfg.AccessToken)` → `<!SECRET_LEAKED!>` | `.ExposeSecret()` |
| Java | `SecretString` class (per sub-module) | `System.out.println(s)` → `<REDACTED>` | `.exposeSecret()` |
| PHP | `SecretString` class (per sub-module) | `var_dump($secret)` → `'<REDACTED>'` | `->exposeSecret()` |
| OneScript | `СекретнаяСтрока` class | `Сообщить(Настройки.Токен())` → `СекретнаяСтрока` | `.Раскрыть()` |

Passing the token through the wrapper is the only supported path.

## Local development

```bash
./scripts/download-swaggers.sh          # pull YAMLs from dev.wildberries.ru
pip install -r scripts/requirements.txt
python  scripts/post-process.py         # inject Bearer auth security scheme
./scripts/generate.sh 0.0.0-local       # emit clients/{python,typescript,go,java,php,onescript}
```

## How the daily release works

`.github/workflows/daily-check.yml` runs on cron:

1. Re-downloads all 13 specs.
2. Diffs `swaggers/checksums.txt` against the freshly generated one.
3. If any file changed (or `workflow_dispatch` was called with `force: true`), it commits the new specs, computes a CalVer version, tags the repo, and dispatches `publish.yml` once per language.

Each language branch in `publish.yml` regenerates its clients from the just-updated specs and pushes to its registry. Publish credentials live in GitHub Environments (`pypi`, `npm`, `maven-central`) and Actions secrets:

| Environment | Required secrets |
|---|---|
| `pypi` | none — set up [PyPI trusted publishing](https://docs.pypi.org/trusted-publishers/) for the `valeryverkhoturov-wb-api-client` project |
| `npm` | `NPM_TOKEN` (automation token) |
| `maven-central` | `MAVEN_USERNAME`, `MAVEN_PASSWORD`, `MAVEN_GPG_PRIVATE_KEY`, `MAVEN_GPG_PASSPHRASE` |
| `packagist` | `PACKAGIST_USERNAME`, `PACKAGIST_API_TOKEN` — package must be pre-registered at [packagist.org/packages/submit](https://packagist.org/packages/submit) |
| Go | none — tags in this repo are the release mechanism |
| `onescript` | `OSCRIPT_HUB_TOKEN` — a GitHub token; [hub.oscript.io](https://hub.oscript.io) uses it to verify the pusher (no scopes needed), and the package must be pre-registered there |
| — (repo-level) | `SIBLING_REPO_TOKEN` — PAT with `repo` scope on **both** `wb-api-client-php` and `wb-api-client-1c`, used to push their commits and tags |

## License

Apache 2.0. See [LICENSE](LICENSE).
