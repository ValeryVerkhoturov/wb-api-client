// OrdersFbwModelsSupplyDetails
//
// Класс сформирован автоматически (onescript) из спецификации OpenAPI.
// Правки будут потеряны при следующей генерации.

// phone - Строка - Телефон пользователя, создавшего поставку
Перем phone Экспорт;

// statusID - Число - ID статуса поставки: - `1` — Не запланировано - `2` — Запланировано - `3` — Отгрузка разрешена - `4` — Идёт приёмка - `5` — Принято - `6` — Отгружено на воротах
Перем statusID Экспорт;

// virtualTypeID - Число - ID типа виртуальной поставки. Отображается только для поставок с `\"boxTypeID\":0`. - `0` — Перенос остатков - `1` — Обезличка - `4` — QR-поставка - `5` — Допри…
Перем virtualTypeID Экспорт;

// boxTypeID - Число - ID типа поставки: - `0` — Без коробов (виртуальная поставка) - `1` и `2` — Короба - `5` — Монопаллеты - `6` — Суперсейф
Перем boxTypeID Экспорт;

// createDate - Строка - Дата и время создания поставки
Перем createDate Экспорт;

// supplyDate - Строка - Плановая дата отгрузки поставки
Перем supplyDate Экспорт;

// factDate - Строка - Дата фактической отгрузки поставки
Перем factDate Экспорт;

// updatedDate - Строка - Дата изменения поставки
Перем updatedDate Экспорт;

// warehouseID - Число - ID склада, на который планируется поставка
Перем warehouseID Экспорт;

// warehouseName - Строка - Название склада, на который планируется поставка
Перем warehouseName Экспорт;

// actualWarehouseID - Число - ID склада, на который поставка была привезена
Перем actualWarehouseID Экспорт;

// actualWarehouseName - Строка - Название склада, на который поставка привезена
Перем actualWarehouseName Экспорт;

// transitWarehouseID - Число - ID транзитного склада
Перем transitWarehouseID Экспорт;

// transitWarehouseName - Строка - Название транзитного склада
Перем transitWarehouseName Экспорт;

// acceptanceCost - Число - Предварительная стоимость приёмки, ₽
Перем acceptanceCost Экспорт;

// paidAcceptanceCoefficient - Число - Коэффициент приёмки
Перем paidAcceptanceCoefficient Экспорт;

// rejectReason - Строка - Причина, по которой поставка не может быть принята
Перем rejectReason Экспорт;

// supplierAssignName - Строка - Краткое название продавца
Перем supplierAssignName Экспорт;

// storageCoef - Строка - Коэффициент хранения
Перем storageCoef Экспорт;

// deliveryCoef - Строка - Коэффициент логистики
Перем deliveryCoef Экспорт;

// quantity - Число - Добавлено в поставку/заказ, шт
Перем quantity Экспорт;

// readyForSaleQuantity - Число - Поступило в продажу, шт
Перем readyForSaleQuantity Экспорт;

// acceptedQuantity - Число - Принято, шт
Перем acceptedQuantity Экспорт;

// unloadingQuantity - Число - Количество товара, находящегося на раскладке, шт
Перем unloadingQuantity Экспорт;

// depersonalizedQuantity - Число - Количество обезличенного товара, шт
Перем depersonalizedQuantity Экспорт;

// discrepancies - Число - Расхождения между заявленным и фактическим количеством товара в поставке. Только при `\"statusID\":5`
Перем discrepancies Экспорт;

// isBoxOnPallet - Булево - Тип поставки — **Поштучная палета**: - `true` — да - `false` — нет Поле возвращается только при `\"boxTypeID\": 2`
Перем isBoxOnPallet Экспорт;

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
	Если Значения.Получить("phone") <> Неопределено Тогда
		phone = Значения.Получить("phone");
	КонецЕсли;
	Если Значения.Получить("statusID") <> Неопределено Тогда
		statusID = Значения.Получить("statusID");
	КонецЕсли;
	Если Значения.Получить("virtualTypeID") <> Неопределено Тогда
		virtualTypeID = Значения.Получить("virtualTypeID");
	КонецЕсли;
	Если Значения.Получить("boxTypeID") <> Неопределено Тогда
		boxTypeID = Значения.Получить("boxTypeID");
	КонецЕсли;
	Если Значения.Получить("createDate") <> Неопределено Тогда
		createDate = Значения.Получить("createDate");
	КонецЕсли;
	Если Значения.Получить("supplyDate") <> Неопределено Тогда
		supplyDate = Значения.Получить("supplyDate");
	КонецЕсли;
	Если Значения.Получить("factDate") <> Неопределено Тогда
		factDate = Значения.Получить("factDate");
	КонецЕсли;
	Если Значения.Получить("updatedDate") <> Неопределено Тогда
		updatedDate = Значения.Получить("updatedDate");
	КонецЕсли;
	Если Значения.Получить("warehouseID") <> Неопределено Тогда
		warehouseID = Значения.Получить("warehouseID");
	КонецЕсли;
	Если Значения.Получить("warehouseName") <> Неопределено Тогда
		warehouseName = Значения.Получить("warehouseName");
	КонецЕсли;
	Если Значения.Получить("actualWarehouseID") <> Неопределено Тогда
		actualWarehouseID = Значения.Получить("actualWarehouseID");
	КонецЕсли;
	Если Значения.Получить("actualWarehouseName") <> Неопределено Тогда
		actualWarehouseName = Значения.Получить("actualWarehouseName");
	КонецЕсли;
	Если Значения.Получить("transitWarehouseID") <> Неопределено Тогда
		transitWarehouseID = Значения.Получить("transitWarehouseID");
	КонецЕсли;
	Если Значения.Получить("transitWarehouseName") <> Неопределено Тогда
		transitWarehouseName = Значения.Получить("transitWarehouseName");
	КонецЕсли;
	Если Значения.Получить("acceptanceCost") <> Неопределено Тогда
		acceptanceCost = Значения.Получить("acceptanceCost");
	КонецЕсли;
	Если Значения.Получить("paidAcceptanceCoefficient") <> Неопределено Тогда
		paidAcceptanceCoefficient = Значения.Получить("paidAcceptanceCoefficient");
	КонецЕсли;
	Если Значения.Получить("rejectReason") <> Неопределено Тогда
		rejectReason = Значения.Получить("rejectReason");
	КонецЕсли;
	Если Значения.Получить("supplierAssignName") <> Неопределено Тогда
		supplierAssignName = Значения.Получить("supplierAssignName");
	КонецЕсли;
	Если Значения.Получить("storageCoef") <> Неопределено Тогда
		storageCoef = Значения.Получить("storageCoef");
	КонецЕсли;
	Если Значения.Получить("deliveryCoef") <> Неопределено Тогда
		deliveryCoef = Значения.Получить("deliveryCoef");
	КонецЕсли;
	Если Значения.Получить("quantity") <> Неопределено Тогда
		quantity = Значения.Получить("quantity");
	КонецЕсли;
	Если Значения.Получить("readyForSaleQuantity") <> Неопределено Тогда
		readyForSaleQuantity = Значения.Получить("readyForSaleQuantity");
	КонецЕсли;
	Если Значения.Получить("acceptedQuantity") <> Неопределено Тогда
		acceptedQuantity = Значения.Получить("acceptedQuantity");
	КонецЕсли;
	Если Значения.Получить("unloadingQuantity") <> Неопределено Тогда
		unloadingQuantity = Значения.Получить("unloadingQuantity");
	КонецЕсли;
	Если Значения.Получить("depersonalizedQuantity") <> Неопределено Тогда
		depersonalizedQuantity = Значения.Получить("depersonalizedQuantity");
	КонецЕсли;
	Если Значения.Получить("discrepancies") <> Неопределено Тогда
		discrepancies = Значения.Получить("discrepancies");
	КонецЕсли;
	Если Значения.Получить("isBoxOnPallet") <> Неопределено Тогда
		isBoxOnPallet = Значения.Получить("isBoxOnPallet");
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
	Если phone <> Неопределено Тогда
		Результат.Вставить("phone", ЗначениеДляJSON(phone));
	КонецЕсли;
	Если statusID <> Неопределено Тогда
		Результат.Вставить("statusID", ЗначениеДляJSON(statusID));
	КонецЕсли;
	Если virtualTypeID <> Неопределено Тогда
		Результат.Вставить("virtualTypeID", ЗначениеДляJSON(virtualTypeID));
	КонецЕсли;
	Если boxTypeID <> Неопределено Тогда
		Результат.Вставить("boxTypeID", ЗначениеДляJSON(boxTypeID));
	КонецЕсли;
	Если createDate <> Неопределено Тогда
		Результат.Вставить("createDate", ЗначениеДляJSON(createDate));
	КонецЕсли;
	Если supplyDate <> Неопределено Тогда
		Результат.Вставить("supplyDate", ЗначениеДляJSON(supplyDate));
	КонецЕсли;
	Если factDate <> Неопределено Тогда
		Результат.Вставить("factDate", ЗначениеДляJSON(factDate));
	КонецЕсли;
	Если updatedDate <> Неопределено Тогда
		Результат.Вставить("updatedDate", ЗначениеДляJSON(updatedDate));
	КонецЕсли;
	Если warehouseID <> Неопределено Тогда
		Результат.Вставить("warehouseID", ЗначениеДляJSON(warehouseID));
	КонецЕсли;
	Если warehouseName <> Неопределено Тогда
		Результат.Вставить("warehouseName", ЗначениеДляJSON(warehouseName));
	КонецЕсли;
	Если actualWarehouseID <> Неопределено Тогда
		Результат.Вставить("actualWarehouseID", ЗначениеДляJSON(actualWarehouseID));
	КонецЕсли;
	Если actualWarehouseName <> Неопределено Тогда
		Результат.Вставить("actualWarehouseName", ЗначениеДляJSON(actualWarehouseName));
	КонецЕсли;
	Если transitWarehouseID <> Неопределено Тогда
		Результат.Вставить("transitWarehouseID", ЗначениеДляJSON(transitWarehouseID));
	КонецЕсли;
	Если transitWarehouseName <> Неопределено Тогда
		Результат.Вставить("transitWarehouseName", ЗначениеДляJSON(transitWarehouseName));
	КонецЕсли;
	Если acceptanceCost <> Неопределено Тогда
		Результат.Вставить("acceptanceCost", ЗначениеДляJSON(acceptanceCost));
	КонецЕсли;
	Если paidAcceptanceCoefficient <> Неопределено Тогда
		Результат.Вставить("paidAcceptanceCoefficient", ЗначениеДляJSON(paidAcceptanceCoefficient));
	КонецЕсли;
	Если rejectReason <> Неопределено Тогда
		Результат.Вставить("rejectReason", ЗначениеДляJSON(rejectReason));
	КонецЕсли;
	Если supplierAssignName <> Неопределено Тогда
		Результат.Вставить("supplierAssignName", ЗначениеДляJSON(supplierAssignName));
	КонецЕсли;
	Если storageCoef <> Неопределено Тогда
		Результат.Вставить("storageCoef", ЗначениеДляJSON(storageCoef));
	КонецЕсли;
	Если deliveryCoef <> Неопределено Тогда
		Результат.Вставить("deliveryCoef", ЗначениеДляJSON(deliveryCoef));
	КонецЕсли;
	Если quantity <> Неопределено Тогда
		Результат.Вставить("quantity", ЗначениеДляJSON(quantity));
	КонецЕсли;
	Если readyForSaleQuantity <> Неопределено Тогда
		Результат.Вставить("readyForSaleQuantity", ЗначениеДляJSON(readyForSaleQuantity));
	КонецЕсли;
	Если acceptedQuantity <> Неопределено Тогда
		Результат.Вставить("acceptedQuantity", ЗначениеДляJSON(acceptedQuantity));
	КонецЕсли;
	Если unloadingQuantity <> Неопределено Тогда
		Результат.Вставить("unloadingQuantity", ЗначениеДляJSON(unloadingQuantity));
	КонецЕсли;
	Если depersonalizedQuantity <> Неопределено Тогда
		Результат.Вставить("depersonalizedQuantity", ЗначениеДляJSON(depersonalizedQuantity));
	КонецЕсли;
	Если discrepancies <> Неопределено Тогда
		Результат.Вставить("discrepancies", ЗначениеДляJSON(discrepancies));
	КонецЕсли;
	Если isBoxOnPallet <> Неопределено Тогда
		Результат.Вставить("isBoxOnPallet", ЗначениеДляJSON(isBoxOnPallet));
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

