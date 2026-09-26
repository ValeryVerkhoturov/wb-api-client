// FinancesSalesReportListRes
//
// Список отчётов реализации
//
// Класс сформирован автоматически (onescript) из спецификации OpenAPI.
// Правки будут потеряны при следующей генерации.

// reportId - Число - ID отчёта
Перем reportId Экспорт;

// sellerFinanceName - Строка - Наименование продавца
Перем sellerFinanceName Экспорт;

// dateFrom - Дата - Дата начала отчётного периода
Перем dateFrom Экспорт;

// dateTo - Дата - Дата конца отчётного периода
Перем dateTo Экспорт;

// createDate - Дата - Дата формирования отчёта
Перем createDate Экспорт;

// currency - Строка - Валюта отчёта
Перем currency Экспорт;

// reportType - Число - Тип отчёта: - `1` — основной - `2` — по выкупам
Перем reportType Экспорт;

// retailAmountSum - Строка - Продажа
Перем retailAmountSum Экспорт;

// forPaySum - Строка - К перечислению за товар
Перем forPaySum Экспорт;

// avgSalePercent - Число - Согласованная скидка, %
Перем avgSalePercent Экспорт;

// deliveryServiceSum - Строка - Стоимость доставки
Перем deliveryServiceSum Экспорт;

// paidStorageSum - Строка - Стоимость хранения
Перем paidStorageSum Экспорт;

// paidAcceptanceSum - Строка - Стоимость операций при приёмке
Перем paidAcceptanceSum Экспорт;

// deductionSum - Строка - Прочие удержания/выплаты
Перем deductionSum Экспорт;

// penaltySum - Строка - Общая сумма штрафов
Перем penaltySum Экспорт;

// additionalPaymentSum - Строка - Корректировка Вознаграждения Wildberries (ВВ)
Перем additionalPaymentSum Экспорт;

// cashbackAmountSum - Строка - Сумма баллов, удержанных по программе лояльности
Перем cashbackAmountSum Экспорт;

// cashbackDiscountSum - Строка - Компенсация скидки по программе лояльности
Перем cashbackDiscountSum Экспорт;

// cashbackCommissionChangeSum - Строка - Стоимость участия в программе лояльности
Перем cashbackCommissionChangeSum Экспорт;

// paymentSchedule - Строка - Разовое изменение срока перечисления денежных средств
Перем paymentSchedule Экспорт;

// bankPaymentSum - Строка - Итого к оплате
Перем bankPaymentSum Экспорт;

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
	Если Значения.Получить("reportId") <> Неопределено Тогда
		reportId = Значения.Получить("reportId");
	КонецЕсли;
	Если Значения.Получить("sellerFinanceName") <> Неопределено Тогда
		sellerFinanceName = Значения.Получить("sellerFinanceName");
	КонецЕсли;
	Если Значения.Получить("dateFrom") <> Неопределено Тогда
		dateFrom = Значения.Получить("dateFrom");
	КонецЕсли;
	Если Значения.Получить("dateTo") <> Неопределено Тогда
		dateTo = Значения.Получить("dateTo");
	КонецЕсли;
	Если Значения.Получить("createDate") <> Неопределено Тогда
		createDate = Значения.Получить("createDate");
	КонецЕсли;
	Если Значения.Получить("currency") <> Неопределено Тогда
		currency = Значения.Получить("currency");
	КонецЕсли;
	Если Значения.Получить("reportType") <> Неопределено Тогда
		reportType = Значения.Получить("reportType");
	КонецЕсли;
	Если Значения.Получить("retailAmountSum") <> Неопределено Тогда
		retailAmountSum = Значения.Получить("retailAmountSum");
	КонецЕсли;
	Если Значения.Получить("forPaySum") <> Неопределено Тогда
		forPaySum = Значения.Получить("forPaySum");
	КонецЕсли;
	Если Значения.Получить("avgSalePercent") <> Неопределено Тогда
		avgSalePercent = Значения.Получить("avgSalePercent");
	КонецЕсли;
	Если Значения.Получить("deliveryServiceSum") <> Неопределено Тогда
		deliveryServiceSum = Значения.Получить("deliveryServiceSum");
	КонецЕсли;
	Если Значения.Получить("paidStorageSum") <> Неопределено Тогда
		paidStorageSum = Значения.Получить("paidStorageSum");
	КонецЕсли;
	Если Значения.Получить("paidAcceptanceSum") <> Неопределено Тогда
		paidAcceptanceSum = Значения.Получить("paidAcceptanceSum");
	КонецЕсли;
	Если Значения.Получить("deductionSum") <> Неопределено Тогда
		deductionSum = Значения.Получить("deductionSum");
	КонецЕсли;
	Если Значения.Получить("penaltySum") <> Неопределено Тогда
		penaltySum = Значения.Получить("penaltySum");
	КонецЕсли;
	Если Значения.Получить("additionalPaymentSum") <> Неопределено Тогда
		additionalPaymentSum = Значения.Получить("additionalPaymentSum");
	КонецЕсли;
	Если Значения.Получить("cashbackAmountSum") <> Неопределено Тогда
		cashbackAmountSum = Значения.Получить("cashbackAmountSum");
	КонецЕсли;
	Если Значения.Получить("cashbackDiscountSum") <> Неопределено Тогда
		cashbackDiscountSum = Значения.Получить("cashbackDiscountSum");
	КонецЕсли;
	Если Значения.Получить("cashbackCommissionChangeSum") <> Неопределено Тогда
		cashbackCommissionChangeSum = Значения.Получить("cashbackCommissionChangeSum");
	КонецЕсли;
	Если Значения.Получить("paymentSchedule") <> Неопределено Тогда
		paymentSchedule = Значения.Получить("paymentSchedule");
	КонецЕсли;
	Если Значения.Получить("bankPaymentSum") <> Неопределено Тогда
		bankPaymentSum = Значения.Получить("bankPaymentSum");
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
	Если reportId <> Неопределено Тогда
		Результат.Вставить("reportId", ЗначениеДляJSON(reportId));
	КонецЕсли;
	Если sellerFinanceName <> Неопределено Тогда
		Результат.Вставить("sellerFinanceName", ЗначениеДляJSON(sellerFinanceName));
	КонецЕсли;
	Если dateFrom <> Неопределено Тогда
		Результат.Вставить("dateFrom", ЗначениеДляJSON(dateFrom));
	КонецЕсли;
	Если dateTo <> Неопределено Тогда
		Результат.Вставить("dateTo", ЗначениеДляJSON(dateTo));
	КонецЕсли;
	Если createDate <> Неопределено Тогда
		Результат.Вставить("createDate", ЗначениеДляJSON(createDate));
	КонецЕсли;
	Если currency <> Неопределено Тогда
		Результат.Вставить("currency", ЗначениеДляJSON(currency));
	КонецЕсли;
	Если reportType <> Неопределено Тогда
		Результат.Вставить("reportType", ЗначениеДляJSON(reportType));
	КонецЕсли;
	Если retailAmountSum <> Неопределено Тогда
		Результат.Вставить("retailAmountSum", ЗначениеДляJSON(retailAmountSum));
	КонецЕсли;
	Если forPaySum <> Неопределено Тогда
		Результат.Вставить("forPaySum", ЗначениеДляJSON(forPaySum));
	КонецЕсли;
	Если avgSalePercent <> Неопределено Тогда
		Результат.Вставить("avgSalePercent", ЗначениеДляJSON(avgSalePercent));
	КонецЕсли;
	Если deliveryServiceSum <> Неопределено Тогда
		Результат.Вставить("deliveryServiceSum", ЗначениеДляJSON(deliveryServiceSum));
	КонецЕсли;
	Если paidStorageSum <> Неопределено Тогда
		Результат.Вставить("paidStorageSum", ЗначениеДляJSON(paidStorageSum));
	КонецЕсли;
	Если paidAcceptanceSum <> Неопределено Тогда
		Результат.Вставить("paidAcceptanceSum", ЗначениеДляJSON(paidAcceptanceSum));
	КонецЕсли;
	Если deductionSum <> Неопределено Тогда
		Результат.Вставить("deductionSum", ЗначениеДляJSON(deductionSum));
	КонецЕсли;
	Если penaltySum <> Неопределено Тогда
		Результат.Вставить("penaltySum", ЗначениеДляJSON(penaltySum));
	КонецЕсли;
	Если additionalPaymentSum <> Неопределено Тогда
		Результат.Вставить("additionalPaymentSum", ЗначениеДляJSON(additionalPaymentSum));
	КонецЕсли;
	Если cashbackAmountSum <> Неопределено Тогда
		Результат.Вставить("cashbackAmountSum", ЗначениеДляJSON(cashbackAmountSum));
	КонецЕсли;
	Если cashbackDiscountSum <> Неопределено Тогда
		Результат.Вставить("cashbackDiscountSum", ЗначениеДляJSON(cashbackDiscountSum));
	КонецЕсли;
	Если cashbackCommissionChangeSum <> Неопределено Тогда
		Результат.Вставить("cashbackCommissionChangeSum", ЗначениеДляJSON(cashbackCommissionChangeSum));
	КонецЕсли;
	Если paymentSchedule <> Неопределено Тогда
		Результат.Вставить("paymentSchedule", ЗначениеДляJSON(paymentSchedule));
	КонецЕсли;
	Если bankPaymentSum <> Неопределено Тогда
		Результат.Вставить("bankPaymentSum", ЗначениеДляJSON(bankPaymentSum));
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

