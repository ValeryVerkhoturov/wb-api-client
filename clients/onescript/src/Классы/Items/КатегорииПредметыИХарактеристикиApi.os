// КатегорииПредметыИХарактеристикиApi
//
// Класс сформирован автоматически (onescript) из спецификации OpenAPI.
// Правки будут потеряны при следующей генерации.
//
// Пример:
//   Настройки = Новый Конфигурация();
//   Настройки.УстановитьТокен("...");
//   Клиент = Новый КатегорииПредметыИХарактеристикиApi(Настройки);

Перем Настройки Экспорт;
Перем Транспорт Экспорт;

Процедура ПриСозданииОбъекта(Знач ВходящиеНастройки)
	Настройки = ВходящиеНастройки;
	Транспорт = Новый ТранспортHTTP(Настройки);
КонецПроцедуры

// Бренды
//
// Метод возвращает список брендов по ID предмета.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца:
// | Тип | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- | --- |
// | Персональный | 1 сек | 1 запрос | 1 сек | 5 запросов |
// | Сервисный | 1 сек | 1 запрос | 1 сек | 5 запросов |
// | Базовый с секретом | 1 сек | 1 запрос | 1 сек | 5 запросов |
// | Базовый | 1 ч | 1 запрос | 1 ч | 1 запрос |
//
// Параметры:
//   subjectId - Число - ID предмета
//   ДопПараметры - Структура, Соответствие - необязательные параметры:
//    * next - Число - Параметр пагинации. Используйте значение `next` из ответа, чтобы получить следующий пакет данных
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция GetV1Brands(Знач subjectId, Знач ДопПараметры = Неопределено) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	ПараметрыЗапроса.Вставить("subjectId", subjectId);
	Заголовки = Новый Соответствие;

	ИменаЗаголовков = Новый Массив;
	Транспорт.РазложитьПараметры(ДопПараметры, ИменаЗаголовков, ПараметрыЗапроса, Заголовки);
	Возврат Транспорт.ВыполнитьЗапрос(
		"GET",
		"/api/content/v1/brands",
		ПараметрыЗапроса,
		Заголовки,
		Неопределено,
		"https://content-api.wildberries.ru");

КонецФункции

// Цвет
//
// Метод возвращает возможные значения [характеристики](https://dev.wildberries.ru/openapi/item-management#tag/categoriesSubcategoriesAndCharacteristics/operation/getV2ObjectCharcsSubjectId) предмета `Цвет`.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца для методов **Характеристик**:
// | Тип | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- | --- |
// | Персональный | 1 мин | 100 запросов | 600 мс | 5 запросов |
// | Сервисный | 1 мин | 100 запросов | 600 мс | 5 запросов |
// | Базовый с секретом | 1 мин | 100 запросов | 600 мс | 5 запросов |
// | Базовый | 1 ч | 2 запроса | 30 мин | 1 запрос |
//
// ---
//
// В [песочнице](https://dev.wildberries.ru/sandbox) — максимум 1 запрос в секунду суммарно для всех методов **Контента**.
//
// Параметры:
//   ДопПараметры - Структура, Соответствие - необязательные параметры:
//    * locale - Строка - Язык полей ответа `subjectName` и `name`: - `ru` — русский - `en` — английский - `zh` — китайский Не используется в песочнице. Данные песочницы возвращаются тол…
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция GetV2DirectoryColors(Знач ДопПараметры = Неопределено) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;

	ИменаЗаголовков = Новый Массив;
	Транспорт.РазложитьПараметры(ДопПараметры, ИменаЗаголовков, ПараметрыЗапроса, Заголовки);
	Возврат Транспорт.ВыполнитьЗапрос(
		"GET",
		"/content/v2/directory/colors",
		ПараметрыЗапроса,
		Заголовки,
		Неопределено,
		"https://content-api.wildberries.ru");

КонецФункции

// Страна производства
//
// Метод возвращает возможные значения [характеристики](https://dev.wildberries.ru/openapi/item-management#tag/categoriesSubcategoriesAndCharacteristics/operation/getV2ObjectCharcsSubjectId) предмета `Страна производства`.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца для всех методов категории **Контент**:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 100 запросов | 600 мс | 5 запросов |
// Исключение — методы:
//
// * [создания карточек товаров](https://dev.wildberries.ru/openapi/item-management#tag/listingItems/operation/postV2CardsUpload)
// * [создания карточек товаров с присоединением](https://dev.wildberries.ru/openapi/item-management#tag/listingItems/operation/postV2CardsUploadAdd)
// * [редактирования карточек товаров](https://dev.wildberries.ru/openapi/item-management#tag/listings/operation/postV2CardsUpdate)
// * [восстановления карточек товаров из корзины](https://dev.wildberries.ru/openapi/item-management#tag/listings/operation/postV2CardsRecover)
// * [получения списка рекомендаций в карточках товаров](https://dev.wildberries.ru/openapi/item-management#tag/recommendations/operation/postV1RecommendationsList)
// * [установки рекомендаций для товаров](https://dev.wildberries.ru/openapi/item-management#tag/recommendations/operation/postV1RecommendationsSet)
//
// ---
//
// В [песочнице](https://dev.wildberries.ru/sandbox) — максимум 1 запрос в секунду суммарно для всех методов **Контента**.
//
// Параметры:
//   ДопПараметры - Структура, Соответствие - необязательные параметры:
//    * locale - Строка - Язык полей ответа `subjectName` и `name`: - `ru` — русский - `en` — английский - `zh` — китайский Не используется в песочнице. Данные песочницы возвращаются тол…
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция GetV2DirectoryCountries(Знач ДопПараметры = Неопределено) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;

	ИменаЗаголовков = Новый Массив;
	Транспорт.РазложитьПараметры(ДопПараметры, ИменаЗаголовков, ПараметрыЗапроса, Заголовки);
	Возврат Транспорт.ВыполнитьЗапрос(
		"GET",
		"/content/v2/directory/countries",
		ПараметрыЗапроса,
		Заголовки,
		Неопределено,
		"https://content-api.wildberries.ru");

КонецФункции

// Пол
//
// Метод возвращает возможные значения [характеристики](https://dev.wildberries.ru/openapi/item-management#tag/categoriesSubcategoriesAndCharacteristics/operation/getV2ObjectCharcsSubjectId) предмета `Пол`.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца для методов **Характеристик**:
// | Тип | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- | --- |
// | Персональный | 1 мин | 100 запросов | 600 мс | 5 запросов |
// | Сервисный | 1 мин | 100 запросов | 600 мс | 5 запросов |
// | Базовый с секретом | 1 мин | 100 запросов | 600 мс | 5 запросов |
// | Базовый | 1 ч | 2 запроса | 30 мин | 1 запрос |
//
// ---
//
// В [песочнице](https://dev.wildberries.ru/sandbox) — максимум 1 запрос в секунду суммарно для всех методов **Контента**.
//
// Параметры:
//   ДопПараметры - Структура, Соответствие - необязательные параметры:
//    * locale - Строка - Язык полей ответа `subjectName` и `name`: - `ru` — русский - `en` — английский - `zh` — китайский Не используется в песочнице. Данные песочницы возвращаются тол…
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция GetV2DirectoryKinds(Знач ДопПараметры = Неопределено) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;

	ИменаЗаголовков = Новый Массив;
	Транспорт.РазложитьПараметры(ДопПараметры, ИменаЗаголовков, ПараметрыЗапроса, Заголовки);
	Возврат Транспорт.ВыполнитьЗапрос(
		"GET",
		"/content/v2/directory/kinds",
		ПараметрыЗапроса,
		Заголовки,
		Неопределено,
		"https://content-api.wildberries.ru");

КонецФункции

// Сезон
//
// Метод возвращает возможные значения [характеристики](https://dev.wildberries.ru/openapi/item-management#tag/categoriesSubcategoriesAndCharacteristics/operation/getV2ObjectCharcsSubjectId) предмета `Сезон`.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца для методов **Характеристик**:
// | Тип | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- | --- |
// | Персональный | 1 мин | 100 запросов | 600 мс | 5 запросов |
// | Сервисный | 1 мин | 100 запросов | 600 мс | 5 запросов |
// | Базовый с секретом | 1 мин | 100 запросов | 600 мс | 5 запросов |
// | Базовый | 1 ч | 2 запроса | 30 мин | 1 запрос |
//
// ---
//
// В [песочнице](https://dev.wildberries.ru/sandbox) — максимум 1 запрос в секунду суммарно для всех методов **Контента**.
//
// Параметры:
//   ДопПараметры - Структура, Соответствие - необязательные параметры:
//    * locale - Строка - Язык полей ответа `subjectName` и `name`: - `ru` — русский - `en` — английский - `zh` — китайский Не используется в песочнице. Данные песочницы возвращаются тол…
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция GetV2DirectorySeasons(Знач ДопПараметры = Неопределено) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;

	ИменаЗаголовков = Новый Массив;
	Транспорт.РазложитьПараметры(ДопПараметры, ИменаЗаголовков, ПараметрыЗапроса, Заголовки);
	Возврат Транспорт.ВыполнитьЗапрос(
		"GET",
		"/content/v2/directory/seasons",
		ПараметрыЗапроса,
		Заголовки,
		Неопределено,
		"https://content-api.wildberries.ru");

КонецФункции

// ТНВЭД-код
//
// Метод возвращает список ТНВЭД-кодов по ID [предмета](https://dev.wildberries.ru/openapi/item-management#tag/categoriesSubcategoriesAndCharacteristics/operation/getV2ObjectAll) и фрагменту ТНВЭД-кода.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца для всех методов категории **Контент**:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 100 запросов | 600 мс | 5 запросов |
// Исключение — методы:
//
// * [создания карточек товаров](https://dev.wildberries.ru/openapi/item-management#tag/listingItems/operation/postV2CardsUpload)
// * [создания карточек товаров с присоединением](https://dev.wildberries.ru/openapi/item-management#tag/listingItems/operation/postV2CardsUploadAdd)
// * [редактирования карточек товаров](https://dev.wildberries.ru/openapi/item-management#tag/listings/operation/postV2CardsUpdate)
// * [восстановления карточек товаров из корзины](https://dev.wildberries.ru/openapi/item-management#tag/listings/operation/postV2CardsRecover)
// * [получения списка рекомендаций в карточках товаров](https://dev.wildberries.ru/openapi/item-management#tag/recommendations/operation/postV1RecommendationsList)
// * [установки рекомендаций для товаров](https://dev.wildberries.ru/openapi/item-management#tag/recommendations/operation/postV1RecommendationsSet)
//
// ---
//
// В [песочнице](https://dev.wildberries.ru/sandbox) — максимум 1 запрос в секунду суммарно для всех методов **Контента**.
//
// Параметры:
//   subjectID - Число - ID предмета
//   ДопПараметры - Структура, Соответствие - необязательные параметры:
//    * search - Число - Поиск по ТНВЭД-коду. Работает только в паре с `subjectID`
//    * locale - Строка - Язык полей ответа: - `ru` — русский - `en` — английский - `zh` — китайский Не используется в песочнице. Данные песочницы возвращаются только на русском языке
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция GetV2DirectoryTnved(Знач subjectID, Знач ДопПараметры = Неопределено) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	ПараметрыЗапроса.Вставить("subjectID", subjectID);
	Заголовки = Новый Соответствие;

	ИменаЗаголовков = Новый Массив;
	Транспорт.РазложитьПараметры(ДопПараметры, ИменаЗаголовков, ПараметрыЗапроса, Заголовки);
	Возврат Транспорт.ВыполнитьЗапрос(
		"GET",
		"/content/v2/directory/tnved",
		ПараметрыЗапроса,
		Заголовки,
		Неопределено,
		"https://content-api.wildberries.ru");

КонецФункции

// Ставка НДС
//
// Метод возвращает возможные значения [характеристики](https://dev.wildberries.ru/openapi/item-management#tag/categoriesSubcategoriesAndCharacteristics/operation/getV2ObjectCharcsSubjectId) предмета `Ставка НДС`.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца для методов **Характеристик**:
// | Тип | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- | --- |
// | Персональный | 1 мин | 100 запросов | 600 мс | 5 запросов |
// | Сервисный | 1 мин | 100 запросов | 600 мс | 5 запросов |
// | Базовый с секретом | 1 мин | 100 запросов | 600 мс | 5 запросов |
// | Базовый | 1 ч | 2 запроса | 30 мин | 1 запрос |
//
// ---
//
// В [песочнице](https://dev.wildberries.ru/sandbox) — максимум 1 запрос в секунду суммарно для всех методов **Контента**.
//
// Параметры:
//   ДопПараметры - Структура, Соответствие - необязательные параметры:
//    * locale - Строка - Язык полей ответа `subjectName` и `name`: - `ru` — русский - `en` — английский - `zh` — китайский Не используется в песочнице. Данные песочницы возвращаются тол…
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция GetV2DirectoryVat(Знач ДопПараметры = Неопределено) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;

	ИменаЗаголовков = Новый Массив;
	Транспорт.РазложитьПараметры(ДопПараметры, ИменаЗаголовков, ПараметрыЗапроса, Заголовки);
	Возврат Транспорт.ВыполнитьЗапрос(
		"GET",
		"/content/v2/directory/vat",
		ПараметрыЗапроса,
		Заголовки,
		Неопределено,
		"https://content-api.wildberries.ru");

КонецФункции

// Список предметов
//
// Метод возвращает список названий [родительских категорий предметов](https://dev.wildberries.ru/openapi/item-management#tag/categoriesSubcategoriesAndCharacteristics/operation/getV2ObjectParentAll) и их предметов с ID. Например, у категории `Игрушки` будут предметы `Калейдоскопы`, `Куклы`, `Мячики`.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца для всех методов категории **Контент**:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 100 запросов | 600 мс | 5 запросов |
// Исключение — методы:
//
// * [создания карточек товаров](https://dev.wildberries.ru/openapi/item-management#tag/listingItems/operation/postV2CardsUpload)
// * [создания карточек товаров с присоединением](https://dev.wildberries.ru/openapi/item-management#tag/listingItems/operation/postV2CardsUploadAdd)
// * [редактирования карточек товаров](https://dev.wildberries.ru/openapi/item-management#tag/listings/operation/postV2CardsUpdate)
// * [восстановления карточек товаров из корзины](https://dev.wildberries.ru/openapi/item-management#tag/listings/operation/postV2CardsRecover)
// * [получения списка рекомендаций в карточках товаров](https://dev.wildberries.ru/openapi/item-management#tag/recommendations/operation/postV1RecommendationsList)
// * [установки рекомендаций для товаров](https://dev.wildberries.ru/openapi/item-management#tag/recommendations/operation/postV1RecommendationsSet)
//
// ---
//
// В [песочнице](https://dev.wildberries.ru/sandbox) — максимум 1 запрос в секунду суммарно для всех методов **Контента**.
//
// Параметры:
//   ДопПараметры - Структура, Соответствие - необязательные параметры:
//    * locale - Строка - Язык полей ответа: - `ru` — русский - `en` — английский - `zh` — китайский Не используется в песочнице. Данные песочницы возвращаются только на русском языке
//    * name - Строка - Поиск по названию предмета (Носки), поиск работает по подстроке, искать можно на любом из поддерживаемых языков
//    * limit - Число - Количество предметов, максимум 1000
//    * offset - Число - Сколько элементов пропустить. Например, для значения `10` ответ начнется с 11 элемента
//    * parentID - Число - ID родительской категории предмета
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция GetV2ObjectAll(Знач ДопПараметры = Неопределено) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;

	ИменаЗаголовков = Новый Массив;
	Транспорт.РазложитьПараметры(ДопПараметры, ИменаЗаголовков, ПараметрыЗапроса, Заголовки);
	Возврат Транспорт.ВыполнитьЗапрос(
		"GET",
		"/content/v2/object/all",
		ПараметрыЗапроса,
		Заголовки,
		Неопределено,
		"https://content-api.wildberries.ru");

КонецФункции

// Характеристики предмета
//
// Метод возвращает параметры характеристик предмета: названия, типы данных, единицы измерения и так далее. В запросе необходимо указать ID [предмета](https://dev.wildberries.ru/openapi/item-management#tag/categoriesSubcategoriesAndCharacteristics/operation/getV2ObjectAll).
//
// Для получения значений характеристик [Цвет](https://dev.wildberries.ru/openapi/item-management#tag/categoriesSubcategoriesAndCharacteristics/operation/getV2DirectoryColors), [Пол](https://dev.wildberries.ru/openapi/item-management#tag/categoriesSubcategoriesAndCharacteristics/operation/getV2DirectoryKinds), [Страна производства](https://dev.wildberries.ru/openapi/item-management#tag/categoriesSubcategoriesAndCharacteristics/operation/getV2DirectoryCountries), [Сезон](https://dev.wildberries.ru/openapi/item-management#tag/categoriesSubcategoriesAndCharacteristics/operation/getV2DirectorySeasons), [Ставка НДС](https://dev.wildberries.ru/openapi/item-management#tag/categoriesSubcategoriesAndCharacteristics/operation/getV2DirectoryVat) и [ТНВЭД-код](https://dev.wildberries.ru/openapi/item-management#tag/categoriesSubcategoriesAndCharacteristics/operation/getV2DirectoryTnved) используйте отдельные методы
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца для всех методов категории **Контент**:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 100 запросов | 600 мс | 5 запросов |
// Исключение — методы:
//
// * [создания карточек товаров](https://dev.wildberries.ru/openapi/item-management#tag/listingItems/operation/postV2CardsUpload)
// * [создания карточек товаров с присоединением](https://dev.wildberries.ru/openapi/item-management#tag/listingItems/operation/postV2CardsUploadAdd)
// * [редактирования карточек товаров](https://dev.wildberries.ru/openapi/item-management#tag/listings/operation/postV2CardsUpdate)
// * [восстановления карточек товаров из корзины](https://dev.wildberries.ru/openapi/item-management#tag/listings/operation/postV2CardsRecover)
// * [получения списка рекомендаций в карточках товаров](https://dev.wildberries.ru/openapi/item-management#tag/recommendations/operation/postV1RecommendationsList)
// * [установки рекомендаций для товаров](https://dev.wildberries.ru/openapi/item-management#tag/recommendations/operation/postV1RecommendationsSet)
//
// ---
//
// В [песочнице](https://dev.wildberries.ru/sandbox) — максимум 1 запрос в секунду суммарно для всех методов **Контента**.
//
// Параметры:
//   subjectId - Число - ID предмета
//   ДопПараметры - Структура, Соответствие - необязательные параметры:
//    * locale - Строка - Язык полей ответа `subjectName` и `name`: - `ru` — русский - `en` — английский - `zh` — китайский Не используется в песочнице. Данные песочницы возвращаются тол…
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция GetV2ObjectCharcsSubjectId(Знач subjectId, Знач ДопПараметры = Неопределено) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;

	ИменаЗаголовков = Новый Массив;
	Транспорт.РазложитьПараметры(ДопПараметры, ИменаЗаголовков, ПараметрыЗапроса, Заголовки);
	Возврат Транспорт.ВыполнитьЗапрос(
		"GET",
		СтрШаблон("/content/v2/object/charcs/%1", Транспорт.ЭкранироватьСегмент(subjectId)),
		ПараметрыЗапроса,
		Заголовки,
		Неопределено,
		"https://content-api.wildberries.ru");

КонецФункции

// Родительские категории товаров
//
// Метод возвращает названия и ID всех родительских категорий для [создания карточек товаров](https://dev.wildberries.ru/openapi/item-management#tag/listingItems): например, `Электроника`, `Бытовая химия`, `Рукоделие`.
//
// [Лимит запросов](https://dev.wildberries.ru/openapi/api-information#tag/introduction/Limity-zaprosov) на один аккаунт продавца для всех методов категории **Контент**:
// | Период | Лимит | Интервал | Всплеск |
// | --- | --- | --- | --- |
// | 1 мин | 100 запросов | 600 мс | 5 запросов |
// Исключение — методы:
//
// * [создания карточек товаров](https://dev.wildberries.ru/openapi/item-management#tag/listingItems/operation/postV2CardsUpload)
// * [создания карточек товаров с присоединением](https://dev.wildberries.ru/openapi/item-management#tag/listingItems/operation/postV2CardsUploadAdd)
// * [редактирования карточек товаров](https://dev.wildberries.ru/openapi/item-management#tag/listings/operation/postV2CardsUpdate)
// * [восстановления карточек товаров из корзины](https://dev.wildberries.ru/openapi/item-management#tag/listings/operation/postV2CardsRecover)
// * [получения списка рекомендаций в карточках товаров](https://dev.wildberries.ru/openapi/item-management#tag/recommendations/operation/postV1RecommendationsList)
// * [установки рекомендаций для товаров](https://dev.wildberries.ru/openapi/item-management#tag/recommendations/operation/postV1RecommendationsSet)
//
// ---
//
// В [песочнице](https://dev.wildberries.ru/sandbox) — максимум 1 запрос в секунду суммарно для всех методов **Контента**.
//
// Параметры:
//   ДопПараметры - Структура, Соответствие - необязательные параметры:
//    * locale - Строка - Язык поля ответа `name`: - `ru` — русский - `en` — английский - `zh` — китайский Не используется в песочнице. Данные песочницы возвращаются только на русском яз…
//
// Возвращаемое значение:
//   ОтветAPI
//
Функция GetV2ObjectParentAll(Знач ДопПараметры = Неопределено) Экспорт

	ПараметрыЗапроса = Новый Соответствие;
	Заголовки = Новый Соответствие;

	ИменаЗаголовков = Новый Массив;
	Транспорт.РазложитьПараметры(ДопПараметры, ИменаЗаголовков, ПараметрыЗапроса, Заголовки);
	Возврат Транспорт.ВыполнитьЗапрос(
		"GET",
		"/content/v2/object/parent/all",
		ПараметрыЗапроса,
		Заголовки,
		Неопределено,
		"https://content-api.wildberries.ru");

КонецФункции

