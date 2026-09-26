// ОперацииПриПриёмкеApi
//
// Класс сформирован автоматически (onescript) из спецификации OpenAPI.
// Правки будут потеряны при следующей генерации.
//
// Пример:
//   Настройки = Новый Конфигурация();
//   Настройки.УстановитьТокен("...");
//   Клиент = Новый ОперацииПриПриёмкеApi(Настройки);

Перем Настройки Экспорт;
Перем Транспорт Экспорт;

Процедура ПриСозданииОбъекта(Знач ВходящиеНастройки)
	Настройки = ВходящиеНастройки;
	Транспорт = Новый ТранспортHTTP(Настройки);
КонецПроцедуры

// Создать отчёт
//
// Метод создаёт [задание на генерацию](https://dev.wildberries.ru/openapi/reports#tag/acceptanceExpenses/operation/getV1AcceptanceReportTasksTaskIdStatus) отчёта об [операциях при приёмке](https://dev.wildberries.ru/openapi/reports#tag/acceptanceExpenses/operation/getV1AcceptanceReportTasksTaskIdDownload).
//
// Можно получить отчёт максимум за 31 день.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца:
// | Тип | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- | --- |
// | Персональный | 1 мин | 1 запрос | 1 мин | 1 запрос |
// | Сервисный | 1 мин | 1 запрос | 1 мин | 1 запрос |
// | Базовый с секретом | 1 мин | 1 запрос | 1 мин | 1 запрос |
// | Базовый | 3 ч | 1 запрос | 3 ч | 1 запрос |
//
// Параметры:
//   dateFrom - Строка - Начало отчётного периода, `ГГГГ-ММ-ДД`
//   dateTo - Строка - Конец отчётного периода, `ГГГГ-ММ-ДД`
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция GetV1AcceptanceReport(Знач dateFrom, Знач dateTo) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	ПараметрыЗапроса.Вставить("dateFrom", dateFrom);
	ПараметрыЗапроса.Вставить("dateTo", dateTo);
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"GET",
		"/api/v1/acceptance_report",
		ПараметрыЗапроса,
		Заголовки,
		Неопределено,
		"https://seller-analytics-api.wildberries.ru");

КонецФункции

// Получить отчёт
//
// Метод возвращает отчёт об [операциях при приёмке](https://seller.wildberries.ru/analytics-reports/acceptance-report) по ID [задания на генерацию](https://dev.wildberries.ru/openapi/reports#tag/acceptanceExpenses/operation/getV1AcceptanceReport).
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца:
// | Тип | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- | --- |
// | Персональный | 1 мин | 1 запрос | 1 мин | 1 запрос |
// | Сервисный | 1 мин | 1 запрос | 1 мин | 1 запрос |
// | Базовый с секретом | 1 мин | 1 запрос | 1 мин | 1 запрос |
// | Базовый | 1 ч | 2 запроса | 30 мин | 1 запрос |
//
// Параметры:
//   task_id - Строка - ID задания на генерацию
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция GetV1AcceptanceReportTasksTaskIdDownload(Знач task_id) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"GET",
		СтрШаблон("/api/v1/acceptance_report/tasks/%1/download", Транспорт.ЭкранироватьСегмент(task_id)),
		ПараметрыЗапроса,
		Заголовки,
		Неопределено,
		"https://seller-analytics-api.wildberries.ru");

КонецФункции

// Проверить статус
//
// Метод возвращает статус [задания на генерацию](https://dev.wildberries.ru/openapi/reports#tag/acceptanceExpenses/operation/getV1AcceptanceReport) отчёта об [операциях при приёмке](https://dev.wildberries.ru/openapi/reports#tag/acceptanceExpenses/operation/getV1AcceptanceReportTasksTaskIdDownload).
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца:
// | Тип | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- | --- |
// | Персональный | 5 сек | 1 запрос | 5 сек | 1 запрос |
// | Сервисный | 5 сек | 1 запрос | 5 сек | 1 запрос |
// | Базовый с секретом | 5 сек | 1 запрос | 5 сек | 1 запрос |
// | Базовый | 1 ч | 2 запроса | 30 мин | 1 запрос |
//
// Параметры:
//   task_id - Строка - ID задания на генерацию
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция GetV1AcceptanceReportTasksTaskIdStatus(Знач task_id) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"GET",
		СтрШаблон("/api/v1/acceptance_report/tasks/%1/status", Транспорт.ЭкранироватьСегмент(task_id)),
		ПараметрыЗапроса,
		Заголовки,
		Неопределено,
		"https://seller-analytics-api.wildberries.ru");

КонецФункции

