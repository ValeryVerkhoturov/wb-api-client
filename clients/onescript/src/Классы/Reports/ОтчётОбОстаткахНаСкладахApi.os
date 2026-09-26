// ОтчётОбОстаткахНаСкладахApi
//
// Класс сформирован автоматически (onescript) из спецификации OpenAPI.
// Правки будут потеряны при следующей генерации.
//
// Пример:
//   Настройки = Новый Конфигурация();
//   Настройки.УстановитьТокен("...");
//   Клиент = Новый ОтчётОбОстаткахНаСкладахApi(Настройки);

Перем Настройки Экспорт;
Перем Транспорт Экспорт;

Процедура ПриСозданииОбъекта(Знач ВходящиеНастройки)
	Настройки = ВходящиеНастройки;
	Транспорт = Новый ТранспортHTTP(Настройки);
КонецПроцедуры

// Создать отчёт
//
// Метод создаёт [задание на генерацию](https://dev.wildberries.ru/openapi/reports#tag/warehousesInventoryReport/operation/getV1WarehouseRemainsTasksTaskIdStatus) отчёта об [остатках на складах WB](https://dev.wildberries.ru/openapi/reports#tag/warehousesInventoryReport/operation/getV1WarehouseRemainsTasksTaskIdDownload).
//
// Параметры `groupBy` и `filter` (группировки и фильтры) можно задать в любой комбинации — аналогично [версии](https://seller.wildberries.ru/analytics-reports/warehouse-remains) в личном кабинете.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца:
// | Тип | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- | --- |
// | Персональный | 1 мин | 1 запрос | 1 мин | 5 запросов |
// | Сервисный | 1 мин | 1 запрос | 1 мин | 5 запросов |
// | Базовый с секретом | 1 мин | 1 запрос | 1 мин | 5 запросов |
// | Базовый | 1 ч | 4 запроса | 15 мин | 1 запрос |
//
// Параметры:
//   ДопПараметры - Структура, Соответствие - необязательные параметры:
//    * locale - Строка - Язык полей ответа `subjectName` и `warehouseName`: - `ru` — русский - `en` — английский - `zh` — китайский. Значения `warehouseName` на английском
//    * groupByBrand - Булево - Разбивка по брендам
//    * groupBySubject - Булево - Разбивка по предметам
//    * groupBySa - Булево - Разбивка по артикулам продавца
//    * groupByNm - Булево - Разбивка по артикулам WB. Если `groupByNm=true`, в ответе будет поле `volume`
//    * groupByBarcode - Булево - Разбивка по баркодам
//    * groupBySize - Булево - Разбивка по размерам
//    * filterPics - Число - Фильтр по фото: - `-1` — без фото - `0` — не применять фильтр - `1` — с фото
//    * filterVolume - Число - Фильтр по объёму: - `-1` — без габаритов - `0` — не применять фильтр - `3` — свыше трёх литров
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция GetV1WarehouseRemains(Знач ДопПараметры = Неопределено) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;

	ИменаЗаголовков = Новый Массив;
	Транспорт.РазложитьПараметры(ДопПараметры, ИменаЗаголовков, ПараметрыЗапроса, Заголовки);
	Возврат Транспорт.ВыполнитьЗапрос(
		"GET",
		"/api/v1/warehouse_remains",
		ПараметрыЗапроса,
		Заголовки,
		Неопределено,
		"https://seller-analytics-api.wildberries.ru");

КонецФункции

// Получить отчёт
//
// Метод возвращает отчёт об [остатках на складах WB](https://seller.wildberries.ru/analytics-reports/warehouse-remains) по ID [задания на генерацию](https://dev.wildberries.ru/openapi/reports#tag/warehousesInventoryReport/operation/getV1WarehouseRemains).
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца:
// | Тип | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- | --- |
// | Персональный | 1 мин | 1 запрос | 1 мин | 1 запрос |
// | Сервисный | 1 мин | 1 запрос | 1 мин | 1 запрос |
// | Базовый с секретом | 1 мин | 1 запрос | 1 мин | 1 запрос |
// | Базовый | 1 ч | 4 запроса | 15 мин | 1 запрос |
//
// Параметры:
//   task_id - Строка - ID задания на генерацию
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция GetV1WarehouseRemainsTasksTaskIdDownload(Знач task_id) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"GET",
		СтрШаблон("/api/v1/warehouse_remains/tasks/%1/download", Транспорт.ЭкранироватьСегмент(task_id)),
		ПараметрыЗапроса,
		Заголовки,
		Неопределено,
		"https://seller-analytics-api.wildberries.ru");

КонецФункции

// Проверить статус
//
// Метод возвращает статус [задания на генерацию](https://dev.wildberries.ru/openapi/reports#tag/warehousesInventoryReport/operation/getV1WarehouseRemains) отчёта об [остатках на складах WB](https://dev.wildberries.ru/openapi/reports#tag/warehousesInventoryReport/operation/getV1WarehouseRemainsTasksTaskIdDownload).
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца:
// | Тип | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- | --- |
// | Персональный | 5 сек | 1 запрос | 5 сек | 5 запросов |
// | Сервисный | 5 сек | 1 запрос | 5 сек | 5 запросов |
// | Базовый с секретом | 5 сек | 1 запрос | 5 сек | 5 запросов |
// | Базовый | 1 ч | 4 запроса | 15 мин | 1 запрос |
//
// Параметры:
//   task_id - Строка - ID задания на генерацию
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция GetV1WarehouseRemainsTasksTaskIdStatus(Знач task_id) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"GET",
		СтрШаблон("/api/v1/warehouse_remains/tasks/%1/status", Транспорт.ЭкранироватьСегмент(task_id)),
		ПараметрыЗапроса,
		Заголовки,
		Неопределено,
		"https://seller-analytics-api.wildberries.ru");

КонецФункции

