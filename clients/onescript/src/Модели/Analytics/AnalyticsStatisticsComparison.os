// AnalyticsStatisticsComparison
//
// Класс сформирован автоматически (onescript) из спецификации OpenAPI.
// Правки будут потеряны при следующей генерации.

// openCountDynamic - Число - Динамика переходов в карточку товара
Перем openCountDynamic Экспорт;

// cartCountDynamic - Число - Динамика добавлений в корзину
Перем cartCountDynamic Экспорт;

// orderCountDynamic - Число - Динамика количества заказов
Перем orderCountDynamic Экспорт;

// orderSumDynamic - Число - Динамика суммы заказов
Перем orderSumDynamic Экспорт;

// buyoutCountDynamic - Число - Динамика выкупов
Перем buyoutCountDynamic Экспорт;

// buyoutSumDynamic - Число - Динамика суммы выкупов
Перем buyoutSumDynamic Экспорт;

// cancelCountDynamic - Число - Динамика отмен и возвратов товаров
Перем cancelCountDynamic Экспорт;

// cancelSumDynamic - Число - Динамика сумм отмен и возвратов товаров
Перем cancelSumDynamic Экспорт;

// avgOrdersCountPerDayDynamic - Число - Динамика среднего количества заказов в день
Перем avgOrdersCountPerDayDynamic Экспорт;

// avgPriceDynamic - Число - Динамика средней цены на товары. Учитываются скидки для акций
Перем avgPriceDynamic Экспорт;

// shareOrderPercentDynamic - Число - Динамика доли в выручке
Перем shareOrderPercentDynamic Экспорт;

// addToWishlistDynamic - Число - Динамика добавлений товара в избранное
Перем addToWishlistDynamic Экспорт;

// timeToReadyDynamic - Comparison_timeToReadyDynamic
Перем timeToReadyDynamic Экспорт;

// localizationPercentDynamic - Число - Динамика локальных заказов в рамках одного региона. [На данный момент](https://dev.wildberries.ru/release-notes?id=570) может быть только `0`
Перем localizationPercentDynamic Экспорт;

// wbClubDynamic - Comparison_wbClubDynamic
Перем wbClubDynamic Экспорт;

// conversions - Statistic_conversions
Перем conversions Экспорт;

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
	Если Значения.Получить("openCountDynamic") <> Неопределено Тогда
		openCountDynamic = Значения.Получить("openCountDynamic");
	КонецЕсли;
	Если Значения.Получить("cartCountDynamic") <> Неопределено Тогда
		cartCountDynamic = Значения.Получить("cartCountDynamic");
	КонецЕсли;
	Если Значения.Получить("orderCountDynamic") <> Неопределено Тогда
		orderCountDynamic = Значения.Получить("orderCountDynamic");
	КонецЕсли;
	Если Значения.Получить("orderSumDynamic") <> Неопределено Тогда
		orderSumDynamic = Значения.Получить("orderSumDynamic");
	КонецЕсли;
	Если Значения.Получить("buyoutCountDynamic") <> Неопределено Тогда
		buyoutCountDynamic = Значения.Получить("buyoutCountDynamic");
	КонецЕсли;
	Если Значения.Получить("buyoutSumDynamic") <> Неопределено Тогда
		buyoutSumDynamic = Значения.Получить("buyoutSumDynamic");
	КонецЕсли;
	Если Значения.Получить("cancelCountDynamic") <> Неопределено Тогда
		cancelCountDynamic = Значения.Получить("cancelCountDynamic");
	КонецЕсли;
	Если Значения.Получить("cancelSumDynamic") <> Неопределено Тогда
		cancelSumDynamic = Значения.Получить("cancelSumDynamic");
	КонецЕсли;
	Если Значения.Получить("avgOrdersCountPerDayDynamic") <> Неопределено Тогда
		avgOrdersCountPerDayDynamic = Значения.Получить("avgOrdersCountPerDayDynamic");
	КонецЕсли;
	Если Значения.Получить("avgPriceDynamic") <> Неопределено Тогда
		avgPriceDynamic = Значения.Получить("avgPriceDynamic");
	КонецЕсли;
	Если Значения.Получить("shareOrderPercentDynamic") <> Неопределено Тогда
		shareOrderPercentDynamic = Значения.Получить("shareOrderPercentDynamic");
	КонецЕсли;
	Если Значения.Получить("addToWishlistDynamic") <> Неопределено Тогда
		addToWishlistDynamic = Значения.Получить("addToWishlistDynamic");
	КонецЕсли;
	Если Значения.Получить("timeToReadyDynamic") <> Неопределено Тогда
		timeToReadyDynamic = Значения.Получить("timeToReadyDynamic");
	КонецЕсли;
	Если Значения.Получить("localizationPercentDynamic") <> Неопределено Тогда
		localizationPercentDynamic = Значения.Получить("localizationPercentDynamic");
	КонецЕсли;
	Если Значения.Получить("wbClubDynamic") <> Неопределено Тогда
		wbClubDynamic = Значения.Получить("wbClubDynamic");
	КонецЕсли;
	Если Значения.Получить("conversions") <> Неопределено Тогда
		conversions = Значения.Получить("conversions");
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
	Если openCountDynamic <> Неопределено Тогда
		Результат.Вставить("openCountDynamic", ЗначениеДляJSON(openCountDynamic));
	КонецЕсли;
	Если cartCountDynamic <> Неопределено Тогда
		Результат.Вставить("cartCountDynamic", ЗначениеДляJSON(cartCountDynamic));
	КонецЕсли;
	Если orderCountDynamic <> Неопределено Тогда
		Результат.Вставить("orderCountDynamic", ЗначениеДляJSON(orderCountDynamic));
	КонецЕсли;
	Если orderSumDynamic <> Неопределено Тогда
		Результат.Вставить("orderSumDynamic", ЗначениеДляJSON(orderSumDynamic));
	КонецЕсли;
	Если buyoutCountDynamic <> Неопределено Тогда
		Результат.Вставить("buyoutCountDynamic", ЗначениеДляJSON(buyoutCountDynamic));
	КонецЕсли;
	Если buyoutSumDynamic <> Неопределено Тогда
		Результат.Вставить("buyoutSumDynamic", ЗначениеДляJSON(buyoutSumDynamic));
	КонецЕсли;
	Если cancelCountDynamic <> Неопределено Тогда
		Результат.Вставить("cancelCountDynamic", ЗначениеДляJSON(cancelCountDynamic));
	КонецЕсли;
	Если cancelSumDynamic <> Неопределено Тогда
		Результат.Вставить("cancelSumDynamic", ЗначениеДляJSON(cancelSumDynamic));
	КонецЕсли;
	Если avgOrdersCountPerDayDynamic <> Неопределено Тогда
		Результат.Вставить("avgOrdersCountPerDayDynamic", ЗначениеДляJSON(avgOrdersCountPerDayDynamic));
	КонецЕсли;
	Если avgPriceDynamic <> Неопределено Тогда
		Результат.Вставить("avgPriceDynamic", ЗначениеДляJSON(avgPriceDynamic));
	КонецЕсли;
	Если shareOrderPercentDynamic <> Неопределено Тогда
		Результат.Вставить("shareOrderPercentDynamic", ЗначениеДляJSON(shareOrderPercentDynamic));
	КонецЕсли;
	Если addToWishlistDynamic <> Неопределено Тогда
		Результат.Вставить("addToWishlistDynamic", ЗначениеДляJSON(addToWishlistDynamic));
	КонецЕсли;
	Если timeToReadyDynamic <> Неопределено Тогда
		Результат.Вставить("timeToReadyDynamic", ЗначениеДляJSON(timeToReadyDynamic));
	КонецЕсли;
	Если localizationPercentDynamic <> Неопределено Тогда
		Результат.Вставить("localizationPercentDynamic", ЗначениеДляJSON(localizationPercentDynamic));
	КонецЕсли;
	Если wbClubDynamic <> Неопределено Тогда
		Результат.Вставить("wbClubDynamic", ЗначениеДляJSON(wbClubDynamic));
	КонецЕсли;
	Если conversions <> Неопределено Тогда
		Результат.Вставить("conversions", ЗначениеДляJSON(conversions));
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

