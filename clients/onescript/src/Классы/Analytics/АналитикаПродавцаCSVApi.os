// АналитикаПродавцаCSVApi
//
// Класс сформирован автоматически (onescript) из спецификации OpenAPI.
// Правки будут потеряны при следующей генерации.
//
// Пример:
//   Настройки = Новый Конфигурация();
//   Настройки.УстановитьТокен("...");
//   Клиент = Новый АналитикаПродавцаCSVApi(Настройки);

Перем Настройки Экспорт;
Перем Транспорт Экспорт;

Процедура ПриСозданииОбъекта(Знач ВходящиеНастройки)
	Настройки = ВходящиеНастройки;
	Транспорт = Новый ТранспортHTTP(Настройки);
КонецПроцедуры

// Получить список отчётов
//
// Метод возвращает список отчётов с расширенной аналитикой продавца. Ответ содержит ID [созданных отчётов](https://dev.wildberries.ru/openapi/analytics#tag/sellerAnalyticsCsv/operation/postV2NmReportDownloads) и статусы генерации.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца:
// | Тип | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- | --- |
// | Персональный | 1 мин | 3 запроса | 20 сек | 3 запроса |
// | Сервисный | 1 мин | 3 запроса | 20 сек | 3 запроса |
// | Базовый с секретом | 1 мин | 3 запроса | 20 сек | 3 запроса |
// | Базовый | 1 ч | 1 запрос | 1 ч | 1 запрос |
//
// Параметры:
//   ДопПараметры - Структура, Соответствие - необязательные параметры:
//    * filter[downloadIds] - Массив - ID отчёта
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция GetV2NmReportDownloads(Знач ДопПараметры = Неопределено) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;

	ИменаЗаголовков = Новый Массив;
	Транспорт.РазложитьПараметры(ДопПараметры, ИменаЗаголовков, ПараметрыЗапроса, Заголовки);
	Возврат Транспорт.ВыполнитьЗапрос(
		"GET",
		"/api/v2/nm-report/downloads",
		ПараметрыЗапроса,
		Заголовки,
		Неопределено,
		"https://seller-analytics-api.wildberries.ru");

КонецФункции

// Получить отчёт
//
// Метод возвращает отчёт с расширенной аналитикой продавца по ID [задания на генерацию](https://dev.wildberries.ru/openapi/analytics#tag/sellerAnalyticsCsv/operation/postV2NmReportDownloads).
//
// Можно получить отчёт, который сгенерирован за последние 48 часов.
// Отчёт будет загружен внутри архива ZIP в формате CSV.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца:
// | Тип | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- | --- |
// | Персональный | 1 мин | 3 запроса | 20 сек | 3 запроса |
// | Сервисный | 1 мин | 3 запроса | 20 сек | 3 запроса |
// | Базовый с секретом | 1 мин | 3 запроса | 20 сек | 3 запроса |
// | Базовый | 1 ч | 1 запрос | 1 ч | 1 запрос |
//
// Параметры:
//   downloadId - Строка - ID отчёта
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция GetV2NmReportDownloadsFileDownloadId(Знач downloadId) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"GET",
		СтрШаблон("/api/v2/nm-report/downloads/file/%1", Транспорт.ЭкранироватьСегмент(downloadId)),
		ПараметрыЗапроса,
		Заголовки,
		Неопределено,
		"https://seller-analytics-api.wildberries.ru");

КонецФункции

// Создать отчёт
//
// Метод создаёт задание на генерацию отчёта с расширенной аналитикой продавца.
//
// Вы можете создать CSV-версии отчётов по [воронке продаж](https://dev.wildberries.ru/openapi/analytics#tag/salesFunnel) или [параметрам поиска](https://dev.wildberries.ru/openapi/analytics#tag/searchQueriesForYourItems) с группировкой по:
// \\* артикулам WB
// \\* предметам, брендам и ярлыкам
// В отчётах по воронке продаж можно группировать данные по дням, неделям или месяцам.
//
// Также можете создать CSV-версии отчётов по [текстам поисковых запросов](https://dev.wildberries.ru/openapi/analytics#tag/searchQueriesForYourItems/operation/postV2SearchReportProductSearchTexts) и [остаткам](https://dev.wildberries.ru/openapi/analytics#tag/stocksReport).
//
// Каждый новый отчёт должен иметь уникальный ID.
//
// Не используйте одинаковые ID для разных отчётов — это может привести к ошибкам при генерации
//
// Набор параметров запроса в объекте `params` зависит от типа отчёта. Чтобы получить описание параметров, выберите тип отчёта в раскрывающемся списке в описании параметра `reportType`.
//
// Параметры `includeSubstitutedSKUs` и `includeSearchTexts` не могут одновременно иметь значение `false`.
//
// Если не удалось [получить отчёт](https://dev.wildberries.ru/openapi/analytics#tag/sellerAnalyticsCsv/operation/getV2NmReportDownloadsFileDownloadId), можно создать [повторное задание на генерацию](https://dev.wildberries.ru/openapi/analytics#tag/sellerAnalyticsCsv/operation/postV2NmReportDownloadsRetry). Также можно [получить список и проверить статусы](https://dev.wildberries.ru/openapi/analytics#tag/sellerAnalyticsCsv/operation/getV2NmReportDownloads) отчётов.
//
// Отчёты по [остаткам](https://seller.wildberries.ru/content-analytics/history-remains) — типы `STOCK_HISTORY_REPORT_CSV` и `STOCK_HISTORY_DAILY_CSV` — можно создать без подписки [Джем](https://seller.wildberries.ru/monetization/jam)
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца:
// | Тип | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- | --- |
// | Персональный | 1 мин | 3 запроса | 20 сек | 3 запроса |
// | Сервисный | 1 мин | 3 запроса | 20 сек | 3 запроса |
// | Базовый с секретом | 1 мин | 3 запроса | 20 сек | 3 запроса |
// | Базовый | 1 ч | 1 запрос | 1 ч | 1 запрос |
//
// Параметры:
//   Тело - AnalyticsPostV2NmReportDownloadsRequest
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV2NmReportDownloads(Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		"/api/v2/nm-report/downloads",
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://seller-analytics-api.wildberries.ru");

КонецФункции

// Сгенерировать отчёт повторно
//
// Метод создает повторное [задание на генерацию](https://dev.wildberries.ru/openapi/analytics#tag/sellerAnalyticsCsv/operation/postV2NmReportDownloads) отчёта с расширенной аналитикой продавца. Необходимо, если при генерации отчёта вы [получили статус](https://dev.wildberries.ru/openapi/analytics#tag/sellerAnalyticsCsv/operation/getV2NmReportDownloads) `FAILED`.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца:
// | Тип | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- | --- |
// | Персональный | 1 мин | 3 запроса | 20 сек | 3 запроса |
// | Сервисный | 1 мин | 3 запроса | 20 сек | 3 запроса |
// | Базовый с секретом | 1 мин | 3 запроса | 20 сек | 3 запроса |
// | Базовый | 1 ч | 1 запрос | 1 ч | 1 запрос |
//
// Параметры:
//   Тело - AnalyticsNmReportRetryReportRequest
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция PostV2NmReportDownloadsRetry(Знач Тело) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"POST",
		"/api/v2/nm-report/downloads/retry",
		ПараметрыЗапроса,
		Заголовки,
		Тело,
		"https://seller-analytics-api.wildberries.ru");

КонецФункции

