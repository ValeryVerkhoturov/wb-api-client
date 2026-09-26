// ПроверкаПодключенияКWBAPIApi
//
// Класс сформирован автоматически (onescript) из спецификации OpenAPI.
// Правки будут потеряны при следующей генерации.
//
// Пример:
//   Настройки = Новый Конфигурация();
//   Настройки.УстановитьТокен("...");
//   Клиент = Новый ПроверкаПодключенияКWBAPIApi(Настройки);

Перем Настройки Экспорт;
Перем Транспорт Экспорт;

Процедура ПриСозданииОбъекта(Знач ВходящиеНастройки)
	Настройки = ВходящиеНастройки;
	Транспорт = Новый ТранспортHTTP(Настройки);
КонецПроцедуры

// Проверка подключения
//
// Метод проверяет:
// 1. Успешно ли запрос доходит до WB API
// 2. Валидность токена авторизации и URL запроса
// 3. Совпадают ли категория токена и сервис
//
// Метод не предназначен для проверки доступности сервисов WB
//
// У каждого сервиса есть свой вариант метода в зависимости от домена:
// | Категория | URL запроса |
// |---------------|-----------------------|
// | Контент | `https://content-api.wildberries.ru/ping`
// `https://content-api-sandbox.wildberries.ru/ping` |
// | Аналитика | `https://seller-analytics-api.wildberries.ru/ping` |
// | Цены и скидки | `https://discounts-prices-api.wildberries.ru/ping`
// `https://discounts-prices-api-sandbox.wildberries.ru/ping` |
// | Маркетплейс | `https://marketplace-api.wildberries.ru/ping` |
// | Статистика | `https://statistics-api.wildberries.ru/ping`
// `https://statistics-api-sandbox.wildberries.ru/ping` |
// | Продвижение | `https://advert-api.wildberries.ru/ping`
// `https://advert-api-sandbox.wildberries.ru/ping` |
// | Вопросы и отзывы | `https://feedbacks-api.wildberries.ru/ping`
// `https://feedbacks-api-sandbox.wildberries.ru/ping` |
// | Чат с покупателями | `https://buyer-chat-api.wildberries.ru/ping` |
// | Поставки | `https://supplies-api.wildberries.ru/ping` |
// | Возвраты покупателями | `https://returns-api.wildberries.ru/ping` |
// | Документы | `https://documents-api.wildberries.ru/ping` |
// | Финансы | `https://finance-api.wildberries.ru/ping` |
// | Тарифы, Новости, Получить информацию о продавце | `https://common-api.wildberries.ru/ping` |
// | Управление пользователями продавца | `https://user-management-api.wildberries.ru/ping` |
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 30 сек | 3 запроса | 10 сек | 99 запросов |
//
// Лимит действует отдельно для каждого варианта метода в зависимости от домена
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция GetPing() Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;
	Возврат Транспорт.ВыполнитьЗапрос(
		"GET",
		"/ping",
		ПараметрыЗапроса,
		Заголовки,
		Неопределено,
		"https://common-api.wildberries.ru");

КонецФункции

