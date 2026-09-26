// СборочныеЗаданияСамовывозApi
//
// Класс сформирован автоматически (onescript) из спецификации OpenAPI.
// Правки будут потеряны при следующей генерации.
//
// Пример:
//   Настройки = Новый Конфигурация();
//   Настройки.УстановитьТокен("...");
//   Клиент = Новый СборочныеЗаданияСамовывозApi(Настройки);

Перем Настройки Экспорт;
Перем Транспорт Экспорт;

Процедура ПриСозданииОбъекта(Знач ВходящиеНастройки)
	Настройки = ВходящиеНастройки;
	Транспорт = Новый ТранспортHTTP(Настройки);
КонецПроцедуры

// Получить информацию о завершённых сборочных заданиях
//
// Метод возвращает информацию о завершённых сборочных заданиях после продажи или отмены заказа.
//
// Можно получить данные за заданный период, максимум 30 календарных дней одним запросом.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца для методов **сборочных заданий Самовывоз**:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 300 запросов | 200 мс | 20 запросов |
// Один запрос с кодами ответов `4XX` учитывается как 10 запросов.
//
// ---
//
// В [песочнице](https://dev.wildberries.ru/sandbox) — максимум 1 запрос в секунду суммарно для всех методов **Маркетплейса**.
//
// Параметры:
//   limit - Число - Количество элементов в ответе
//   next - Число - Параметр пагинации. Чтобы получить полный список данных, укажите `0` в первом запросе. Чтобы получить следующий пакет данных, используйте значение `next` из отв…
//   dateFrom - Число - Дата начала периода в формате Unix timestamp
//   dateTo - Число - Дата конца периода в формате Unix timestamp
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция GetV3ClickCollectOrders(Знач limit, Знач next, Знач dateFrom, Знач dateTo) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	ПараметрыЗапроса.Вставить("limit", limit);
	ПараметрыЗапроса.Вставить("next", next);
	ПараметрыЗапроса.Вставить("dateFrom", dateFrom);
	ПараметрыЗапроса.Вставить("dateTo", dateTo);
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"GET",
		"/api/v3/click-collect/orders",
		ПараметрыЗапроса,
		Заголовки,
		Неопределено,
		"https://marketplace-api.wildberries.ru");

КонецФункции

// Получить список новых сборочных заданий
//
// Метод возвращает список всех новых [сборочных заданий](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders), которые есть у продавца на момент запроса.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца для методов **сборочных заданий Самовывоз**:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 300 запросов | 200 мс | 20 запросов |
// Один запрос с кодами ответов `4XX` учитывается как 10 запросов.
//
// ---
//
// В [песочнице](https://dev.wildberries.ru/sandbox) — максимум 1 запрос в секунду суммарно для всех методов **Маркетплейса**.
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция GetV3ClickCollectOrdersNew() Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"GET",
		"/api/v3/click-collect/orders/new",
		ПараметрыЗапроса,
		Заголовки,
		Неопределено,
		"https://marketplace-api.wildberries.ru");

КонецФункции

// Информация о покупателе
//
// Метод возвращает информацию о покупателе по ID сборочного задания.
//
// Доступно только для сборочных заданий в статусах:
// - `confirm` — на сборке
// - `prepare` — готов к выдаче
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца для методов **сборочных заданий Самовывоз**:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 300 запросов | 200 мс | 20 запросов |
// Один запрос с кодами ответов `4XX` учитывается как 10 запросов.
//
// ---
//
// В [песочнице](https://dev.wildberries.ru/sandbox) — максимум 1 запрос в секунду суммарно для всех методов **Маркетплейса**.
//
// Параметры:
//   Тело - InStorePickupApiOrdersRequest
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV3ClickCollectOrdersClient(Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		"/api/v3/click-collect/orders/client",
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://marketplace-api.wildberries.ru");

КонецФункции

// Проверить, что заказ принадлежит покупателю
//
// Метод сообщает, принадлежит ли проверяемый заказ покупателю или нет по переданному коду.
//
// Доступно, если хотя бы одно сборочное задание из заказа находится в статусе prepare - готов к выдаче.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 30 запросов | 2 сек | 20 запросов |
// Один запрос с кодами ответов `4XX` учитывается как 10 запросов.
//
// ---
//
// В [песочнице](https://dev.wildberries.ru/sandbox) — максимум 1 запрос в секунду суммарно для всех методов **Маркетплейса**.
//
// Параметры:
//   Тело - InStorePickupApiCheckIdentityRequest
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV3ClickCollectOrdersClientIdentity(Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		"/api/v3/click-collect/orders/client/identity",
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://marketplace-api.wildberries.ru");

КонецФункции

// Получить цены продавца и суммы к оплате
//
// Метод возвращает:
// - цены продавца без учёта скидок
// - суммы к оплате покупателем с учетом всех скидок и кэшбека
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
//   Тело - InStorePickupApiOrdersRequest
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV3ClickCollectOrdersFinalPrice(Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		"/api/marketplace/v3/click-collect/orders/final-price",
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://marketplace-api.wildberries.ru");

КонецФункции

// Отменить сборочные задания
//
// Переводит [сборочные задания](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders) из [статусов](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders/operation/postV3ClickCollectOrdersStatusInfo) `new`, `confirm`, `prepare` в статус `cancel` — отменено продавцом.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 сек | 1 запрос | 1 сек | 10 запросов |
// Один запрос с кодами ответов `4XX` учитывается как 10 запросов.
//
// ---
//
// В [песочнице](https://dev.wildberries.ru/sandbox) — максимум 1 запрос в секунду суммарно для всех методов **Маркетплейса**.
//
// Параметры:
//   Тело - InStorePickupApiOrdersRequestV2
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV3ClickCollectOrdersStatusCancel(Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		"/api/marketplace/v3/click-collect/orders/status/cancel",
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://marketplace-api.wildberries.ru");

КонецФункции

// Перевести сборочные задания на сборку
//
// Метод переводит [сборочные задания](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders) из [статуса](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders/operation/postV3ClickCollectOrdersStatusInfo) `new` — новый — в статус `confirm` — на сборке.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 сек | 1 запрос | 1 сек | 10 запросов |
// Один запрос с кодами ответов `4XX` учитывается как 10 запросов.
//
// ---
//
// В [песочнице](https://dev.wildberries.ru/sandbox) — максимум 1 запрос в секунду суммарно для всех методов **Маркетплейса**.
//
// Параметры:
//   Тело - InStorePickupApiOrdersRequestV2
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV3ClickCollectOrdersStatusConfirm(Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		"/api/marketplace/v3/click-collect/orders/status/confirm",
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://marketplace-api.wildberries.ru");

КонецФункции

// Получить статусы сборочных заданий
//
// Метод возвращает статусы [сборочных заданий](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders) по их ID.
//
// `supplierStatus` — статус сборочного задания. Триггер его изменения - действие самого продавца.
// Возможные значения `supplierStatus`:
// | Статус | Описание | Как перевести сборочное задание в данный статус |
// | ------- | --------- | --------------------------------------|
// | `new` | \\*\\*Новое сборочное задание\\*\\* |
// | `confirm` | \\*\\*На сборке\\*\\* | [Перевести сборочное задание на сборку](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders/operation/postV3ClickCollectOrdersStatusConfirm)
// | `prepare` | \\*\\*Готов к выдаче\\*\\* | [Сообщить, что сборочное задание готово к выдаче](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders/operation/postV3ClickCollectOrdersStatusPrepare)
// | `receive` | \\*\\*Получено покупателем\\*\\* | [Сообщить, что заказ принят покупателем](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders/operation/postV3ClickCollectOrdersStatusReceive)
// | `reject` | \\*\\*Отказ покупателя при получении\\*\\* | [Сообщить, что покупатель отказался от заказа](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders/operation/postV3ClickCollectOrdersStatusReject)
// | `cancel` | \\*\\*Отменено продавцом\\*\\* | [Отменить сборочное задание](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders/operation/postV3ClickCollectOrdersStatusCancel)
// | `cancel\\_shelf\\_life` | \\*\\*Отмена по истечении срока хранения\\*\\* | Переводится автоматически по возникновению события
//
// `wbStatus` — статус системы Wildberries.
// Возможные значения `wbStatus`:
// - `waiting` - сборочное задание в работе
// - `sold` - заказ получен покупателем
// - `canceled` - отмена сборочного задания
// - `canceled\\_by\\_client` - покупатель отменил заказ при получении
// - `declined\\_by\\_client` - покупатель отменил заказ в первый чаc
//
// Отмена доступна покупателю в первый час с момента заказа, если заказ не переведён на сборку
// - `defect` - отмена заказа по причине брака
// - `ready\\_for\\_pickup` - заказ готов к выдаче
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 сек | 1 запрос | 1 сек | 10 запросов |
// Один запрос с кодами ответов `4XX` учитывается как 10 запросов.
//
// ---
//
// В [песочнице](https://dev.wildberries.ru/sandbox) — максимум 1 запрос в секунду суммарно для всех методов **Маркетплейса**.
//
// Параметры:
//   Тело - InStorePickupApiOrdersRequestV2
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV3ClickCollectOrdersStatusInfo(Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		"/api/marketplace/v3/click-collect/orders/status/info",
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://marketplace-api.wildberries.ru");

КонецФункции

// Сообщить, что сборочные задания готовы к выдаче
//
// Метод переводит [сборочные задания](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders) из [статуса](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders/operation/postV3ClickCollectOrdersStatusInfo) `confirm` — на сборке — в статус `prepare` — готово к выдаче.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 сек | 1 запрос | 1 сек | 10 запросов |
// Один запрос с кодами ответов `4XX` учитывается как 10 запросов.
//
// ---
//
// В [песочнице](https://dev.wildberries.ru/sandbox) — максимум 1 запрос в секунду суммарно для всех методов **Маркетплейса**.
//
// Параметры:
//   Тело - InStorePickupApiOrdersRequestV2
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV3ClickCollectOrdersStatusPrepare(Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		"/api/marketplace/v3/click-collect/orders/status/prepare",
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://marketplace-api.wildberries.ru");

КонецФункции

// Сообщить, что заказы приняты покупателями
//
// Метод переводит [сборочные задания](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders) из [статуса](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders/operation/postV3ClickCollectOrdersStatusInfo) `prepare` — готово к выдаче — в статус `receive` — получено покупателем.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 сек | 1 запрос | 1 сек | 10 запросов |
// Один запрос с кодами ответов `4XX` учитывается как 10 запросов.
//
// ---
//
// В [песочнице](https://dev.wildberries.ru/sandbox) — максимум 1 запрос в секунду суммарно для всех методов **Маркетплейса**.
//
// Параметры:
//   Тело - InStorePickupApiOrdersRequestV2
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV3ClickCollectOrdersStatusReceive(Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		"/api/marketplace/v3/click-collect/orders/status/receive",
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://marketplace-api.wildberries.ru");

КонецФункции

// Сообщить об отказе от заказов
//
// Метод переводит [сборочные задания](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders) из [статуса](https://dev.wildberries.ru/openapi/in-store-pickup#tag/inStorePickupAssemblyOrders/operation/postV3ClickCollectOrdersStatusInfo) `prepare` — готово к выдаче — в статус `reject` — отказ при получении.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 сек | 1 запрос | 1 сек | 10 запросов |
// Один запрос с кодами ответов `4XX` учитывается как 10 запросов.
//
// ---
//
// В [песочнице](https://dev.wildberries.ru/sandbox) — максимум 1 запрос в секунду суммарно для всех методов **Маркетплейса**.
//
// Параметры:
//   Тело - InStorePickupApiOrdersRequestV2
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV3ClickCollectOrdersStatusReject(Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		"/api/marketplace/v3/click-collect/orders/status/reject",
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://marketplace-api.wildberries.ru");

КонецФункции

