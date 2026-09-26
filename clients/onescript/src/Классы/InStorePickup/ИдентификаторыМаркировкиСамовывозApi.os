// ИдентификаторыМаркировкиСамовывозApi
//
// Класс сформирован автоматически (onescript) из спецификации OpenAPI.
// Правки будут потеряны при следующей генерации.
//
// Пример:
//   Настройки = Новый Конфигурация();
//   Настройки.УстановитьТокен("...");
//   Клиент = Новый ИдентификаторыМаркировкиСамовывозApi(Настройки);

Перем Настройки Экспорт;
Перем Транспорт Экспорт;

Процедура ПриСозданииОбъекта(Знач ВходящиеНастройки)
	Настройки = ВходящиеНастройки;
	Транспорт = Новый ТранспортHTTP(Настройки);
КонецПроцедуры

// Закрепить номера ДТ за сборочными заданиями
//
// Метод обновляет номера ДТ — деклараций на товары — и коды стран происхождения товаров в [идентификаторах маркировки сборочных заданий](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers/operation/postV3ClickCollectOrdersMetaDetails). У одного сборочного задания может быть только один номер ДТ.
// Закрепить номер ДТ можно, только если выполняются все условия:
// - сборочное задание имеет признак B2B-продажи — `\"isB2b\":true` в ответе метода [получения новых сборочных заданий](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders/operation/getV3ClickCollectOrdersNew)
// - сборочное задание находится в [статусах](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders/operation/postV3ClickCollectOrdersStatusInfo) `confirm` или `prepare`
// - поле `customsDeclaration` есть в [идентификаторах маркировки сборочного задания](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers/operation/postV3ClickCollectOrdersMetaDetails)
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца для всех методов **закрепления идентификаторов маркировки Самовывоз**:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 20 запросов | 3 сек | 500 запросов |
// Один запрос с кодами ответов `4XX` учитывается как 10 запросов.
//
// ---
//
// В [песочнице](https://dev.wildberries.ru/sandbox) — максимум 1 запрос в секунду суммарно для всех методов **Маркетплейса**.
//
// Параметры:
//   Тело - InStorePickupPostV3ClickCollectOrdersMetaCustomsDeclarationRequest
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV3ClickCollectOrdersMetaCustomsDeclaration(Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		"/api/marketplace/v3/click-collect/orders/meta/customs-declaration",
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://marketplace-api.wildberries.ru");

КонецФункции

// Удалить идентификаторы маркировки сборочных заданий
//
// Метод удаляет значения указанных [идентификаторов маркировки сборочных заданий](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers/operation/postV3ClickCollectOrdersMetaDetails).
//
// В одном запросе можно удалить идентификаторы маркировки только одного типа. Укажите тип идентификаторов маркировки в запросе:
// - `imei` — [IMEI](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers/operation/postV3ClickCollectOrdersMetaImei)
// - `uin` — [УИН](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers/operation/postV3ClickCollectOrdersMetaUin)
// - `gtin` — [GTIN](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers/operation/postV3ClickCollectOrdersMetaGtin)
// - `sgtin` — [код маркировки](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers/operation/postV3ClickCollectOrdersMetaSgtin)
// - `customsDeclaration` — [номер ДТ](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers/operation/postV3ClickCollectOrdersMetaCustomsDeclaration). При удалении номера ДТ также удаляется код страны происхождения товара — `originCountryCode`
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца для всех методов **получения и удаления идентификаторов маркировки Самовывоз**:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 150 запросов | 400 мс | 20 запросов |
// Один запрос с кодами ответов `4XX` учитывается как 10 запросов.
//
// ---
//
// В [песочнице](https://dev.wildberries.ru/sandbox) — максимум 1 запрос в секунду суммарно для всех методов **Маркетплейса**.
//
// Параметры:
//   Тело - InStorePickupApiOrdersMetaDeleteRequest
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV3ClickCollectOrdersMetaDelete(Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		"/api/marketplace/v3/click-collect/orders/meta/delete",
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://marketplace-api.wildberries.ru");

КонецФункции

// Получить идентификаторы маркировки сборочных заданий
//
// Метод возвращает идентификаторы маркировки [сборочных заданий ](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders) и статусы их проверки.
//
// Перечень идентификаторов маркировки, доступных для сборочного задания, можно получить в [списке новых сборочных заданий](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders/operation/getV3ClickCollectOrdersNew), поле `requiredMeta`. Если поле `requiredMeta` не содержит какой-либо идентификатор маркировки, значит, у сборочного задания не может быть этого идентификатора — и добавить его нельзя.
// Возможные идентификаторы маркировки:
// - `imei` — [IMEI](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers/operation/postV3ClickCollectOrdersMetaImei)
// - `uin` — [УИН](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers/operation/postV3ClickCollectOrdersMetaUin)
// - `gtin` — [GTIN](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers/operation/postV3ClickCollectOrdersMetaGtin)
// - `sgtin` — [код маркировки](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers/operation/postV3ClickCollectOrdersMetaSgtin)
// - `customsDeclaration` — [номер ДТ](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers/operation/postV3ClickCollectOrdersMetaCustomsDeclaration)
// - `originCountryCode` — [числовой код страны происхождения товара](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers/operation/postV3ClickCollectOrdersMetaCustomsDeclaration) из [Общероссийского классификатора стран мира](https://esnsi.gosuslugi.ru/classifiers/16269)
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца для всех методов **получения и удаления идентификаторов маркировки Самовывоз**:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 150 запросов | 400 мс | 20 запросов |
// Один запрос с кодами ответов `4XX` учитывается как 10 запросов
//
// Параметры:
//   Тело - InStorePickupApiOrdersRequestV2
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV3ClickCollectOrdersMetaDetails(Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		"/api/marketplace/v3/click-collect/orders/meta/details",
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://marketplace-api.wildberries.ru");

КонецФункции

// Закрепить GTIN за сборочными заданиями
//
// Метод обновляет GTIN, уникальный ID товара в Беларуси, в [идентификаторах маркировки сборочных заданий](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers/operation/postV3ClickCollectOrdersMetaDetails). У одного сборочного задания может быть только один GTIN.
// Закрепить GTIN можно только за сборочным заданием в [статусе](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders/operation/postV3ClickCollectOrdersStatusInfo) `confirm` и если в [идентификаторах маркировки сборочного задания](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers/operation/postV3ClickCollectOrdersMetaDetails) есть поле `gtin`.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца для всех методов **закрепления идентификаторов маркировки Самовывоз**:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 20 запросов | 3 сек | 500 запросов |
// Один запрос с кодами ответов `4XX` учитывается как 10 запросов.
//
// ---
//
// В [песочнице](https://dev.wildberries.ru/sandbox) — максимум 1 запрос в секунду суммарно для всех методов **Маркетплейса**.
//
// Параметры:
//   Тело - InStorePickupApiOrdersGTINSetRequest
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV3ClickCollectOrdersMetaGtin(Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		"/api/marketplace/v3/click-collect/orders/meta/gtin",
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://marketplace-api.wildberries.ru");

КонецФункции

// Закрепить IMEI за сборочными заданиями
//
// Метод обновляет IMEI в [идентификаторах маркировки сборочных заданий](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers/operation/postV3ClickCollectOrdersMetaDetails).
// У одного сборочного задания может быть только один IMEI. Если у устройства два IMEI — \\*\\*IMEI\\*\\* и \\*\\*IMEI2\\*\\* или \\*\\*IMEI1\\*\\* и \\*\\*IMEI2\\*\\* — укажите только \\*\\*IMEI\\*\\* или \\*\\*IMEI1\\*\\*. \\*\\*IMEI2\\*\\* указывать не нужно.
// Закрепить IMEI можно только за сборочным заданием в [статусе](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders/operation/postV3ClickCollectOrdersStatusInfo) `confirm` и если в [идентификаторах маркировки сборочного задания](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers/operation/postV3ClickCollectOrdersMetaDetails) есть поле `imei`.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца для всех методов **закрепления идентификаторов маркировки Самовывоз**:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 20 запросов | 3 сек | 500 запросов |
// Один запрос с кодами ответов `4XX` учитывается как 10 запросов.
//
// ---
//
// В [песочнице](https://dev.wildberries.ru/sandbox) — максимум 1 запрос в секунду суммарно для всех методов **Маркетплейса**.
//
// Параметры:
//   Тело - InStorePickupApiOrdersIMEISetRequest
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV3ClickCollectOrdersMetaImei(Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		"/api/marketplace/v3/click-collect/orders/meta/imei",
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://marketplace-api.wildberries.ru");

КонецФункции

// Закрепить коды маркировки Честного знака за сборочными заданиями
//
// Метод обновляет код маркировки [Честного знака](https://честныйзнак.рф/) в [идентификаторах маркировки сборочных заданий](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers/operation/postV3ClickCollectOrdersMetaDetails).
// Закрепить код маркировки можно только за сборочным заданием в [статусе](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders/operation/postV3ClickCollectOrdersStatusInfo) `confirm` и если в [идентификаторах маркировки сборочного задания](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers/operation/postV3ClickCollectOrdersMetaDetails) есть поле `sgtin`.
//
// Получить загруженные маркировки можно в [идентификаторах маркировки сборочного задания](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers/operation/postV3ClickCollectOrdersMetaDetails).
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца для всех методов **закрепления идентификаторов маркировки Самовывоз**:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 20 запросов | 3 сек | 500 запросов |
// Один запрос с кодами ответов `4XX` учитывается как 10 запросов.
//
// ---
//
// В [песочнице](https://dev.wildberries.ru/sandbox) — максимум 1 запрос в секунду суммарно для всех методов **Маркетплейса**.
//
// Параметры:
//   Тело - InStorePickupApiOrdersSGTINsSetRequest
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV3ClickCollectOrdersMetaSgtin(Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		"/api/marketplace/v3/click-collect/orders/meta/sgtin",
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://marketplace-api.wildberries.ru");

КонецФункции

// Закрепить УИН за сборочными заданиями
//
// Метод обновляет УИН, уникальные идентификационные номера, в [идентификаторах маркировки сборочных заданий](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers/operation/postV3ClickCollectOrdersMetaDetails). У одного сборочного задания может быть только один УИН.
// Закрепить УИН можно только за сборочным заданием в [статусе](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders/operation/postV3ClickCollectOrdersStatusInfo) `confirm` и если в [идентификаторах маркировки сборочного задания](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupLabelIdentifiers/operation/postV3ClickCollectOrdersMetaDetails) есть поле `uin`.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца для всех методов **закрепления идентификаторов маркировки Самовывоз**:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 20 запросов | 3 сек | 500 запросов |
// Один запрос с кодами ответов `4XX` учитывается как 10 запросов.
//
// ---
//
// В [песочнице](https://dev.wildberries.ru/sandbox) — максимум 1 запрос в секунду суммарно для всех методов **Маркетплейса**.
//
// Параметры:
//   Тело - InStorePickupApiOrdersUINSetRequest
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV3ClickCollectOrdersMetaUin(Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		"/api/marketplace/v3/click-collect/orders/meta/uin",
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://marketplace-api.wildberries.ru");

КонецФункции

