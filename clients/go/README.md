# wb-api-client — Go

Auto-generated Go client for the [Wildberries Seller API](https://dev.wildberries.ru/). One package, thirteen sub-modules — one per API category. This README is regenerated on every release, so it always matches the code in this tree.

## Install

```bash
go get github.com/ValeryVerkhoturov/wb-api-client/clients/go@latest
```

## Authentication

Every module accepts the same WB bearer JWT. The token is stored in a redacting wrapper — [`secrecy.SecretString`](https://github.com/negrel/secrecy) — so it does not leak under logs / `fmt.Printf` unless you explicitly ask for the raw value with `.ExposeSecret()`.

```go
import wbitems "github.com/ValeryVerkhoturov/wb-api-client/clients/go/items"

cfg := wbitems.NewConfiguration()
cfg.SetAccessToken("<your WB JWT>")
client := wbitems.NewAPIClient(cfg)
```

## Modules

Each row below is a sub-module you can import independently. Import path is `github.com/ValeryVerkhoturov/wb-api-client/clients/go/<slug>`.

| Slug | Category | APIs |
|---|---|---|
| [`general`](https://dev.wildberries.ru/openapi/api-information) | Общее | `APIAPI`, `DefaultApi`, `WBAPIAPI` |
| [`items`](https://dev.wildberries.ru/openapi/item-management) | Работа с товарами | `DefaultApi` |
| [`orders-fbs`](https://dev.wildberries.ru/openapi/orders-fbs) | Заказы FBS | `DefaultApi`, `FBSAPI` |
| [`orders-dbw`](https://dev.wildberries.ru/openapi/orders-dbw) | Заказы DBW | `DBWAPI` |
| [`dbs`](https://dev.wildberries.ru/openapi/dbs) | DBS | `DBSAPI` |
| [`in-store-pickup`](https://dev.wildberries.ru/openapi/in-store-pickup) | Самовывоз | `DefaultApi` |
| [`orders-fbw`](https://dev.wildberries.ru/openapi/orders-fbw) | Поставки FBW | `DefaultApi` |
| [`promotion`](https://dev.wildberries.ru/openapi/promotion) | Маркетинг и продвижение | `DefaultApi` |
| [`communications`](https://dev.wildberries.ru/openapi/customer-communication) | Общение с покупателями | `DefaultApi` |
| [`rates`](https://dev.wildberries.ru/openapi/rates) | Тарифы | `DefaultApi` |
| [`analytics`](https://dev.wildberries.ru/openapi/analytics) | Аналитика и данные | `CSVAPI`, `DefaultApi` |
| [`reports`](https://dev.wildberries.ru/openapi/reports) | Отчёты | `CAPI`, `DefaultApi` |
| [`finances`](https://dev.wildberries.ru/openapi/documents-and-accounting) | Документы и бухгалтерия | `DefaultApi` |

## Per-module usage

### general — Общее

В этом разделе: [общая информация о WB API](https://dev.wildberries.ru/openapi/api-information#tag/introduction) как [начать работу с WB API](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Kak-nachat-rabotu-s-API) ка…

**Reference:** https://dev.wildberries.ru/openapi/api-information

**APIs:** `APIAPI`, `DefaultApi`, `WBAPIAPI`

```go
import wbgeneral "github.com/ValeryVerkhoturov/wb-api-client/clients/go/general"

cfg := wbgeneral.NewConfiguration()
cfg.SetAccessToken("<your WB JWT>")
client := wbgeneral.NewAPIClient(cfg)
```

### items — Работа с товарами

С помощью методов этого раздела вы можете: [создавать](https://dev.wildberries.ru/openapi/item-management#tag/listingItems) и [редактировать](https://dev.wildberries.ru/openapi/item-management#tag/listings) карточки товаров получать [кат…

**Reference:** https://dev.wildberries.ru/openapi/item-management

**APIs:** `DefaultApi`

```go
import wbitems "github.com/ValeryVerkhoturov/wb-api-client/clients/go/items"

cfg := wbitems.NewConfiguration()
cfg.SetAccessToken("<your WB JWT>")
client := wbitems.NewAPIClient(cfg)
```

### orders-fbs — Заказы FBS

С помощью методов раздела Заказы FBS (Fulfillment by Seller) вы можете: получать информацию о [сборочных заданиях](https://dev.wildberries.ru/openapi/orders-fbs#tag/fbsAssemblyOrders) и их статусах, отменять сборочные задания, получать с…

**Reference:** https://dev.wildberries.ru/openapi/orders-fbs

**APIs:** `DefaultApi`, `FBSAPI`

```go
import wborders_fbs "github.com/ValeryVerkhoturov/wb-api-client/clients/go/orders_fbs"

cfg := wborders_fbs.NewConfiguration()
cfg.SetAccessToken("<your WB JWT>")
client := wborders_fbs.NewAPIClient(cfg)
```

### orders-dbw — Заказы DBW

С помощью методов Заказы DBW (Деливери WB) вы можете: получать информацию о [сборочных заданиях](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwAssemblyOrders), управлять статусами и отменять сборочные задания получать, добавлять,…

**Reference:** https://dev.wildberries.ru/openapi/orders-dbw

**APIs:** `DBWAPI`

```go
import wborders_dbw "github.com/ValeryVerkhoturov/wb-api-client/clients/go/orders_dbw"

cfg := wborders_dbw.NewConfiguration()
cfg.SetAccessToken("<your WB JWT>")
client := wborders_dbw.NewAPIClient(cfg)
```

### dbs — DBS

Узнать больше о модели DBS можно в [справочном центре](https://seller.wildberries.ru/instructions/category/6572e024-7428-4db1-86a8-a4c7dbebbfcf?goBackOption=prevRoute&categoryId=5a8e1202-0865-45b7-acae-5d0afc7add56)

**Reference:** https://dev.wildberries.ru/openapi/dbs

**APIs:** `DBSAPI`

```go
import wbdbs "github.com/ValeryVerkhoturov/wb-api-client/clients/go/dbs"

cfg := wbdbs.NewConfiguration()
cfg.SetAccessToken("<your WB JWT>")
client := wbdbs.NewAPIClient(cfg)
```

### in-store-pickup — Самовывоз

Управление [сборочными заданиями](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders) и [идентификаторами маркировки](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers) С…

**Reference:** https://dev.wildberries.ru/openapi/in-store-pickup

**APIs:** `DefaultApi`

```go
import wbin_store_pickup "github.com/ValeryVerkhoturov/wb-api-client/clients/go/in_store_pickup"

cfg := wbin_store_pickup.NewConfiguration()
cfg.SetAccessToken("<your WB JWT>")
client := wbin_store_pickup.NewAPIClient(cfg)
```

### orders-fbw — Поставки FBW

Узнать больше о поставках FBW можно в [справочном центре](https://seller.wildberries.ru/instructions/subcategory/5a8e1202-0865-45b7-acae-5d0afc7add56?goBackOption=prevRoute&categoryId=479385c6-de01-4b4d-ad4e-ed941e65582e)

**Reference:** https://dev.wildberries.ru/openapi/orders-fbw

**APIs:** `DefaultApi`

```go
import wborders_fbw "github.com/ValeryVerkhoturov/wb-api-client/clients/go/orders_fbw"

cfg := wborders_fbw.NewConfiguration()
cfg.SetAccessToken("<your WB JWT>")
client := wborders_fbw.NewAPIClient(cfg)
```

### promotion — Маркетинг и продвижение

Узнать больше о маркетинге и продвижении можно в [справочном центре](https://seller.wildberries.ru/instructions/category/59d92bd3-6ea0-40f2-b762-ca8835d7d42e?goBackOption=prevRoute&categoryId=479385c6-de01-4b4d-ad4e-ed941e65582e)

**Reference:** https://dev.wildberries.ru/openapi/promotion

**APIs:** `DefaultApi`

```go
import wbpromotion "github.com/ValeryVerkhoturov/wb-api-client/clients/go/promotion"

cfg := wbpromotion.NewConfiguration()
cfg.SetAccessToken("<your WB JWT>")
client := wbpromotion.NewAPIClient(cfg)
```

### communications — Общение с покупателями

Узнать больше об общении с покупателями можно в [справочном центре](https://seller.wildberries.ru/instructions/category/f7f6c465-dd12-422d-80a0-a6d9562115d5?goBackOption=prevRoute&categoryId=30817062-14cc-4a82-bc78-3600c2b0685b)

**Reference:** https://dev.wildberries.ru/openapi/customer-communication

**APIs:** `DefaultApi`

```go
import wbcommunications "github.com/ValeryVerkhoturov/wb-api-client/clients/go/communications"

cfg := wbcommunications.NewConfiguration()
cfg.SetAccessToken("<your WB JWT>")
client := wbcommunications.NewAPIClient(cfg)
```

### rates — Тарифы

Узнать больше о тарифах можно в [справочном центре](https://seller.wildberries.ru/instructions/ru/ru/material/fees-site-section)

**Reference:** https://dev.wildberries.ru/openapi/rates

**APIs:** `DefaultApi`

```go
import wbrates "github.com/ValeryVerkhoturov/wb-api-client/clients/go/rates"

cfg := wbrates.NewConfiguration()
cfg.SetAccessToken("<your WB JWT>")
client := wbrates.NewAPIClient(cfg)
```

### analytics — Аналитика и данные

Узнать больше об аналитике и данных можно в [справочном центре](https://seller.wildberries.ru/instructions/ru/ru/subcategory/seller-analytics)

**Reference:** https://dev.wildberries.ru/openapi/analytics

**APIs:** `CSVAPI`, `DefaultApi`

```go
import wbanalytics "github.com/ValeryVerkhoturov/wb-api-client/clients/go/analytics"

cfg := wbanalytics.NewConfiguration()
cfg.SetAccessToken("<your WB JWT>")
client := wbanalytics.NewAPIClient(cfg)
```

### reports — Отчёты

Узнать больше об отчётах можно в [справочном центре](https://seller.wildberries.ru/instructions/subcategory/5f2162c5-069b-416d-a4e1-48da2a76e6b0)

**Reference:** https://dev.wildberries.ru/openapi/reports

**APIs:** `CAPI`, `DefaultApi`

```go
import wbreports "github.com/ValeryVerkhoturov/wb-api-client/clients/go/reports"

cfg := wbreports.NewConfiguration()
cfg.SetAccessToken("<your WB JWT>")
client := wbreports.NewAPIClient(cfg)
```

### finances — Документы и бухгалтерия

Узнать больше о документах и бухгалтерии можно в [справочном центре](https://seller.wildberries.ru/instructions/category/ba929b64-1f89-4426-82d7-ce998ee552bd?goBackOption=prevRoute&categoryId=3c971375-9939-45e8-ab82-376019be8942)

**Reference:** https://dev.wildberries.ru/openapi/documents-and-accounting

**APIs:** `DefaultApi`

```go
import wbfinances "github.com/ValeryVerkhoturov/wb-api-client/clients/go/finances"

cfg := wbfinances.NewConfiguration()
cfg.SetAccessToken("<your WB JWT>")
client := wbfinances.NewAPIClient(cfg)
```

