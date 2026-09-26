// ФинансовыеОтчётыApi
//
// Класс сформирован автоматически (onescript) из спецификации OpenAPI.
// Правки будут потеряны при следующей генерации.
//
// Пример:
//   Настройки = Новый Конфигурация();
//   Настройки.УстановитьТокен("...");
//   Клиент = Новый ФинансовыеОтчётыApi(Настройки);

Перем Настройки Экспорт;
Перем Транспорт Экспорт;

Процедура ПриСозданииОбъекта(Знач ВходящиеНастройки)
	Настройки = ВходящиеНастройки;
	Транспорт = Новый ТранспортHTTP(Настройки);
КонецПроцедуры

// Детализации к отчётам об издержках на приём платежей за период
//
// Метод [доступен](https://dev.wildberries.ru/openapi/api-information#tag/authorization/Pravila-ispolzovaniya-tokenov-dostupa-k-API) по
// **Персональному** токену,
// **Сервисному** токену
//
// Метод возвращает детализации к [отчётам об издержках на приём платежей](https://seller.wildberries.ru/suppliers-mutual-settlements/reports-implementations/acquiring-reports) за указанный период.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 1 запрос | 1 мин | 1 запрос |
//
// Параметры:
//   Тело - FinancesAcquiringReportsDetailedReq
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV1AcquiringDetailed(Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		"/api/finance/v1/acquiring/detailed",
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://finance-api.wildberries.ru");

КонецФункции

// Детализации к отчётам об издержках на приём платежей по ID отчётов
//
// Метод [доступен](https://dev.wildberries.ru/openapi/api-information#tag/authorization/Pravila-ispolzovaniya-tokenov-dostupa-k-API) по
// **Персональному** токену,
// **Сервисному** токену
//
// Метод возвращает детализации к [отчётам об издержках на приём платежей](https://seller.wildberries.ru/suppliers-mutual-settlements/reports-implementations/acquiring-reports) по ID отчётов.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 1 запрос | 1 мин | 1 запрос |
//
// Параметры:
//   reportId - Число - ID отчёта
//   Тело - FinancesFinancialReportsDetailedReportIdReq
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV1AcquiringDetailedReportId(Знач reportId, Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		СтрШаблон("/api/finance/v1/acquiring/detailed/%1", Транспорт.ЭкранироватьСегмент(reportId)),
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://finance-api.wildberries.ru");

КонецФункции

// Список отчётов об издержках на приём платежей
//
// Метод [доступен](https://dev.wildberries.ru/openapi/api-information#tag/authorization/Pravila-ispolzovaniya-tokenov-dostupa-k-API) по
// **Персональному** токену,
// **Сервисному** токену
//
// Метод возвращает список отчётов об издержках на приём платежей по формату [таблицы отчётов](https://seller.wildberries.ru/suppliers-mutual-settlements/reports-implementations/acquiring-reports).
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 1 запрос | 1 мин | 1 запрос |
//
// Параметры:
//   Тело - FinancesAcquiringReportListReq
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV1AcquiringList(Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		"/api/finance/v1/acquiring/list",
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://finance-api.wildberries.ru");

КонецФункции

// Детализации к отчётам реализации за период
//
// Метод возвращает детализации к [отчётам реализации](https://seller.wildberries.ru/suppliers-mutual-settlements) за указанный период.
//
// Данные доступны с 29 января 2024 года.
//
// Вы можете выгрузить данные в [Google Таблицы](https://dev.wildberries.ru/knowledge-base/articles/019d49a4-650c-7b04-9596-ba441936f9d3)
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца:
// | Тип | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- | --- |
// | Персональный | 1 мин | 1 запрос | 1 мин | 1 запрос |
// | Сервисный | 1 мин | 1 запрос | 1 мин | 1 запрос |
// | Базовый с секретом | 1 мин | 1 запрос | 1 мин | 1 запрос |
// | Базовый | 24 ч | 2 запроса | 12 ч | 1 запрос |
//
// Параметры:
//   Тело - FinancesSalesReportsDetailedReq
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV1SalesReportsDetailed(Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		"/api/finance/v1/sales-reports/detailed",
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://finance-api.wildberries.ru");

КонецФункции

// Детализации к отчётам реализации по ID отчётов
//
// Метод [доступен](https://dev.wildberries.ru/openapi/api-information#tag/authorization/Pravila-ispolzovaniya-tokenov-dostupa-k-API) по
// **Персональному** токену,
// **Сервисному** токену
//
// Метод возвращает детализации к [отчётам реализации](https://seller.wildberries.ru/suppliers-mutual-settlements) по ID отчётов.
//
// Данные доступны с 29 января 2024 года.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 1 запрос | 1 мин | 1 запрос |
//
// Параметры:
//   reportId - Число - ID отчёта. Для ежедневных отчётов вместо стандартной десериализации рекомендуем использовать нестандартные библиотеки с поддержкой [BigInt](https://www.npmjs.co…
//   Тело - FinancesFinancialReportsDetailedReportIdReq
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV1SalesReportsDetailedReportId(Знач reportId, Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		СтрШаблон("/api/finance/v1/sales-reports/detailed/%1", Транспорт.ЭкранироватьСегмент(reportId)),
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://finance-api.wildberries.ru");

КонецФункции

// Список отчётов реализации
//
// Метод [доступен](https://dev.wildberries.ru/openapi/api-information#tag/authorization/Pravila-ispolzovaniya-tokenov-dostupa-k-API) по
// **Персональному** токену,
// **Сервисному** токену
//
// Метод возвращает список отчётов релизации по формату [таблицы отчётов](https://seller.wildberries.ru/suppliers-mutual-settlements).
//
// Данные доступны с 29 января 2024 года.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 1 запрос | 1 мин | 1 запрос |
//
// Параметры:
//   Тело - FinancesSalesReportListReq
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV1SalesReportsList(Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		"/api/finance/v1/sales-reports/list",
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://finance-api.wildberries.ru");

КонецФункции

