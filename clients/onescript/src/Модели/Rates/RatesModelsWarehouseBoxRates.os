// RatesModelsWarehouseBoxRates
//
// Класс сформирован автоматически (onescript) из спецификации OpenAPI.
// Правки будут потеряны при следующей генерации.

// boxDeliveryBase - Строка - Логистика, первый литр, ₽
Перем boxDeliveryBase Экспорт;

// boxDeliveryCoefExpr - Строка - Коэффициент **Логистика**, %. На него умножается стоимость логистики. Уже учтён в тарифах
Перем boxDeliveryCoefExpr Экспорт;

// boxDeliveryLiter - Строка - Логистика, дополнительный литр, ₽
Перем boxDeliveryLiter Экспорт;

// boxDeliveryMarketplaceBase - Строка - Логистика FBS, первый литр, ₽
Перем boxDeliveryMarketplaceBase Экспорт;

// boxDeliveryMarketplaceCoefExpr - Строка - Коэффициент **FBS**, %. На него умножается стоимость логистики FBS. Уже учтён в тарифах
Перем boxDeliveryMarketplaceCoefExpr Экспорт;

// boxDeliveryMarketplaceLiter - Строка - Логистика FBS, дополнительный литр, ₽
Перем boxDeliveryMarketplaceLiter Экспорт;

// boxStorageBase - Строка - Хранение в день, первый литр, ₽
Перем boxStorageBase Экспорт;

// boxStorageCoefExpr - Строка - Коэффициент **Хранение**, %. На него умножается стоимость хранения в день. Уже учтён в тарифах
Перем boxStorageCoefExpr Экспорт;

// boxStorageLiter - Строка - Хранение в день, дополнительный литр, ₽
Перем boxStorageLiter Экспорт;

// geoName - Строка - Местонахождение склада
Перем geoName Экспорт;

// warehouseName - Строка - Название склада
Перем warehouseName Экспорт;

// Параметры:
//   Данные - Соответствие, Структура - исходные значения, разобранные из JSON.
//
Процедура ПриСозданииОбъекта(Знач Данные = Неопределено)

	Если Данные <> Неопределено Тогда
		Заполнить(Данные);
	КонецЕсли;

КонецПроцедуры

// Заполняет свойства из коллекции, полученной из JSON.
//
// Параметры:
//   Данные - Соответствие, Структура - исходные значения.
//
Процедура Заполнить(Знач Данные) Экспорт

	Если Данные = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Значения = Новый Соответствие;
	Для Каждого ЭлементДанных Из Данные Цикл
		Значения.Вставить(Строка(ЭлементДанных.Ключ), ЭлементДанных.Значение);
	КонецЦикла;
	Если Значения.Получить("boxDeliveryBase") <> Неопределено Тогда
		boxDeliveryBase = Значения.Получить("boxDeliveryBase");
	КонецЕсли;
	Если Значения.Получить("boxDeliveryCoefExpr") <> Неопределено Тогда
		boxDeliveryCoefExpr = Значения.Получить("boxDeliveryCoefExpr");
	КонецЕсли;
	Если Значения.Получить("boxDeliveryLiter") <> Неопределено Тогда
		boxDeliveryLiter = Значения.Получить("boxDeliveryLiter");
	КонецЕсли;
	Если Значения.Получить("boxDeliveryMarketplaceBase") <> Неопределено Тогда
		boxDeliveryMarketplaceBase = Значения.Получить("boxDeliveryMarketplaceBase");
	КонецЕсли;
	Если Значения.Получить("boxDeliveryMarketplaceCoefExpr") <> Неопределено Тогда
		boxDeliveryMarketplaceCoefExpr = Значения.Получить("boxDeliveryMarketplaceCoefExpr");
	КонецЕсли;
	Если Значения.Получить("boxDeliveryMarketplaceLiter") <> Неопределено Тогда
		boxDeliveryMarketplaceLiter = Значения.Получить("boxDeliveryMarketplaceLiter");
	КонецЕсли;
	Если Значения.Получить("boxStorageBase") <> Неопределено Тогда
		boxStorageBase = Значения.Получить("boxStorageBase");
	КонецЕсли;
	Если Значения.Получить("boxStorageCoefExpr") <> Неопределено Тогда
		boxStorageCoefExpr = Значения.Получить("boxStorageCoefExpr");
	КонецЕсли;
	Если Значения.Получить("boxStorageLiter") <> Неопределено Тогда
		boxStorageLiter = Значения.Получить("boxStorageLiter");
	КонецЕсли;
	Если Значения.Получить("geoName") <> Неопределено Тогда
		geoName = Значения.Получить("geoName");
	КонецЕсли;
	Если Значения.Получить("warehouseName") <> Неопределено Тогда
		warehouseName = Значения.Получить("warehouseName");
	КонецЕсли;
КонецПроцедуры

// Возвращает значения свойств под именами из спецификации.
//
// Незаполненные свойства пропускаются, поэтому в теле запроса не появится
// null там, где сервис ожидает отсутствие поля.
//
// Возвращаемое значение:
//   Соответствие
//
Функция Данные() Экспорт

	Результат = Новый Соответствие;
	Если boxDeliveryBase <> Неопределено Тогда
		Результат.Вставить("boxDeliveryBase", ЗначениеДляJSON(boxDeliveryBase));
	КонецЕсли;
	Если boxDeliveryCoefExpr <> Неопределено Тогда
		Результат.Вставить("boxDeliveryCoefExpr", ЗначениеДляJSON(boxDeliveryCoefExpr));
	КонецЕсли;
	Если boxDeliveryLiter <> Неопределено Тогда
		Результат.Вставить("boxDeliveryLiter", ЗначениеДляJSON(boxDeliveryLiter));
	КонецЕсли;
	Если boxDeliveryMarketplaceBase <> Неопределено Тогда
		Результат.Вставить("boxDeliveryMarketplaceBase", ЗначениеДляJSON(boxDeliveryMarketplaceBase));
	КонецЕсли;
	Если boxDeliveryMarketplaceCoefExpr <> Неопределено Тогда
		Результат.Вставить("boxDeliveryMarketplaceCoefExpr", ЗначениеДляJSON(boxDeliveryMarketplaceCoefExpr));
	КонецЕсли;
	Если boxDeliveryMarketplaceLiter <> Неопределено Тогда
		Результат.Вставить("boxDeliveryMarketplaceLiter", ЗначениеДляJSON(boxDeliveryMarketplaceLiter));
	КонецЕсли;
	Если boxStorageBase <> Неопределено Тогда
		Результат.Вставить("boxStorageBase", ЗначениеДляJSON(boxStorageBase));
	КонецЕсли;
	Если boxStorageCoefExpr <> Неопределено Тогда
		Результат.Вставить("boxStorageCoefExpr", ЗначениеДляJSON(boxStorageCoefExpr));
	КонецЕсли;
	Если boxStorageLiter <> Неопределено Тогда
		Результат.Вставить("boxStorageLiter", ЗначениеДляJSON(boxStorageLiter));
	КонецЕсли;
	Если geoName <> Неопределено Тогда
		Результат.Вставить("geoName", ЗначениеДляJSON(geoName));
	КонецЕсли;
	Если warehouseName <> Неопределено Тогда
		Результат.Вставить("warehouseName", ЗначениеДляJSON(warehouseName));
	КонецЕсли;
	Возврат Результат;

КонецФункции

Функция ЗначениеДляJSON(Знач Значение)

	Если ТипЗнч(Значение) = Тип("Массив") Тогда
		Результат = Новый Массив;
		Для Каждого ЭлементМассива Из Значение Цикл
			Результат.Добавить(ЗначениеДляJSON(ЭлементМассива));
		КонецЦикла;
		Возврат Результат;
	КонецЕсли;

	// Вложенные модели раскладываются тем же способом.
	Попытка
		Возврат Значение.Данные();
	Исключение
		Возврат Значение;
	КонецПопытки;

КонецФункции

