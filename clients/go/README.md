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

В этом разделе:
- [общая информация о WB API](https://dev.wildberries.ru/openapi/api-information#tag/introduction)
- как [начать работу с WB API](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Kak-nachat-rabotu-s-API)
- как [авторизоваться](https://dev.wildberries.ru/openapi/api-information#tag/authorization) и [создавать токены](https://dev.wildberries.ru/openapi/api-information#tag/authorization/Kak-sozdat-personalnyj-bazovyj-ili-testovyj-token)
- основные [статус-коды ответов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Status-kody-HTTP)
- [лимиты запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov)
- как обратиться в [поддержку](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Podderzhka)
С помощью методов этого раздела вы можете:
- проверить [подключение к WB API](https://dev.wildberries.ru/openapi/api-information#tag/connectionCheck/operation/getPing)
- получить [новости портала продавцов](https://dev.wildberries.ru/openapi/api-information#tag/newsApi/operation/getV2News)
- получить [информацию о продавце](https://dev.wildberries.ru/openapi/api-information#tag/sellerInformation/operation/getV1SellerInfo)
- [управлять пользователями продавца](https://dev.wildberries.ru/openapi/api-information#tag/sellerUserManagement)

**Reference:** https://dev.wildberries.ru/openapi/api-information

**APIs:** `APIAPI`, `DefaultApi`, `WBAPIAPI`

```go
import wbgeneral "github.com/ValeryVerkhoturov/wb-api-client/clients/go/general"

cfg := wbgeneral.NewConfiguration()
cfg.SetAccessToken("<your WB JWT>")
client := wbgeneral.NewAPIClient(cfg)
```

### items — Работа с товарами

С помощью методов этого раздела вы можете:
- [создавать](https://dev.wildberries.ru/openapi/item-management#tag/listingItems) и [редактировать](https://dev.wildberries.ru/openapi/item-management#tag/listings) карточки товаров
- получать [категории, предметы, характеристики и бренды товаров](https://dev.wildberries.ru/openapi/item-management#tag/categoriesSubcategoriesAndCharacteristics)
- загружать [медиафайлы](https://dev.wildberries.ru/openapi/item-management#tag/mediaFiles) в карточки товаров
- настраивать [ярлыки](https://dev.wildberries.ru/openapi/item-management#tag/labels) для поиска товаров
- работать с [рекомендациями](https://dev.wildberries.ru/openapi/item-management#tag/recommendations) для товаров
- устанавливать [цены и скидки](https://dev.wildberries.ru/openapi/item-management#tag/pricesAndDiscounts)
- управлять [остатками товаров](https://dev.wildberries.ru/openapi/item-management#tag/sellerWarehousesInventory) и [складами](https://dev.wildberries.ru/openapi/item-management#tag/sellerWarehouses), если вы работаете по модели продаж со склада продавца
Вы можете протестировать методы работы с товарами в [песочнице](https://dev.wildberries.ru/sandbox). Также в песочнице доступны [специальные методы](https://dev.wildberries.ru/docs/openapi-other/sandbox-environment#tag/itemManagement) для управления карточками товаров

Узнать, как использовать методы в бизнес-кейсах, можно в [инструкции](https://dev.wildberries.ru/knowledge-base/articles/019d49a4-1320-71bb-9dac-8ba07e7177ce/rabota-s-tovarami) по **работе с товарами**

**Reference:** https://dev.wildberries.ru/openapi/item-management

**APIs:** `DefaultApi`

```go
import wbitems "github.com/ValeryVerkhoturov/wb-api-client/clients/go/items"

cfg := wbitems.NewConfiguration()
cfg.SetAccessToken("<your WB JWT>")
client := wbitems.NewAPIClient(cfg)
```

### orders-fbs — Заказы FBS

С помощью методов раздела Заказы FBS (Fulfillment by Seller) вы можете:
- получать информацию о [сборочных заданиях](https://dev.wildberries.ru/openapi/orders-fbs#tag/fbsAssemblyOrders) и их статусах, отменять сборочные задания, получать стикеры
- добавлять, редактировать и удалять [идентификаторы маркировки](https://dev.wildberries.ru/openapi/orders-fbs#tag/fbsLabelIdentifiers) сборочных заданий
- управлять [поставками](https://dev.wildberries.ru/openapi/orders-fbs#tag/fbsSupplies)
- создавать, редактировать и удалять [пропуска](https://dev.wildberries.ru/openapi/orders-fbs#tag/fbsPasses) на склады WB
Вы можете протестировать методы заказов FBS в [песочнице](https://dev.wildberries.ru/sandbox). Также в песочнице доступны [специальные методы](https://dev.wildberries.ru/docs/openapi-other/sandbox-environment#tag/marketplaceFbs) для эмуляции действий пользователя

Узнать, как использовать методы в бизнес-кейсах, можно в [инструкции](https://dev.wildberries.ru/knowledge-base/articles/019d49a4-0771-7571-aea9-11d5b597f34c/zakazy-fbs) по работе с **заказами FBS**

Узнать больше о заказах FBS можно в [справочном центре](https://seller.wildberries.ru/instructions/ru/ru/category/b3e60238-fd4c-49ce-8668-ff688725a12d)

**Reference:** https://dev.wildberries.ru/openapi/orders-fbs

**APIs:** `DefaultApi`, `FBSAPI`

```go
import wborders_fbs "github.com/ValeryVerkhoturov/wb-api-client/clients/go/orders_fbs"

cfg := wborders_fbs.NewConfiguration()
cfg.SetAccessToken("<your WB JWT>")
client := wborders_fbs.NewAPIClient(cfg)
```

### orders-dbw — Заказы DBW

С помощью методов Заказы DBW (Деливери WB) вы можете:
- получать информацию о [сборочных заданиях](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwAssemblyOrders), управлять статусами и отменять сборочные задания
- получать, добавлять, редактировать и удалять [метаданные](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwLabelIdentifiers) сборочных заданий

Узнать, как использовать методы в бизнес-кейсах, можно в [инструкции](https://dev.wildberries.ru/knowledge-base/articles/019d49a4-036a-7721-98e8-bed5f1a4f72d/zakazy-dbw) по работе с **заказами DBW**

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

Управление [сборочными заданиями](https://dev.wildberries.ru/openapi/dbs#tag/dbsAssemblyOrders) и [идентификаторами маркировки](https://dev.wildberries.ru/openapi/dbs#tag/dbsLabelIdentifiers) DBS (Delivery by Seller).

Вы можете протестировать методы DBS в [песочнице](https://dev.wildberries.ru/sandbox). Также в песочнице доступны [специальные методы](https://dev.wildberries.ru/docs/openapi-other/sandbox-environment#tag/marketplaceDbs) для эмуляции действий пользователя

**Reference:** https://dev.wildberries.ru/openapi/dbs

**APIs:** `DBSAPI`

```go
import wbdbs "github.com/ValeryVerkhoturov/wb-api-client/clients/go/dbs"

cfg := wbdbs.NewConfiguration()
cfg.SetAccessToken("<your WB JWT>")
client := wbdbs.NewAPIClient(cfg)
```

### in-store-pickup — Самовывоз

Управление [сборочными заданиями](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders) и [идентификаторами маркировки](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers) Самовывоза.

Вы можете протестировать методы Самовывоза в [песочнице](https://dev.wildberries.ru/sandbox). Также в песочнице доступны [специальные методы](https://dev.wildberries.ru/docs/openapi-other/sandbox-environment#tag/marketplaceInStorePickup) для эмуляции действий пользователя

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

В разделе описаны методы получения:
- [информации для формирования поставок](https://dev.wildberries.ru/openapi/orders-fbw#tag/informationForFormingSupplies)
- [информации о поставках](https://dev.wildberries.ru/openapi/orders-fbw#tag/suppliesInformation)
Вы можете создавать карточки товара в песочнице [Контента](https://dev.wildberries.ru/openapi/api-information#tag/authorization/Kategorii-tokenov), а потом использовать баркоды товаров в [песочнице](https://dev.wildberries.ru/sandbox) Поставок

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

Методы маркетинга и продвижения позволяют:
1. Получать информацию о кампаниях [продвижения](https://dev.wildberries.ru/openapi/promotion#tag/campaigns) и [медиакампаниях](https://dev.wildberries.ru/openapi/promotion#tag/media)
2. [Создавать](https://dev.wildberries.ru/openapi/promotion#tag/creatingCampaigns) и [управлять](https://dev.wildberries.ru/openapi/promotion#tag/campaignManagement) кампаниями
3. Управлять [финансами](https://dev.wildberries.ru/openapi/promotion#tag/finances) кампаний
4. Выгружать [статистику](https://dev.wildberries.ru/openapi/promotion#tag/statistics) кампаний продвижения и медиакампаний
5. Работать с [календарём акций](https://dev.wildberries.ru/openapi/promotion#tag/promoCalendar)
Данные синхронизируются с базой раз в 3 минуты. Статусы кампаний меняются раз в минуту. Ставки кампаний меняются раз в 30 секунд.

Вы можете протестировать методы продвижения в [песочнице](https://dev.wildberries.ru/sandbox). Также в песочнице доступны [специальные методы](https://dev.wildberries.ru/docs/openapi-other/sandbox-environment#tag/promotion) для управления тестовым балансом

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

С помощью методов общения с покупателями вы можете работать с:
1. [Вопросами](https://dev.wildberries.ru/openapi/customer-communication#tag/questions) и [отзывами](https://dev.wildberries.ru/openapi/customer-communication#tag/feedbacks) покупателей
2. [Закреплёнными отзывами](https://dev.wildberries.ru/openapi/customer-communication#tag/pinnedFeedbacks)
3. [Чатами с покупателями](https://dev.wildberries.ru/openapi/customer-communication#tag/buyersChat)
4. [Заявками покупателей на возврат](https://dev.wildberries.ru/openapi/customer-communication#tag/buyersReturns)
Вы можете протестировать методы общения с покупателями в [песочнице](https://dev.wildberries.ru/sandbox). Также в песочнице доступны [специальные методы](https://dev.wildberries.ru/docs/openapi-other/sandbox-environment#tag/questionsAndFeedbacks) для управления тестовыми вопросами и отзывами

Узнать, как использовать методы в бизнес-кейсах, можно в [инструкции](https://dev.wildberries.ru/knowledge-base/articles/019d49a4-0b26-7620-8d0b-e3050b7cd01d/obshchenie-s-pokupateliami) по работе с разделом **Общение с покупателями**

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

В разделе описаны методы получения:
1. [Комиссий](https://dev.wildberries.ru/openapi/rates#tag/fees)
2. [Тарифов на поставку](https://dev.wildberries.ru/openapi/rates#tag/supplyRates)
3. [Тарифов на остаток](https://dev.wildberries.ru/openapi/rates#tag/stockRates)
4. [Тарифов на возврат товаров продавцу](https://dev.wildberries.ru/openapi/rates#tag/returnCostToSeller)

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

В разделе описаны методы получения:
1. [Воронки продаж](https://dev.wildberries.ru/openapi/analytics#tag/salesFunnel)
2. [Ленты заказов](https://dev.wildberries.ru/openapi/analytics#tag/orderFeed)
3. [Поисковых запросов по вашим товарам](https://dev.wildberries.ru/openapi/analytics#tag/searchQueriesForYourItems)
4. [Истории остатков](https://dev.wildberries.ru/openapi/analytics#tag/stocksReport)
5. [Оценки товара](https://dev.wildberries.ru/openapi/analytics#tag/itemRating)
6. [Аналитики продавца в формате CSV](https://dev.wildberries.ru/openapi/analytics#tag/sellerAnalyticsCsv)

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

С помощью этих методов вы можете получать [основные отчёты](https://dev.wildberries.ru/openapi/reports#tag/mainReports) и отчёты о:
1. [Остатках на складах](https://dev.wildberries.ru/openapi/reports#tag/warehousesInventoryReport)
2. [Товарах с обязательной маркировкой](https://dev.wildberries.ru/openapi/reports#tag/reportOnItemsWithMandatoryLabeling)
3. [Удержаниях](https://dev.wildberries.ru/openapi/reports#tag/retentionReports)
4. [Операциях при приёмке](https://dev.wildberries.ru/openapi/reports#tag/acceptanceExpenses)
5. [Платном хранении](https://dev.wildberries.ru/openapi/reports#tag/paidStorage)
6. [Продажах по регионам](https://dev.wildberries.ru/openapi/reports#tag/salesByRegions)
7. [Доле бренда в продажах](https://dev.wildberries.ru/openapi/reports#tag/shareOfBrandInSales)
8. [Заблокированных карточках](https://dev.wildberries.ru/openapi/reports#tag/blockedItems)
9. [Возвратах и перемещении товаров](https://dev.wildberries.ru/openapi/reports#tag/returnsAndItemMovementReport)

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

Просмотр [баланса](https://dev.wildberries.ru/openapi/documents-and-accounting#tag/balance), [финансовых отчётов](https://dev.wildberries.ru/openapi/documents-and-accounting#tag/financialReports) и [документов](https://dev.wildberries.ru/openapi/documents-and-accounting#tag/documents) продавца.

**Reference:** https://dev.wildberries.ru/openapi/documents-and-accounting

**APIs:** `DefaultApi`

```go
import wbfinances "github.com/ValeryVerkhoturov/wb-api-client/clients/go/finances"

cfg := wbfinances.NewConfiguration()
cfg.SetAccessToken("<your WB JWT>")
client := wbfinances.NewAPIClient(cfg)
```

