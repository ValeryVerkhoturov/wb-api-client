// RatesModelsWarehouseReturnRates
//
// Класс сформирован автоматически (onescript) из спецификации OpenAPI.
// Правки будут потеряны при следующей генерации.

// deliveryDumpKgtOfficeBase - Строка - **Стоимость возврата при грузовой доставке, доставка на ПВЗ (базовая цена за 1 л), ₽** Применяется для крупногабаритных товаров, когда: - продавец хочет вывезти…
Перем deliveryDumpKgtOfficeBase Экспорт;

// deliveryDumpKgtOfficeLiter - Строка - \\*\\*Стоимость возврата при грузовой доставке, доставка на ПВЗ (доп. литр), ₽\\*\\* Стоимость за каждый дополнительный литр.
Перем deliveryDumpKgtOfficeLiter Экспорт;

// deliveryDumpKgtReturnExpr - Строка - \\*\\*Стоимость возврата при грузовой доставке, обратная логистика невостребованного возврата, ₽\\*\\* Грузовая доставка невостребованного возврата обратно на с…
Перем deliveryDumpKgtReturnExpr Экспорт;

// deliveryDumpSrgOfficeExpr - Строка - \\*\\*Стоимость возврата неопознанного складом товара за каждую единицу, доставка на ПВЗ, ₽\\*\\* Применяется для товаров, которые не смогли принять на складе.
Перем deliveryDumpSrgOfficeExpr Экспорт;

// deliveryDumpSrgReturnExpr - Строка - \\*\\*Стоимость возврата неопознанного складом товара за каждую единицу, обратная логистика невостребованного возврата, ₽\\*\\* Доставка невостребованного возвр…
Перем deliveryDumpSrgReturnExpr Экспорт;

// deliveryDumpSupCourierBase - Строка - **Стоимость возврата, доставка курьером (базовая цена за 1 л), ₽** Применяется, когда: - продавец хочет вывезти товары со склада Wildberries - на складе обнаруж…
Перем deliveryDumpSupCourierBase Экспорт;

// deliveryDumpSupCourierLiter - Строка - \\*\\*Стоимость возврата, доставка курьером (доп. л), ₽\\*\\* Стоимость за каждый дополнительный литр.
Перем deliveryDumpSupCourierLiter Экспорт;

// deliveryDumpSupOfficeBase - Строка - **Стоимость возврата, доставка на ПВЗ (базовая цена за 1 л), ₽** Применяется, когда: - продавец хочет вывезти товары со склада Wildberries - на складе обнаружил…
Перем deliveryDumpSupOfficeBase Экспорт;

// deliveryDumpSupOfficeLiter - Строка - \\*\\*Стоимость возврата, доставка на ПВЗ (доп. литр), ₽\\*\\* Стоимость за каждый дополнительный литр
Перем deliveryDumpSupOfficeLiter Экспорт;

// deliveryDumpSupReturnExpr - Строка - \\*\\*Стоимость возврата, обратная логистика невостребованного возврата, за единицу товара, ₽\\*\\* Доставка невостребованного возврата обратно на склад Wildber…
Перем deliveryDumpSupReturnExpr Экспорт;

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
	Если Значения.Получить("deliveryDumpKgtOfficeBase") <> Неопределено Тогда
		deliveryDumpKgtOfficeBase = Значения.Получить("deliveryDumpKgtOfficeBase");
	КонецЕсли;
	Если Значения.Получить("deliveryDumpKgtOfficeLiter") <> Неопределено Тогда
		deliveryDumpKgtOfficeLiter = Значения.Получить("deliveryDumpKgtOfficeLiter");
	КонецЕсли;
	Если Значения.Получить("deliveryDumpKgtReturnExpr") <> Неопределено Тогда
		deliveryDumpKgtReturnExpr = Значения.Получить("deliveryDumpKgtReturnExpr");
	КонецЕсли;
	Если Значения.Получить("deliveryDumpSrgOfficeExpr") <> Неопределено Тогда
		deliveryDumpSrgOfficeExpr = Значения.Получить("deliveryDumpSrgOfficeExpr");
	КонецЕсли;
	Если Значения.Получить("deliveryDumpSrgReturnExpr") <> Неопределено Тогда
		deliveryDumpSrgReturnExpr = Значения.Получить("deliveryDumpSrgReturnExpr");
	КонецЕсли;
	Если Значения.Получить("deliveryDumpSupCourierBase") <> Неопределено Тогда
		deliveryDumpSupCourierBase = Значения.Получить("deliveryDumpSupCourierBase");
	КонецЕсли;
	Если Значения.Получить("deliveryDumpSupCourierLiter") <> Неопределено Тогда
		deliveryDumpSupCourierLiter = Значения.Получить("deliveryDumpSupCourierLiter");
	КонецЕсли;
	Если Значения.Получить("deliveryDumpSupOfficeBase") <> Неопределено Тогда
		deliveryDumpSupOfficeBase = Значения.Получить("deliveryDumpSupOfficeBase");
	КонецЕсли;
	Если Значения.Получить("deliveryDumpSupOfficeLiter") <> Неопределено Тогда
		deliveryDumpSupOfficeLiter = Значения.Получить("deliveryDumpSupOfficeLiter");
	КонецЕсли;
	Если Значения.Получить("deliveryDumpSupReturnExpr") <> Неопределено Тогда
		deliveryDumpSupReturnExpr = Значения.Получить("deliveryDumpSupReturnExpr");
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
	Если deliveryDumpKgtOfficeBase <> Неопределено Тогда
		Результат.Вставить("deliveryDumpKgtOfficeBase", ЗначениеДляJSON(deliveryDumpKgtOfficeBase));
	КонецЕсли;
	Если deliveryDumpKgtOfficeLiter <> Неопределено Тогда
		Результат.Вставить("deliveryDumpKgtOfficeLiter", ЗначениеДляJSON(deliveryDumpKgtOfficeLiter));
	КонецЕсли;
	Если deliveryDumpKgtReturnExpr <> Неопределено Тогда
		Результат.Вставить("deliveryDumpKgtReturnExpr", ЗначениеДляJSON(deliveryDumpKgtReturnExpr));
	КонецЕсли;
	Если deliveryDumpSrgOfficeExpr <> Неопределено Тогда
		Результат.Вставить("deliveryDumpSrgOfficeExpr", ЗначениеДляJSON(deliveryDumpSrgOfficeExpr));
	КонецЕсли;
	Если deliveryDumpSrgReturnExpr <> Неопределено Тогда
		Результат.Вставить("deliveryDumpSrgReturnExpr", ЗначениеДляJSON(deliveryDumpSrgReturnExpr));
	КонецЕсли;
	Если deliveryDumpSupCourierBase <> Неопределено Тогда
		Результат.Вставить("deliveryDumpSupCourierBase", ЗначениеДляJSON(deliveryDumpSupCourierBase));
	КонецЕсли;
	Если deliveryDumpSupCourierLiter <> Неопределено Тогда
		Результат.Вставить("deliveryDumpSupCourierLiter", ЗначениеДляJSON(deliveryDumpSupCourierLiter));
	КонецЕсли;
	Если deliveryDumpSupOfficeBase <> Неопределено Тогда
		Результат.Вставить("deliveryDumpSupOfficeBase", ЗначениеДляJSON(deliveryDumpSupOfficeBase));
	КонецЕсли;
	Если deliveryDumpSupOfficeLiter <> Неопределено Тогда
		Результат.Вставить("deliveryDumpSupOfficeLiter", ЗначениеДляJSON(deliveryDumpSupOfficeLiter));
	КонецЕсли;
	Если deliveryDumpSupReturnExpr <> Неопределено Тогда
		Результат.Вставить("deliveryDumpSupReturnExpr", ЗначениеДляJSON(deliveryDumpSupReturnExpr));
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

