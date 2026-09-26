// ИдентификаторыМаркировкиDBWApi
//
// Класс сформирован автоматически (onescript) из спецификации OpenAPI.
// Правки будут потеряны при следующей генерации.
//
// Пример:
//   Настройки = Новый Конфигурация();
//   Настройки.УстановитьТокен("...");
//   Клиент = Новый ИдентификаторыМаркировкиDBWApi(Настройки);

Перем Настройки Экспорт;
Перем Транспорт Экспорт;

Процедура ПриСозданииОбъекта(Знач ВходящиеНастройки)
	Настройки = ВходящиеНастройки;
	Транспорт = Новый ТранспортHTTP(Настройки);
КонецПроцедуры

// Удалить идентификаторы маркировки сборочных заданий
//
// Метод удаляет значение указанных [идентификаторов маркировки сборочного задания](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwLabelIdentifiers/operation/postV3DbwOrdersMetaDetails) для переданного ключа.
//
// В одном запросе можно удалить идентификаторы маркировки только одного типа. Укажите тип идентификаторов маркировки в запросе:
// - `imei` — [IMEI](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwLabelIdentifiers/operation/putV3DbwOrdersOrderIdMetaImei)
// - `uin` — [УИН](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwLabelIdentifiers/operation/putV3DbwOrdersOrderIdMetaUin)
// - `gtin` — [GTIN](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwLabelIdentifiers/operation/putV3DbwOrdersOrderIdMetaImei)
// - `sgtin` — [код маркировки Честного знака](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwLabelIdentifiers/operation/postV3DbwOrdersMetaSgtin)
// Можно передать только один ключ.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца для следующих методов DBW:
//
// * получение и обновление списка контактов
// * получение и удаление идентификаторов маркировки
// * методы сборочных заданий
//
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 300 запросов | 200 мс | 20 запросов |
// Один запрос с кодами ответов `4XX` учитывается как 10 запросов
//
// Параметры:
//   Тело - OrdersDbwApiOrdersMetaDleteRequestV2
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV3DbwOrdersMetaDelete(Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		"/api/marketplace/v3/dbw/orders/meta/delete",
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://marketplace-api.wildberries.ru");

КонецФункции

// Получить идентификаторы маркировки сборочных заданий
//
// Метод возвращает идентификаторы маркировки [сборочных заданий](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwAssemblyOrders/operation/getV3DbwOrders) и статусы их проверки.
//
// Перечень идентификаторов маркировки, доступных для сборочного задания, можно получить в [списке новых сборочных заданий](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwAssemblyOrders/operation/getV3DbwOrdersNew), поле `requiredMeta`. Если поле `requiredMeta` не содержит какой-либо идентификатор маркировки, значит, у сборочного задания не может быть этого идентификатора — и добавить его нельзя.
// Возможные идентификаторы маркировки:
// - `imei` — [IMEI](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwLabelIdentifiers/operation/putV3DbwOrdersOrderIdMetaImei)
// - `uin` — [УИН](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwLabelIdentifiers/operation/putV3DbwOrdersOrderIdMetaUin)
// - `gtin` — [GTIN](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwLabelIdentifiers/operation/putV3DbwOrdersOrderIdMetaGtin)
// - `sgtin` — [код маркировки Честного знака](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwLabelIdentifiers/operation/postV3DbwOrdersMetaSgtin)
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца для следующих методов DBW:
//
// * получение и обновление списка контактов
// * получение и удаление идентификаторов маркировки
// * методы сборочных заданий
//
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 300 запросов | 200 мс | 20 запросов |
// Один запрос с кодами ответов `4XX` учитывается как 10 запросов
//
// Параметры:
//   Тело - OrdersDbwApiOrdersRequestV2
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV3DbwOrdersMetaDetails(Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		"/api/marketplace/v3/dbw/orders/meta/details",
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://marketplace-api.wildberries.ru");

КонецФункции

// Закрепить коды маркировки Честного знака за сборочными заданиями
//
// Метод обновляет код маркировки [Честного знака](https://честныйзнак.рф/) в [идентификаторах маркировки сборочных заданий](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwLabelIdentifiers/operation/postV3DbwOrdersMetaDetails).
// Закрепить код маркировки можно только за сборочным заданием в [статусе](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwAssemblyOrders/operation/postV3DbwOrdersStatus) `confirm` и если в [идентификаторах маркировки сборочного задания](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwLabelIdentifiers/operation/postV3DbwOrdersMetaDetails) есть поле `sgtin`.
//
// Получить загруженные маркировки можно в [идентификаторах маркировки сборочного задания](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwLabelIdentifiers/operation/postV3DbwOrdersMetaDetails).
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца для следующих методов DBW:
//
// * получение и обновление списка контактов
// * получение и удаление идентификаторов маркировки
// * методы сборочных заданий
//
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 300 запросов | 200 мс | 20 запросов |
// Один запрос с кодами ответов `4XX` учитывается как 10 запросов
//
// Параметры:
//   Тело - OrdersDbwApiOrdersSGTINsSetRequest
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV3DbwOrdersMetaSgtin(Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		"/api/marketplace/v3/dbw/orders/meta/sgtin",
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://marketplace-api.wildberries.ru");

КонецФункции

// Закрепить GTIN за сборочным заданием
//
// Метод обновляет GTIN, уникальный ID товара в Беларуси, в [идентификаторах маркировки сборочного задания](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwLabelIdentifiers/operation/postV3DbwOrdersMetaDetails). У одного сборочного задания может быть только один GTIN.
// Закрепить GTIN можно только за сборочным заданием в [статусе](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwAssemblyOrders/operation/postV3DbwOrdersStatus) `confirm` и если в [идентификаторах маркировки сборочного задания](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwLabelIdentifiers/operation/postV3DbwOrdersMetaDetails) есть поле `gtin`.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца для всех методов **закрепления идентификаторов маркировки DBW**:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 1000 запросов | 60 мс | 20 запросов |
// Один запрос с кодами ответов `4XX` учитывается как 10 запросов
//
// Параметры:
//   orderId - Число - ID сборочного задания
//   Тело - OrdersDbwPutV3DbwOrdersOrderIdMetaGtinRequest
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PutV3DbwOrdersOrderIdMetaGtin(Знач orderId, Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"PUT",
		СтрШаблон("/api/v3/dbw/orders/%1/meta/gtin", Транспорт.ЭкранироватьСегмент(orderId)),
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://marketplace-api.wildberries.ru");

КонецФункции

// Закрепить IMEI за сборочным заданием
//
// Метод обновляет IMEI в [идентификаторах маркировки сборочного задания](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwLabelIdentifiers/operation/postV3DbwOrdersMetaDetails).
// У одного сборочного задания может быть только один IMEI. Если у устройства два IMEI — \\*\\*IMEI\\*\\* и \\*\\*IMEI2\\*\\* или \\*\\*IMEI1\\*\\* и \\*\\*IMEI2\\*\\* — укажите только \\*\\*IMEI\\*\\* или \\*\\*IMEI1\\*\\*. \\*\\*IMEI2\\*\\* указывать не нужно.
// Закрепить IMEI можно только за сборочным заданием в [статусе](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwAssemblyOrders/operation/postV3DbwOrdersStatus) `confirm` и если в [идентификаторах маркировки сборочного задания](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwLabelIdentifiers/operation/postV3DbwOrdersMetaDetails) есть поле `imei`.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца для всех методов **закрепления идентификаторов маркировки DBW**:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 1000 запросов | 60 мс | 20 запросов |
// Один запрос с кодами ответов `4XX` учитывается как 10 запросов
//
// Параметры:
//   orderId - Число - ID сборочного задания
//   Тело - OrdersDbwPutV3DbwOrdersOrderIdMetaImeiRequest
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PutV3DbwOrdersOrderIdMetaImei(Знач orderId, Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"PUT",
		СтрШаблон("/api/v3/dbw/orders/%1/meta/imei", Транспорт.ЭкранироватьСегмент(orderId)),
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://marketplace-api.wildberries.ru");

КонецФункции

// Закрепить УИН за сборочным заданием
//
// Метод обновляет УИН, уникальный идентификационный номер, в [идентификаторах маркировки сборочного задания](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwLabelIdentifiers/operation/postV3DbwOrdersMetaDetails). У одного сборочного задания может быть только один УИН.
// Закрепить УИН можно только за сборочным заданием в [статусе](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwAssemblyOrders/operation/postV3DbwOrdersStatus) `confirm` и если в [идентификаторах маркировки сборочного задания](https://dev.wildberries.ru/openapi/orders-dbw#tag/dbwLabelIdentifiers/operation/postV3DbwOrdersMetaDetails) есть поле `uin`.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца для всех методов **закрепления идентификаторов маркировки DBW**:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 1000 запросов | 60 мс | 20 запросов |
// Один запрос с кодами ответов `4XX` учитывается как 10 запросов
//
// Параметры:
//   orderId - Число - ID сборочного задания
//   Тело - OrdersDbwPutV3DbwOrdersOrderIdMetaUinRequest
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PutV3DbwOrdersOrderIdMetaUin(Знач orderId, Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"PUT",
		СтрШаблон("/api/v3/dbw/orders/%1/meta/uin", Транспорт.ЭкранироватьСегмент(orderId)),
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://marketplace-api.wildberries.ru");

КонецФункции

