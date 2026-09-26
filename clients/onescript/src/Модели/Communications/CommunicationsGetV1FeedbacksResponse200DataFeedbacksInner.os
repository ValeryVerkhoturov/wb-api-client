// CommunicationsGetV1FeedbacksResponse200DataFeedbacksInner
//
// Класс сформирован автоматически (onescript) из спецификации OpenAPI.
// Правки будут потеряны при следующей генерации.

// id - Строка - ID отзыва
Перем id Экспорт;

// text - Строка - Текст отзыва
Перем text Экспорт;

// pros - Строка - Достоинства товара
Перем pros Экспорт;

// cons - Строка - Недостатки товара
Перем cons Экспорт;

// productValuation - Число - Оценка товара
Перем productValuation Экспорт;

// createdDate - Дата - Дата и время создания отзыва
Перем createdDate Экспорт;

// answer - GetV1FeedbacksResponse200_data_feedbacks_inner_answer
Перем answer Экспорт;

// state - Строка - Статус отзыва: - `none` - не обработан (новый) - `wbRu` - обработан
Перем state Экспорт;

// productDetails - GetV1FeedbacksResponse200_data_feedbacks_inner_productDetails
Перем productDetails Экспорт;

// photoLinks - Массив - Массив структур фотографий
Перем photoLinks Экспорт;

// video - GetV1FeedbacksResponse200_data_feedbacks_inner_video
Перем video Экспорт;

// wasViewed - Булево - Просмотрен ли отзыв
Перем wasViewed Экспорт;

// userName - Строка - Имя автора отзыва
Перем userName Экспорт;

// orderStatus - Строка - Статус заказа. Возможные значения: - `buyout` — выкуплен - `rejected` — отказались - `returned` — возврат - `notSpecified` — статус не присвоен
Перем orderStatus Экспорт;

// matchingSize - Строка - Соответствие заявленного размера реальному. Возможные значения: - ` ` — для безразмерных товаров - `ок` — соответствует размеру - `smaller` — маломерит - `bigge…
Перем matchingSize Экспорт;

// isAbleSupplierFeedbackValuation - Булево - Доступна ли продавцу возможность оставить жалобу на отзыв (`true` — доступна, `false` — не доступна)
Перем isAbleSupplierFeedbackValuation Экспорт;

// supplierFeedbackValuation - Число - Ключ причины жалобы на отзыв
Перем supplierFeedbackValuation Экспорт;

// isAbleSupplierProductValuation - Булево - Доступна ли продавцу возможность сообщить о проблеме с товаром: - `true` — да - `false` — нет
Перем isAbleSupplierProductValuation Экспорт;

// supplierProductValuation - Число - Ключ проблемы с товаром
Перем supplierProductValuation Экспорт;

// isAbleReturnProductOrders - Булево - Опция возврата товара: - `true` — доступна - `false` — недоступна
Перем isAbleReturnProductOrders Экспорт;

// returnProductOrdersDate - Строка - Дата и время, когда на запрос возврата был получен ответ со статус-кодом 200.
Перем returnProductOrdersDate Экспорт;

// bables - Массив - Список тегов покупателя
Перем bables Экспорт;

// lastOrderShkId - Число - Штрихкод единицы товара
Перем lastOrderShkId Экспорт;

// lastOrderCreatedAt - Строка - Дата покупки
Перем lastOrderCreatedAt Экспорт;

// color - Строка - Цвет товара
Перем color Экспорт;

// subjectId - Число - ID предмета
Перем subjectId Экспорт;

// subjectName - Строка - Название предмета
Перем subjectName Экспорт;

// parentFeedbackId - Строка - ID начального отзыва (`null`, если этот отзыв начальный)
Перем parentFeedbackId Экспорт;

// childFeedbackId - Строка - ID дополненного отзыва (`null`, если этот отзыв дополненный)
Перем childFeedbackId Экспорт;

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
	Если Значения.Получить("id") <> Неопределено Тогда
		id = Значения.Получить("id");
	КонецЕсли;
	Если Значения.Получить("text") <> Неопределено Тогда
		text = Значения.Получить("text");
	КонецЕсли;
	Если Значения.Получить("pros") <> Неопределено Тогда
		pros = Значения.Получить("pros");
	КонецЕсли;
	Если Значения.Получить("cons") <> Неопределено Тогда
		cons = Значения.Получить("cons");
	КонецЕсли;
	Если Значения.Получить("productValuation") <> Неопределено Тогда
		productValuation = Значения.Получить("productValuation");
	КонецЕсли;
	Если Значения.Получить("createdDate") <> Неопределено Тогда
		createdDate = Значения.Получить("createdDate");
	КонецЕсли;
	Если Значения.Получить("answer") <> Неопределено Тогда
		answer = Значения.Получить("answer");
	КонецЕсли;
	Если Значения.Получить("state") <> Неопределено Тогда
		state = Значения.Получить("state");
	КонецЕсли;
	Если Значения.Получить("productDetails") <> Неопределено Тогда
		productDetails = Значения.Получить("productDetails");
	КонецЕсли;
	Если Значения.Получить("photoLinks") <> Неопределено Тогда
		photoLinks = Значения.Получить("photoLinks");
	КонецЕсли;
	Если Значения.Получить("video") <> Неопределено Тогда
		video = Значения.Получить("video");
	КонецЕсли;
	Если Значения.Получить("wasViewed") <> Неопределено Тогда
		wasViewed = Значения.Получить("wasViewed");
	КонецЕсли;
	Если Значения.Получить("userName") <> Неопределено Тогда
		userName = Значения.Получить("userName");
	КонецЕсли;
	Если Значения.Получить("orderStatus") <> Неопределено Тогда
		orderStatus = Значения.Получить("orderStatus");
	КонецЕсли;
	Если Значения.Получить("matchingSize") <> Неопределено Тогда
		matchingSize = Значения.Получить("matchingSize");
	КонецЕсли;
	Если Значения.Получить("isAbleSupplierFeedbackValuation") <> Неопределено Тогда
		isAbleSupplierFeedbackValuation = Значения.Получить("isAbleSupplierFeedbackValuation");
	КонецЕсли;
	Если Значения.Получить("supplierFeedbackValuation") <> Неопределено Тогда
		supplierFeedbackValuation = Значения.Получить("supplierFeedbackValuation");
	КонецЕсли;
	Если Значения.Получить("isAbleSupplierProductValuation") <> Неопределено Тогда
		isAbleSupplierProductValuation = Значения.Получить("isAbleSupplierProductValuation");
	КонецЕсли;
	Если Значения.Получить("supplierProductValuation") <> Неопределено Тогда
		supplierProductValuation = Значения.Получить("supplierProductValuation");
	КонецЕсли;
	Если Значения.Получить("isAbleReturnProductOrders") <> Неопределено Тогда
		isAbleReturnProductOrders = Значения.Получить("isAbleReturnProductOrders");
	КонецЕсли;
	Если Значения.Получить("returnProductOrdersDate") <> Неопределено Тогда
		returnProductOrdersDate = Значения.Получить("returnProductOrdersDate");
	КонецЕсли;
	Если Значения.Получить("bables") <> Неопределено Тогда
		bables = Значения.Получить("bables");
	КонецЕсли;
	Если Значения.Получить("lastOrderShkId") <> Неопределено Тогда
		lastOrderShkId = Значения.Получить("lastOrderShkId");
	КонецЕсли;
	Если Значения.Получить("lastOrderCreatedAt") <> Неопределено Тогда
		lastOrderCreatedAt = Значения.Получить("lastOrderCreatedAt");
	КонецЕсли;
	Если Значения.Получить("color") <> Неопределено Тогда
		color = Значения.Получить("color");
	КонецЕсли;
	Если Значения.Получить("subjectId") <> Неопределено Тогда
		subjectId = Значения.Получить("subjectId");
	КонецЕсли;
	Если Значения.Получить("subjectName") <> Неопределено Тогда
		subjectName = Значения.Получить("subjectName");
	КонецЕсли;
	Если Значения.Получить("parentFeedbackId") <> Неопределено Тогда
		parentFeedbackId = Значения.Получить("parentFeedbackId");
	КонецЕсли;
	Если Значения.Получить("childFeedbackId") <> Неопределено Тогда
		childFeedbackId = Значения.Получить("childFeedbackId");
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
	Если id <> Неопределено Тогда
		Результат.Вставить("id", ЗначениеДляJSON(id));
	КонецЕсли;
	Если text <> Неопределено Тогда
		Результат.Вставить("text", ЗначениеДляJSON(text));
	КонецЕсли;
	Если pros <> Неопределено Тогда
		Результат.Вставить("pros", ЗначениеДляJSON(pros));
	КонецЕсли;
	Если cons <> Неопределено Тогда
		Результат.Вставить("cons", ЗначениеДляJSON(cons));
	КонецЕсли;
	Если productValuation <> Неопределено Тогда
		Результат.Вставить("productValuation", ЗначениеДляJSON(productValuation));
	КонецЕсли;
	Если createdDate <> Неопределено Тогда
		Результат.Вставить("createdDate", ЗначениеДляJSON(createdDate));
	КонецЕсли;
	Если answer <> Неопределено Тогда
		Результат.Вставить("answer", ЗначениеДляJSON(answer));
	КонецЕсли;
	Если state <> Неопределено Тогда
		Результат.Вставить("state", ЗначениеДляJSON(state));
	КонецЕсли;
	Если productDetails <> Неопределено Тогда
		Результат.Вставить("productDetails", ЗначениеДляJSON(productDetails));
	КонецЕсли;
	Если photoLinks <> Неопределено Тогда
		Результат.Вставить("photoLinks", ЗначениеДляJSON(photoLinks));
	КонецЕсли;
	Если video <> Неопределено Тогда
		Результат.Вставить("video", ЗначениеДляJSON(video));
	КонецЕсли;
	Если wasViewed <> Неопределено Тогда
		Результат.Вставить("wasViewed", ЗначениеДляJSON(wasViewed));
	КонецЕсли;
	Если userName <> Неопределено Тогда
		Результат.Вставить("userName", ЗначениеДляJSON(userName));
	КонецЕсли;
	Если orderStatus <> Неопределено Тогда
		Результат.Вставить("orderStatus", ЗначениеДляJSON(orderStatus));
	КонецЕсли;
	Если matchingSize <> Неопределено Тогда
		Результат.Вставить("matchingSize", ЗначениеДляJSON(matchingSize));
	КонецЕсли;
	Если isAbleSupplierFeedbackValuation <> Неопределено Тогда
		Результат.Вставить("isAbleSupplierFeedbackValuation", ЗначениеДляJSON(isAbleSupplierFeedbackValuation));
	КонецЕсли;
	Если supplierFeedbackValuation <> Неопределено Тогда
		Результат.Вставить("supplierFeedbackValuation", ЗначениеДляJSON(supplierFeedbackValuation));
	КонецЕсли;
	Если isAbleSupplierProductValuation <> Неопределено Тогда
		Результат.Вставить("isAbleSupplierProductValuation", ЗначениеДляJSON(isAbleSupplierProductValuation));
	КонецЕсли;
	Если supplierProductValuation <> Неопределено Тогда
		Результат.Вставить("supplierProductValuation", ЗначениеДляJSON(supplierProductValuation));
	КонецЕсли;
	Если isAbleReturnProductOrders <> Неопределено Тогда
		Результат.Вставить("isAbleReturnProductOrders", ЗначениеДляJSON(isAbleReturnProductOrders));
	КонецЕсли;
	Если returnProductOrdersDate <> Неопределено Тогда
		Результат.Вставить("returnProductOrdersDate", ЗначениеДляJSON(returnProductOrdersDate));
	КонецЕсли;
	Если bables <> Неопределено Тогда
		Результат.Вставить("bables", ЗначениеДляJSON(bables));
	КонецЕсли;
	Если lastOrderShkId <> Неопределено Тогда
		Результат.Вставить("lastOrderShkId", ЗначениеДляJSON(lastOrderShkId));
	КонецЕсли;
	Если lastOrderCreatedAt <> Неопределено Тогда
		Результат.Вставить("lastOrderCreatedAt", ЗначениеДляJSON(lastOrderCreatedAt));
	КонецЕсли;
	Если color <> Неопределено Тогда
		Результат.Вставить("color", ЗначениеДляJSON(color));
	КонецЕсли;
	Если subjectId <> Неопределено Тогда
		Результат.Вставить("subjectId", ЗначениеДляJSON(subjectId));
	КонецЕсли;
	Если subjectName <> Неопределено Тогда
		Результат.Вставить("subjectName", ЗначениеДляJSON(subjectName));
	КонецЕсли;
	Если parentFeedbackId <> Неопределено Тогда
		Результат.Вставить("parentFeedbackId", ЗначениеДляJSON(parentFeedbackId));
	КонецЕсли;
	Если childFeedbackId <> Неопределено Тогда
		Результат.Вставить("childFeedbackId", ЗначениеДляJSON(childFeedbackId));
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

