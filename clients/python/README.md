# wb-api-client — Python

Auto-generated Python client for the [Wildberries Seller API](https://dev.wildberries.ru/). One package, thirteen sub-modules — one per API category. This README is regenerated on every release, so it always matches the code in this tree.

## Install

```bash
pip install valeryverkhoturov-wb-api-client
```

## Authentication

Every module accepts the same WB bearer JWT. The token is stored in a redacting wrapper — `pydantic.SecretStr` — so it does not leak under logs / `print` unless you explicitly ask for the raw value with `.get_secret_value()`.

```python
from wb_api_client.items import Configuration, ApiClient

cfg = Configuration(access_token="<your WB JWT>")
client = ApiClient(cfg)
```

## Modules

Each row below is a sub-module you can import independently. Import path is `wb_api_client.<slug>`.

| Slug | Category | APIs |
|---|---|---|
| [`general`](https://dev.wildberries.ru/openapi/api-information) | Общее | `APIApi`, `Api`, `WBAPIApi` |
| [`items`](https://dev.wildberries.ru/openapi/item-management) | Работа с товарами | `Api`, `DefaultApi` |
| [`orders-fbs`](https://dev.wildberries.ru/openapi/orders-fbs) | Заказы FBS | `Api`, `FBSApi` |
| [`orders-dbw`](https://dev.wildberries.ru/openapi/orders-dbw) | Заказы DBW | `DBWApi` |
| [`dbs`](https://dev.wildberries.ru/openapi/dbs) | DBS | `DBSApi` |
| [`in-store-pickup`](https://dev.wildberries.ru/openapi/in-store-pickup) | Самовывоз | `Api` |
| [`orders-fbw`](https://dev.wildberries.ru/openapi/orders-fbw) | Поставки FBW | `Api` |
| [`promotion`](https://dev.wildberries.ru/openapi/promotion) | Маркетинг и продвижение | `Api`, `DefaultApi` |
| [`communications`](https://dev.wildberries.ru/openapi/customer-communication) | Общение с покупателями | `Api`, `DefaultApi` |
| [`rates`](https://dev.wildberries.ru/openapi/rates) | Тарифы | `Api`, `DefaultApi` |
| [`analytics`](https://dev.wildberries.ru/openapi/analytics) | Аналитика и данные | `Api`, `CSVApi` |
| [`reports`](https://dev.wildberries.ru/openapi/reports) | Отчёты | `Api`, `CApi` |
| [`finances`](https://dev.wildberries.ru/openapi/documents-and-accounting) | Документы и бухгалтерия | `Api`, `DefaultApi` |

## Per-module usage

### general — Общее

В этом разделе: [общая информация о WB API](https://dev.wildberries.ru/openapi/api-information#tag/introduction) как [начать работу с WB API](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Kak-nachat-rabotu-s-API) ка…

**Reference:** https://dev.wildberries.ru/openapi/api-information

**APIs:** `APIApi`, `Api`, `WBAPIApi`

```python
from wb_api_client.general import Configuration, ApiClient
from wb_api_client.general.api import APIApi

cfg = Configuration(access_token="<your WB JWT>")
api = APIApi(ApiClient(cfg))
```

### items — Работа с товарами

С помощью методов этого раздела вы можете: [создавать](https://dev.wildberries.ru/openapi/item-management#tag/listingItems) и [редактировать](https://dev.wildberries.ru/openapi/item-management#tag/listings) карточки товаров получать [кат…

**Reference:** https://dev.wildberries.ru/openapi/item-management

**APIs:** `Api`, `DefaultApi`

```python
from wb_api_client.items import Configuration, ApiClient
from wb_api_client.items.api import Api

cfg = Configuration(access_token="<your WB JWT>")
api = Api(ApiClient(cfg))
```

### orders-fbs — Заказы FBS

С помощью методов раздела Заказы FBS (Fulfillment by Seller) вы можете: получать информацию о [сборочных заданиях](https://dev.wildberries.ru/openapi/orders-fbs#tag/fbsAssemblyOrders) и их статусах, отменять сборочные задания, получать с…

**Reference:** https://dev.wildberries.ru/openapi/orders-fbs

**APIs:** `Api`, `FBSApi`

```python
from wb_api_client.orders_fbs import Configuration, ApiClient
from wb_api_client.orders_fbs.api import Api

cfg = Configuration(access_token="<your WB JWT>")
api = Api(ApiClient(cfg))
```

### orders-dbw — Заказы DBW

С помощью методов Заказы DBW (Деливери WB) вы можете: получать информацию о [сборочных заданиях](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwAssemblyOrders), управлять статусами и отменять сборочные задания получать, добавлять,…

**Reference:** https://dev.wildberries.ru/openapi/orders-dbw

**APIs:** `DBWApi`

```python
from wb_api_client.orders_dbw import Configuration, ApiClient
from wb_api_client.orders_dbw.api import DBWApi

cfg = Configuration(access_token="<your WB JWT>")
api = DBWApi(ApiClient(cfg))
```

### dbs — DBS

Узнать больше о модели DBS можно в [справочном центре](https://seller.wildberries.ru/instructions/category/6572e024-7428-4db1-86a8-a4c7dbebbfcf?goBackOption=prevRoute&categoryId=5a8e1202-0865-45b7-acae-5d0afc7add56)

**Reference:** https://dev.wildberries.ru/openapi/dbs

**APIs:** `DBSApi`

```python
from wb_api_client.dbs import Configuration, ApiClient
from wb_api_client.dbs.api import DBSApi

cfg = Configuration(access_token="<your WB JWT>")
api = DBSApi(ApiClient(cfg))
```

### in-store-pickup — Самовывоз

Управление [сборочными заданиями](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders) и [идентификаторами маркировки](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers) С…

**Reference:** https://dev.wildberries.ru/openapi/in-store-pickup

**APIs:** `Api`

```python
from wb_api_client.in_store_pickup import Configuration, ApiClient
from wb_api_client.in_store_pickup.api import Api

cfg = Configuration(access_token="<your WB JWT>")
api = Api(ApiClient(cfg))
```

### orders-fbw — Поставки FBW

Узнать больше о поставках FBW можно в [справочном центре](https://seller.wildberries.ru/instructions/subcategory/5a8e1202-0865-45b7-acae-5d0afc7add56?goBackOption=prevRoute&categoryId=479385c6-de01-4b4d-ad4e-ed941e65582e)

**Reference:** https://dev.wildberries.ru/openapi/orders-fbw

**APIs:** `Api`

```python
from wb_api_client.orders_fbw import Configuration, ApiClient
from wb_api_client.orders_fbw.api import Api

cfg = Configuration(access_token="<your WB JWT>")
api = Api(ApiClient(cfg))
```

### promotion — Маркетинг и продвижение

Узнать больше о маркетинге и продвижении можно в [справочном центре](https://seller.wildberries.ru/instructions/category/59d92bd3-6ea0-40f2-b762-ca8835d7d42e?goBackOption=prevRoute&categoryId=479385c6-de01-4b4d-ad4e-ed941e65582e)

**Reference:** https://dev.wildberries.ru/openapi/promotion

**APIs:** `Api`, `DefaultApi`

```python
from wb_api_client.promotion import Configuration, ApiClient
from wb_api_client.promotion.api import Api

cfg = Configuration(access_token="<your WB JWT>")
api = Api(ApiClient(cfg))
```

### communications — Общение с покупателями

Узнать больше об общении с покупателями можно в [справочном центре](https://seller.wildberries.ru/instructions/category/f7f6c465-dd12-422d-80a0-a6d9562115d5?goBackOption=prevRoute&categoryId=30817062-14cc-4a82-bc78-3600c2b0685b)

**Reference:** https://dev.wildberries.ru/openapi/customer-communication

**APIs:** `Api`, `DefaultApi`

```python
from wb_api_client.communications import Configuration, ApiClient
from wb_api_client.communications.api import Api

cfg = Configuration(access_token="<your WB JWT>")
api = Api(ApiClient(cfg))
```

### rates — Тарифы

Узнать больше о тарифах можно в [справочном центре](https://seller.wildberries.ru/instructions/ru/ru/material/fees-site-section)

**Reference:** https://dev.wildberries.ru/openapi/rates

**APIs:** `Api`, `DefaultApi`

```python
from wb_api_client.rates import Configuration, ApiClient
from wb_api_client.rates.api import Api

cfg = Configuration(access_token="<your WB JWT>")
api = Api(ApiClient(cfg))
```

### analytics — Аналитика и данные

Узнать больше об аналитике и данных можно в [справочном центре](https://seller.wildberries.ru/instructions/ru/ru/subcategory/seller-analytics)

**Reference:** https://dev.wildberries.ru/openapi/analytics

**APIs:** `Api`, `CSVApi`

```python
from wb_api_client.analytics import Configuration, ApiClient
from wb_api_client.analytics.api import Api

cfg = Configuration(access_token="<your WB JWT>")
api = Api(ApiClient(cfg))
```

### reports — Отчёты

Узнать больше об отчётах можно в [справочном центре](https://seller.wildberries.ru/instructions/subcategory/5f2162c5-069b-416d-a4e1-48da2a76e6b0)

**Reference:** https://dev.wildberries.ru/openapi/reports

**APIs:** `Api`, `CApi`

```python
from wb_api_client.reports import Configuration, ApiClient
from wb_api_client.reports.api import Api

cfg = Configuration(access_token="<your WB JWT>")
api = Api(ApiClient(cfg))
```

### finances — Документы и бухгалтерия

Узнать больше о документах и бухгалтерии можно в [справочном центре](https://seller.wildberries.ru/instructions/category/ba929b64-1f89-4426-82d7-ce998ee552bd?goBackOption=prevRoute&categoryId=3c971375-9939-45e8-ab82-376019be8942)

**Reference:** https://dev.wildberries.ru/openapi/documents-and-accounting

**APIs:** `Api`, `DefaultApi`

```python
from wb_api_client.finances import Configuration, ApiClient
from wb_api_client.finances.api import Api

cfg = Configuration(access_token="<your WB JWT>")
api = Api(ApiClient(cfg))
```

