# wb-api-client

Auto-generated client libraries for the [Wildberries Seller API](https://dev.wildberries.ru/) in **Python**, **TypeScript**, **Go**, and **Java**. Specs are pulled daily from `dev.wildberries.ru`; when they change, new packages are cut and pushed to each language's package manager.

## What's in the box

- **One package per language**, with all 13 WB API categories as sub-modules: `general`, `items`, `orders_fbs`, `orders_dbw`, `dbs`, `in_store_pickup`, `orders_fbw`, `promotion`, `communications`, `rates`, `analytics`, `reports`, `finances`.
- **Bearer JWT authorization** is injected into every spec before generation, even though upstream YAMLs omit a security scheme. All generated clients expose an `Authorization` parameter.
- CalVer releases (`YYYY.MM.DD`) — one tag covers all 4 languages so versions line up across ecosystems.

## Install & import

**Python (PyPI):**
```bash
pip install wb-api-client
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
  <version>2026.09.19</version>
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

### Secret redaction

In every language the bearer JWT is stored inside a "secret-string" wrapper so it redacts under logs / `print` / `console.log` / `System.out.println` / `fmt.Printf` unless you explicitly ask for the raw value:

| Language | Wrapper type | Redacted under | Explicit expose |
|---|---|---|---|
| Python | [`pydantic.SecretStr`](https://docs.pydantic.dev/latest/api/types/#pydantic.types.SecretStr) | `print(cfg.access_token)` → `**********` | `.get_secret_value()` |
| TypeScript | `SecretString` class (internal, exposed) | `console.log(new SecretString("…"))` → `<REDACTED>` | `.exposeSecret()` |
| Go | [`secrecy.SecretString`](https://github.com/negrel/secrecy) | `fmt.Printf("%v", cfg.AccessToken)` → `<!SECRET_LEAKED!>` | `.ExposeSecret()` |
| Java | `SecretString` class (per sub-module) | `System.out.println(s)` → `<REDACTED>` | `.exposeSecret()` |

Passing the token through the wrapper is the only supported path.

## Local development

```bash
./scripts/download-swaggers.sh          # pull YAMLs from dev.wildberries.ru
pip install -r scripts/requirements.txt
python  scripts/post-process.py         # inject Bearer auth security scheme
./scripts/generate.sh 0.0.0-local       # emit clients/{python,typescript,go,java}
```

### Anti-bot note

`dev.wildberries.ru` sits behind Wildberries' WBAAS challenge (HTTP 498 for non-browsers). `download-swaggers.sh` ships with a hardcoded `x_wbaas_token` cookie that clears the challenge. That token is fingerprint-bound and eventually expires — when it does, open the swagger URL in a browser, copy the fresh `x_wbaas_token` cookie value, and either edit `DEFAULT_WBAAS_TOKEN` in the script or export `WBAAS_TOKEN=<value>` before running. For CI, store it as an Actions secret and inject it into the workflow env.

## How the daily release works

`.github/workflows/daily-check.yml` runs on cron:

1. Re-downloads all 13 specs.
2. Diffs `swaggers/checksums.txt` against the freshly generated one.
3. If any file changed (or `workflow_dispatch` was called with `force: true`), it commits the new specs, computes a CalVer version, tags the repo, and dispatches `publish.yml` once per language.

Each language branch in `publish.yml` regenerates its clients from the just-updated specs and pushes to its registry. Publish credentials live in GitHub Environments (`pypi`, `npm`, `maven-central`) and Actions secrets:

| Environment | Required secrets |
|---|---|
| `pypi` | none — set up [PyPI trusted publishing](https://docs.pypi.org/trusted-publishers/) for the `wb-api-client` project |
| `npm` | `NPM_TOKEN` (automation token) |
| `maven-central` | `MAVEN_USERNAME`, `MAVEN_PASSWORD`, `MAVEN_GPG_PRIVATE_KEY`, `MAVEN_GPG_PASSPHRASE` |
| Go | none — tags in this repo are the release mechanism |

## License

Apache 2.0. See [LICENSE](LICENSE).
