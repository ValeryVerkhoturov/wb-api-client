# wb-api-client — Java

Auto-generated Java client for the [Wildberries Seller API](https://dev.wildberries.ru/). One package, thirteen sub-modules — one per API category. This README is regenerated on every release, so it always matches the code in this tree.

## Install

```bash
<dependency>
  <groupId>io.github.valeryverkhoturov</groupId>
  <artifactId>wb-api-client</artifactId>
  <version>0.0.0.dev0</version>
</dependency>
```

## Authentication

Every module accepts the same WB bearer JWT. The token is stored in a redacting wrapper — a per-sub-module `SecretString` class — so it does not leak under logs / `System.out.println` unless you explicitly ask for the raw value with `.exposeSecret()`.

```java
import io.github.valeryverkhoturov.wbapi.items.ApiClient;
import io.github.valeryverkhoturov.wbapi.items.SecretString;

ApiClient client = new ApiClient();
client.setBearerToken(new SecretString("<your WB JWT>"));
```

## Modules

Each row below is a sub-module you can import independently. Import path is `io.github.valeryverkhoturov.wbapi.<slug>`.

| Slug | Category | APIs |
|---|---|---|
| [`general`](https://dev.wildberries.ru/openapi/api-information) | Общее | `ApiApi`, `DefaultApi`, `WbApiApi` |
| [`items`](https://dev.wildberries.ru/openapi/item-management) | Работа с товарами | `DefaultApi` |
| [`orders-fbs`](https://dev.wildberries.ru/openapi/orders-fbs) | Заказы FBS | `DefaultApi`, `FbsApi` |
| [`orders-dbw`](https://dev.wildberries.ru/openapi/orders-dbw) | Заказы DBW | `DbwApi` |
| [`dbs`](https://dev.wildberries.ru/openapi/dbs) | DBS | `DbsApi` |
| [`in-store-pickup`](https://dev.wildberries.ru/openapi/in-store-pickup) | Самовывоз | `DefaultApi` |
| [`orders-fbw`](https://dev.wildberries.ru/openapi/orders-fbw) | Поставки FBW | `DefaultApi` |
| [`promotion`](https://dev.wildberries.ru/openapi/promotion) | Маркетинг и продвижение | `DefaultApi` |
| [`communications`](https://dev.wildberries.ru/openapi/customer-communication) | Общение с покупателями | `DefaultApi` |
| [`rates`](https://dev.wildberries.ru/openapi/rates) | Тарифы | `DefaultApi` |
| [`analytics`](https://dev.wildberries.ru/openapi/analytics) | Аналитика и данные | `CsvApi`, `DefaultApi` |
| [`reports`](https://dev.wildberries.ru/openapi/reports) | Отчёты | `CApi`, `DefaultApi` |
| [`finances`](https://dev.wildberries.ru/openapi/documents-and-accounting) | Документы и бухгалтерия | `DefaultApi` |

## Per-module usage

### general — Общее

В этом разделе: [общая информация о WB API](https://dev.wildberries.ru/openapi/api-information#tag/introduction) как [начать работу с WB API](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Kak-nachat-rabotu-s-API) ка…

**Reference:** https://dev.wildberries.ru/openapi/api-information

**APIs:** `ApiApi`, `DefaultApi`, `WbApiApi`

```java
import io.github.valeryverkhoturov.wbapi.general.ApiClient;
import io.github.valeryverkhoturov.wbapi.general.SecretString;
import io.github.valeryverkhoturov.wbapi.general.api.ApiApi;

ApiClient client = new ApiClient();
client.setBearerToken(new SecretString("<your WB JWT>"));
ApiApi api = new ApiApi(client);
```

### items — Работа с товарами

С помощью методов этого раздела вы можете: [создавать](https://dev.wildberries.ru/openapi/item-management#tag/listingItems) и [редактировать](https://dev.wildberries.ru/openapi/item-management#tag/listings) карточки товаров получать [кат…

**Reference:** https://dev.wildberries.ru/openapi/item-management

**APIs:** `DefaultApi`

```java
import io.github.valeryverkhoturov.wbapi.items.ApiClient;
import io.github.valeryverkhoturov.wbapi.items.SecretString;
import io.github.valeryverkhoturov.wbapi.items.api.DefaultApi;

ApiClient client = new ApiClient();
client.setBearerToken(new SecretString("<your WB JWT>"));
DefaultApi api = new DefaultApi(client);
```

### orders-fbs — Заказы FBS

С помощью методов раздела Заказы FBS (Fulfillment by Seller) вы можете: получать информацию о [сборочных заданиях](https://dev.wildberries.ru/openapi/orders-fbs#tag/fbsAssemblyOrders) и их статусах, отменять сборочные задания, получать с…

**Reference:** https://dev.wildberries.ru/openapi/orders-fbs

**APIs:** `DefaultApi`, `FbsApi`

```java
import io.github.valeryverkhoturov.wbapi.orders_fbs.ApiClient;
import io.github.valeryverkhoturov.wbapi.orders_fbs.SecretString;
import io.github.valeryverkhoturov.wbapi.orders_fbs.api.DefaultApi;

ApiClient client = new ApiClient();
client.setBearerToken(new SecretString("<your WB JWT>"));
DefaultApi api = new DefaultApi(client);
```

### orders-dbw — Заказы DBW

С помощью методов Заказы DBW (Деливери WB) вы можете: получать информацию о [сборочных заданиях](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwAssemblyOrders), управлять статусами и отменять сборочные задания получать, добавлять,…

**Reference:** https://dev.wildberries.ru/openapi/orders-dbw

**APIs:** `DbwApi`

```java
import io.github.valeryverkhoturov.wbapi.orders_dbw.ApiClient;
import io.github.valeryverkhoturov.wbapi.orders_dbw.SecretString;
import io.github.valeryverkhoturov.wbapi.orders_dbw.api.DbwApi;

ApiClient client = new ApiClient();
client.setBearerToken(new SecretString("<your WB JWT>"));
DbwApi api = new DbwApi(client);
```

### dbs — DBS

Узнать больше о модели DBS можно в [справочном центре](https://seller.wildberries.ru/instructions/category/6572e024-7428-4db1-86a8-a4c7dbebbfcf?goBackOption=prevRoute&categoryId=5a8e1202-0865-45b7-acae-5d0afc7add56)

**Reference:** https://dev.wildberries.ru/openapi/dbs

**APIs:** `DbsApi`

```java
import io.github.valeryverkhoturov.wbapi.dbs.ApiClient;
import io.github.valeryverkhoturov.wbapi.dbs.SecretString;
import io.github.valeryverkhoturov.wbapi.dbs.api.DbsApi;

ApiClient client = new ApiClient();
client.setBearerToken(new SecretString("<your WB JWT>"));
DbsApi api = new DbsApi(client);
```

### in-store-pickup — Самовывоз

Управление [сборочными заданиями](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders) и [идентификаторами маркировки](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers) С…

**Reference:** https://dev.wildberries.ru/openapi/in-store-pickup

**APIs:** `DefaultApi`

```java
import io.github.valeryverkhoturov.wbapi.in_store_pickup.ApiClient;
import io.github.valeryverkhoturov.wbapi.in_store_pickup.SecretString;
import io.github.valeryverkhoturov.wbapi.in_store_pickup.api.DefaultApi;

ApiClient client = new ApiClient();
client.setBearerToken(new SecretString("<your WB JWT>"));
DefaultApi api = new DefaultApi(client);
```

### orders-fbw — Поставки FBW

Узнать больше о поставках FBW можно в [справочном центре](https://seller.wildberries.ru/instructions/subcategory/5a8e1202-0865-45b7-acae-5d0afc7add56?goBackOption=prevRoute&categoryId=479385c6-de01-4b4d-ad4e-ed941e65582e)

**Reference:** https://dev.wildberries.ru/openapi/orders-fbw

**APIs:** `DefaultApi`

```java
import io.github.valeryverkhoturov.wbapi.orders_fbw.ApiClient;
import io.github.valeryverkhoturov.wbapi.orders_fbw.SecretString;
import io.github.valeryverkhoturov.wbapi.orders_fbw.api.DefaultApi;

ApiClient client = new ApiClient();
client.setBearerToken(new SecretString("<your WB JWT>"));
DefaultApi api = new DefaultApi(client);
```

### promotion — Маркетинг и продвижение

Узнать больше о маркетинге и продвижении можно в [справочном центре](https://seller.wildberries.ru/instructions/category/59d92bd3-6ea0-40f2-b762-ca8835d7d42e?goBackOption=prevRoute&categoryId=479385c6-de01-4b4d-ad4e-ed941e65582e)

**Reference:** https://dev.wildberries.ru/openapi/promotion

**APIs:** `DefaultApi`

```java
import io.github.valeryverkhoturov.wbapi.promotion.ApiClient;
import io.github.valeryverkhoturov.wbapi.promotion.SecretString;
import io.github.valeryverkhoturov.wbapi.promotion.api.DefaultApi;

ApiClient client = new ApiClient();
client.setBearerToken(new SecretString("<your WB JWT>"));
DefaultApi api = new DefaultApi(client);
```

### communications — Общение с покупателями

Узнать больше об общении с покупателями можно в [справочном центре](https://seller.wildberries.ru/instructions/category/f7f6c465-dd12-422d-80a0-a6d9562115d5?goBackOption=prevRoute&categoryId=30817062-14cc-4a82-bc78-3600c2b0685b)

**Reference:** https://dev.wildberries.ru/openapi/customer-communication

**APIs:** `DefaultApi`

```java
import io.github.valeryverkhoturov.wbapi.communications.ApiClient;
import io.github.valeryverkhoturov.wbapi.communications.SecretString;
import io.github.valeryverkhoturov.wbapi.communications.api.DefaultApi;

ApiClient client = new ApiClient();
client.setBearerToken(new SecretString("<your WB JWT>"));
DefaultApi api = new DefaultApi(client);
```

### rates — Тарифы

Узнать больше о тарифах можно в [справочном центре](https://seller.wildberries.ru/instructions/ru/ru/material/fees-site-section)

**Reference:** https://dev.wildberries.ru/openapi/rates

**APIs:** `DefaultApi`

```java
import io.github.valeryverkhoturov.wbapi.rates.ApiClient;
import io.github.valeryverkhoturov.wbapi.rates.SecretString;
import io.github.valeryverkhoturov.wbapi.rates.api.DefaultApi;

ApiClient client = new ApiClient();
client.setBearerToken(new SecretString("<your WB JWT>"));
DefaultApi api = new DefaultApi(client);
```

### analytics — Аналитика и данные

Узнать больше об аналитике и данных можно в [справочном центре](https://seller.wildberries.ru/instructions/ru/ru/subcategory/seller-analytics)

**Reference:** https://dev.wildberries.ru/openapi/analytics

**APIs:** `CsvApi`, `DefaultApi`

```java
import io.github.valeryverkhoturov.wbapi.analytics.ApiClient;
import io.github.valeryverkhoturov.wbapi.analytics.SecretString;
import io.github.valeryverkhoturov.wbapi.analytics.api.CsvApi;

ApiClient client = new ApiClient();
client.setBearerToken(new SecretString("<your WB JWT>"));
CsvApi api = new CsvApi(client);
```

### reports — Отчёты

Узнать больше об отчётах можно в [справочном центре](https://seller.wildberries.ru/instructions/subcategory/5f2162c5-069b-416d-a4e1-48da2a76e6b0)

**Reference:** https://dev.wildberries.ru/openapi/reports

**APIs:** `CApi`, `DefaultApi`

```java
import io.github.valeryverkhoturov.wbapi.reports.ApiClient;
import io.github.valeryverkhoturov.wbapi.reports.SecretString;
import io.github.valeryverkhoturov.wbapi.reports.api.CApi;

ApiClient client = new ApiClient();
client.setBearerToken(new SecretString("<your WB JWT>"));
CApi api = new CApi(client);
```

### finances — Документы и бухгалтерия

Узнать больше о документах и бухгалтерии можно в [справочном центре](https://seller.wildberries.ru/instructions/category/ba929b64-1f89-4426-82d7-ce998ee552bd?goBackOption=prevRoute&categoryId=3c971375-9939-45e8-ab82-376019be8942)

**Reference:** https://dev.wildberries.ru/openapi/documents-and-accounting

**APIs:** `DefaultApi`

```java
import io.github.valeryverkhoturov.wbapi.finances.ApiClient;
import io.github.valeryverkhoturov.wbapi.finances.SecretString;
import io.github.valeryverkhoturov.wbapi.finances.api.DefaultApi;

ApiClient client = new ApiClient();
client.setBearerToken(new SecretString("<your WB JWT>"));
DefaultApi api = new DefaultApi(client);
```

