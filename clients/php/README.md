# wb-api-client — PHP

Auto-generated PHP client for the [Wildberries Seller API](https://dev.wildberries.ru/). One package, thirteen sub-modules — one per API category. This README is regenerated on every release, so it always matches the code in this tree.

## Install

```bash
composer require valeryverkhoturov/wb-api-client
```

## Authentication

Every module accepts the same WB bearer JWT. The token is stored in a redacting wrapper — a per-sub-module `SecretString` class — so it does not leak under logs / `var_dump` unless you explicitly ask for the raw value with `->exposeSecret()`.

```php
use ValeryVerkhoturov\WbApiClient\Items\Configuration;
use ValeryVerkhoturov\WbApiClient\Items\SecretString;

$config = (new Configuration())
    ->setAccessTokenSecret(new SecretString('<your WB JWT>'));
```

## Modules

Each row below is a sub-module you can import independently. Import path is `ValeryVerkhoturov\\WbApiClient\\<slug>`.

| Slug | Category | APIs |
|---|---|---|
| [`general`](https://dev.wildberries.ru/openapi/api-information) | Общее | `APIApi`, `DefaultApi`, `WBAPIApi` |
| [`items`](https://dev.wildberries.ru/openapi/item-management) | Работа с товарами | `DefaultApi` |
| [`orders-fbs`](https://dev.wildberries.ru/openapi/orders-fbs) | Заказы FBS | `DefaultApi`, `FBSApi` |
| [`orders-dbw`](https://dev.wildberries.ru/openapi/orders-dbw) | Заказы DBW | `DBWApi` |
| [`dbs`](https://dev.wildberries.ru/openapi/dbs) | DBS | `DBSApi` |
| [`in-store-pickup`](https://dev.wildberries.ru/openapi/in-store-pickup) | Самовывоз | `DefaultApi` |
| [`orders-fbw`](https://dev.wildberries.ru/openapi/orders-fbw) | Поставки FBW | `DefaultApi` |
| [`promotion`](https://dev.wildberries.ru/openapi/promotion) | Маркетинг и продвижение | `DefaultApi` |
| [`communications`](https://dev.wildberries.ru/openapi/customer-communication) | Общение с покупателями | `DefaultApi` |
| [`rates`](https://dev.wildberries.ru/openapi/rates) | Тарифы | `DefaultApi` |
| [`analytics`](https://dev.wildberries.ru/openapi/analytics) | Аналитика и данные | `CSVApi`, `DefaultApi` |
| [`reports`](https://dev.wildberries.ru/openapi/reports) | Отчёты | `CApi`, `DefaultApi` |
| [`finances`](https://dev.wildberries.ru/openapi/documents-and-accounting) | Документы и бухгалтерия | `DefaultApi` |

## Per-module usage

### general — Общее

В этом разделе: [общая информация о WB API](https://dev.wildberries.ru/openapi/api-information#tag/introduction) как [начать работу с WB API](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Kak-nachat-rabotu-s-API) ка…

**Reference:** https://dev.wildberries.ru/openapi/api-information

**APIs:** `APIApi`, `DefaultApi`, `WBAPIApi`

```php
use ValeryVerkhoturov\WbApiClient\General\Configuration;
use ValeryVerkhoturov\WbApiClient\General\SecretString;
use ValeryVerkhoturov\WbApiClient\General\Api\APIApi;
use GuzzleHttp\Client;

$config = (new Configuration())
    ->setAccessTokenSecret(new SecretString('<your WB JWT>'));
$api = new APIApi(new Client(), $config);
```

### items — Работа с товарами

С помощью методов этого раздела вы можете: [создавать](https://dev.wildberries.ru/openapi/item-management#tag/listingItems) и [редактировать](https://dev.wildberries.ru/openapi/item-management#tag/listings) карточки товаров получать [кат…

**Reference:** https://dev.wildberries.ru/openapi/item-management

**APIs:** `DefaultApi`

```php
use ValeryVerkhoturov\WbApiClient\Items\Configuration;
use ValeryVerkhoturov\WbApiClient\Items\SecretString;
use ValeryVerkhoturov\WbApiClient\Items\Api\DefaultApi;
use GuzzleHttp\Client;

$config = (new Configuration())
    ->setAccessTokenSecret(new SecretString('<your WB JWT>'));
$api = new DefaultApi(new Client(), $config);
```

### orders-fbs — Заказы FBS

С помощью методов раздела Заказы FBS (Fulfillment by Seller) вы можете: получать информацию о [сборочных заданиях](https://dev.wildberries.ru/openapi/orders-fbs#tag/fbsAssemblyOrders) и их статусах, отменять сборочные задания, получать с…

**Reference:** https://dev.wildberries.ru/openapi/orders-fbs

**APIs:** `DefaultApi`, `FBSApi`

```php
use ValeryVerkhoturov\WbApiClient\OrdersFbs\Configuration;
use ValeryVerkhoturov\WbApiClient\OrdersFbs\SecretString;
use ValeryVerkhoturov\WbApiClient\OrdersFbs\Api\DefaultApi;
use GuzzleHttp\Client;

$config = (new Configuration())
    ->setAccessTokenSecret(new SecretString('<your WB JWT>'));
$api = new DefaultApi(new Client(), $config);
```

### orders-dbw — Заказы DBW

С помощью методов Заказы DBW (Деливери WB) вы можете: получать информацию о [сборочных заданиях](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwAssemblyOrders), управлять статусами и отменять сборочные задания получать, добавлять,…

**Reference:** https://dev.wildberries.ru/openapi/orders-dbw

**APIs:** `DBWApi`

```php
use ValeryVerkhoturov\WbApiClient\OrdersDbw\Configuration;
use ValeryVerkhoturov\WbApiClient\OrdersDbw\SecretString;
use ValeryVerkhoturov\WbApiClient\OrdersDbw\Api\DBWApi;
use GuzzleHttp\Client;

$config = (new Configuration())
    ->setAccessTokenSecret(new SecretString('<your WB JWT>'));
$api = new DBWApi(new Client(), $config);
```

### dbs — DBS

Узнать больше о модели DBS можно в [справочном центре](https://seller.wildberries.ru/instructions/category/6572e024-7428-4db1-86a8-a4c7dbebbfcf?goBackOption=prevRoute&categoryId=5a8e1202-0865-45b7-acae-5d0afc7add56)

**Reference:** https://dev.wildberries.ru/openapi/dbs

**APIs:** `DBSApi`

```php
use ValeryVerkhoturov\WbApiClient\Dbs\Configuration;
use ValeryVerkhoturov\WbApiClient\Dbs\SecretString;
use ValeryVerkhoturov\WbApiClient\Dbs\Api\DBSApi;
use GuzzleHttp\Client;

$config = (new Configuration())
    ->setAccessTokenSecret(new SecretString('<your WB JWT>'));
$api = new DBSApi(new Client(), $config);
```

### in-store-pickup — Самовывоз

Управление [сборочными заданиями](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders) и [идентификаторами маркировки](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers) С…

**Reference:** https://dev.wildberries.ru/openapi/in-store-pickup

**APIs:** `DefaultApi`

```php
use ValeryVerkhoturov\WbApiClient\InStorePickup\Configuration;
use ValeryVerkhoturov\WbApiClient\InStorePickup\SecretString;
use ValeryVerkhoturov\WbApiClient\InStorePickup\Api\DefaultApi;
use GuzzleHttp\Client;

$config = (new Configuration())
    ->setAccessTokenSecret(new SecretString('<your WB JWT>'));
$api = new DefaultApi(new Client(), $config);
```

### orders-fbw — Поставки FBW

Узнать больше о поставках FBW можно в [справочном центре](https://seller.wildberries.ru/instructions/subcategory/5a8e1202-0865-45b7-acae-5d0afc7add56?goBackOption=prevRoute&categoryId=479385c6-de01-4b4d-ad4e-ed941e65582e)

**Reference:** https://dev.wildberries.ru/openapi/orders-fbw

**APIs:** `DefaultApi`

```php
use ValeryVerkhoturov\WbApiClient\OrdersFbw\Configuration;
use ValeryVerkhoturov\WbApiClient\OrdersFbw\SecretString;
use ValeryVerkhoturov\WbApiClient\OrdersFbw\Api\DefaultApi;
use GuzzleHttp\Client;

$config = (new Configuration())
    ->setAccessTokenSecret(new SecretString('<your WB JWT>'));
$api = new DefaultApi(new Client(), $config);
```

### promotion — Маркетинг и продвижение

Узнать больше о маркетинге и продвижении можно в [справочном центре](https://seller.wildberries.ru/instructions/category/59d92bd3-6ea0-40f2-b762-ca8835d7d42e?goBackOption=prevRoute&categoryId=479385c6-de01-4b4d-ad4e-ed941e65582e)

**Reference:** https://dev.wildberries.ru/openapi/promotion

**APIs:** `DefaultApi`

```php
use ValeryVerkhoturov\WbApiClient\Promotion\Configuration;
use ValeryVerkhoturov\WbApiClient\Promotion\SecretString;
use ValeryVerkhoturov\WbApiClient\Promotion\Api\DefaultApi;
use GuzzleHttp\Client;

$config = (new Configuration())
    ->setAccessTokenSecret(new SecretString('<your WB JWT>'));
$api = new DefaultApi(new Client(), $config);
```

### communications — Общение с покупателями

Узнать больше об общении с покупателями можно в [справочном центре](https://seller.wildberries.ru/instructions/category/f7f6c465-dd12-422d-80a0-a6d9562115d5?goBackOption=prevRoute&categoryId=30817062-14cc-4a82-bc78-3600c2b0685b)

**Reference:** https://dev.wildberries.ru/openapi/customer-communication

**APIs:** `DefaultApi`

```php
use ValeryVerkhoturov\WbApiClient\Communications\Configuration;
use ValeryVerkhoturov\WbApiClient\Communications\SecretString;
use ValeryVerkhoturov\WbApiClient\Communications\Api\DefaultApi;
use GuzzleHttp\Client;

$config = (new Configuration())
    ->setAccessTokenSecret(new SecretString('<your WB JWT>'));
$api = new DefaultApi(new Client(), $config);
```

### rates — Тарифы

Узнать больше о тарифах можно в [справочном центре](https://seller.wildberries.ru/instructions/ru/ru/material/fees-site-section)

**Reference:** https://dev.wildberries.ru/openapi/rates

**APIs:** `DefaultApi`

```php
use ValeryVerkhoturov\WbApiClient\Rates\Configuration;
use ValeryVerkhoturov\WbApiClient\Rates\SecretString;
use ValeryVerkhoturov\WbApiClient\Rates\Api\DefaultApi;
use GuzzleHttp\Client;

$config = (new Configuration())
    ->setAccessTokenSecret(new SecretString('<your WB JWT>'));
$api = new DefaultApi(new Client(), $config);
```

### analytics — Аналитика и данные

Узнать больше об аналитике и данных можно в [справочном центре](https://seller.wildberries.ru/instructions/ru/ru/subcategory/seller-analytics)

**Reference:** https://dev.wildberries.ru/openapi/analytics

**APIs:** `CSVApi`, `DefaultApi`

```php
use ValeryVerkhoturov\WbApiClient\Analytics\Configuration;
use ValeryVerkhoturov\WbApiClient\Analytics\SecretString;
use ValeryVerkhoturov\WbApiClient\Analytics\Api\CSVApi;
use GuzzleHttp\Client;

$config = (new Configuration())
    ->setAccessTokenSecret(new SecretString('<your WB JWT>'));
$api = new CSVApi(new Client(), $config);
```

### reports — Отчёты

Узнать больше об отчётах можно в [справочном центре](https://seller.wildberries.ru/instructions/subcategory/5f2162c5-069b-416d-a4e1-48da2a76e6b0)

**Reference:** https://dev.wildberries.ru/openapi/reports

**APIs:** `CApi`, `DefaultApi`

```php
use ValeryVerkhoturov\WbApiClient\Reports\Configuration;
use ValeryVerkhoturov\WbApiClient\Reports\SecretString;
use ValeryVerkhoturov\WbApiClient\Reports\Api\CApi;
use GuzzleHttp\Client;

$config = (new Configuration())
    ->setAccessTokenSecret(new SecretString('<your WB JWT>'));
$api = new CApi(new Client(), $config);
```

### finances — Документы и бухгалтерия

Узнать больше о документах и бухгалтерии можно в [справочном центре](https://seller.wildberries.ru/instructions/category/ba929b64-1f89-4426-82d7-ce998ee552bd?goBackOption=prevRoute&categoryId=3c971375-9939-45e8-ab82-376019be8942)

**Reference:** https://dev.wildberries.ru/openapi/documents-and-accounting

**APIs:** `DefaultApi`

```php
use ValeryVerkhoturov\WbApiClient\Finances\Configuration;
use ValeryVerkhoturov\WbApiClient\Finances\SecretString;
use ValeryVerkhoturov\WbApiClient\Finances\Api\DefaultApi;
use GuzzleHttp\Client;

$config = (new Configuration())
    ->setAccessTokenSecret(new SecretString('<your WB JWT>'));
$api = new DefaultApi(new Client(), $config);
```

