# Пример: вызов new-balance-open-api.wb.ru через Python-клиент

Задача: вызвать детализацию финансового отчёта на хосте
`https://new-balance-open-api.wb.ru` вместо штатного
`https://finance-api.wildberries.ru`, с авторизацией через заголовки
`X-Nb-Auth-Token` и `X-Supplier-Old-Id`, подменив путь
`/api/finance/v1/sales-reports/detailed` на
`/api/v4/supplier/financialReport/detailed`.

Важно: v4-эндпоинт периодный (`GetReportDetailByPeriod`), а не по ID отчёта —
обязательные поля тела `dateFrom`/`dateTo` (иначе сервер отвечает 400
`Field validation for 'DateFrom' failed on the 'required' tag`). Поэтому за
основу берём метод `post_v1_sales_reports_detailed`: его модель запроса
`SalesReportsDetailedReq` уже сериализуется ровно в нужные поля
(`dateFrom`, `dateTo`, `limit`, `rrdId`, `period`).

## 1. Установка

```bash
pip install valeryverkhoturov-wb-api-client
```

## 2. Переопределение хоста

Каждый метод сгенерированного клиента зашивает operation-server
(`https://finance-api.wildberries.ru`) в сериализатор запроса, поэтому одного
`host=` недостаточно — нужен ещё `ignore_operation_servers=True`. Тогда
`ApiClient` соберёт URL как `configuration.host + resource_path`.

`access_token` не передаём: Bearer-авторизация из спецификации WB здесь не
нужна, токен уходит в заголовке `X-Nb-Auth-Token` (при неправильном токене
сервер отвечает `{"code":20,"message":"invalid or expired token"}`).

```python
from wb_api_client.finances import Configuration, ApiClient

cfg = Configuration(
    host="https://new-balance-open-api.wb.ru",
    ignore_operation_servers=True,  # игнорировать зашитый в метод operation-server
)
client = ApiClient(cfg)
```

## 3. Заголовки авторизации

`set_default_header` добавляет заголовок ко всем запросам этого `ApiClient`
(они попадают в `default_headers` и мержатся в каждый запрос).

```python
client.set_default_header("X-Nb-Auth-Token", "<token>")
client.set_default_header("X-Supplier-Old-Id", "585923")
```

## 4. Переопределение пути

Путь зашит в приватный сериализатор метода. Сериализатор возвращает кортеж
`(method, url, headers, body, auth_settings)` — достаточно вызвать родительский
и заменить путь в уже собранном URL:

```python
from wb_api_client.finances.api import Api
from wb_api_client.finances.api_client import RequestSerialized


class NewBalanceApi(Api):
    def _post_v1_sales_reports_detailed_serialize(
        self,
        sales_reports_detailed_req,
        _request_auth,
        _content_type,
        _headers,
        _host_index,
    ) -> RequestSerialized:
        param = super()._post_v1_sales_reports_detailed_serialize(
            sales_reports_detailed_req,
            _request_auth,
            _content_type,
            _headers,
            _host_index,
        )
        method, url, *rest = param
        url = url.replace(
            "/api/finance/v1/sales-reports/detailed",
            "/api/v4/supplier/financialReport/detailed",
        )
        return (method, url, *rest)
```

Тело запроса наследуется как есть: `dateFrom`/`dateTo` — обязательные для v4,
остальные поля (`limit`, `rrdId`, `period`) сервер игнорирует, если не
поддерживает (Go-декодер пропускает неизвестные поля).

## 5. Вызов

Публичный метод `post_v1_sales_reports_detailed` остаётся прежним — он вызовет
наш переопределённый сериализатор, а десериализация ответа в
`List[SalesReportsDetailedRes]` сохранится.

```python
from wb_api_client.finances.models import SalesReportsDetailedReq

api = NewBalanceApi(client)

rows = api.post_v1_sales_reports_detailed(
    sales_reports_detailed_req=SalesReportsDetailedReq(
        date_from="2026-10-01",            # RFC3339, время в МСК (UTC+3)
        date_to="2026-10-08T23:59:59",
        limit=100000,
        rrd_id=0,                          # alias "rrdId"
    ),
)

for row in rows:
    print(row.rrd_id, row.realizationreport_id, row.ppvz_for_pay)
```

Если v4-эндпоинт поддерживает постраничность как исходный: начинайте с
`rrd_id=0`, в следующих запросах передавайте `rrdId` последней строки ответа,
пока сервер не вернёт `204 No Content`.

## Итоговый URL и запрос

```
POST https://new-balance-open-api.wb.ru/api/v4/supplier/financialReport/detailed
X-Nb-Auth-Token: <token>
X-Supplier-Old-Id: 585923
Content-Type: application/json

{"dateFrom": "2026-10-01", "dateTo": "2026-10-08T23:59:59", "limit": 100000, "rrdId": 0, "period": "weekly"}
```
