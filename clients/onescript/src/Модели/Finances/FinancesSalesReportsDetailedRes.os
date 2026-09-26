// FinancesSalesReportsDetailedRes
//
// Детализации к отчётам реализации
//
// Класс сформирован автоматически (onescript) из спецификации OpenAPI.
// Правки будут потеряны при следующей генерации.

// reportId - Число - ID отчёта
Перем reportId Экспорт;

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

// rrdId - Число - ID строки
Перем rrdId Экспорт;

// giId - Число - ID поставки
Перем giId Экспорт;

// dlvPrc - Число - Фиксированный коэффициент склада по поставке
Перем dlvPrc Экспорт;

// fixTariffDateFrom - Дата - Дата начала действия фиксации
Перем fixTariffDateFrom Экспорт;

// fixTariffDateTo - Дата - Дата конца действия фиксации
Перем fixTariffDateTo Экспорт;

// subjectName - Строка - Предмет
Перем subjectName Экспорт;

// nmId - Число - Артикул WB
Перем nmId Экспорт;

// brandName - Строка - Бренд
Перем brandName Экспорт;

// vendorCode - Строка - Артикул продавца
Перем vendorCode Экспорт;

// title - Строка - Название товара
Перем title Экспорт;

// techSize - Строка - Размер
Перем techSize Экспорт;

// sku - Строка - Баркод
Перем sku Экспорт;

// docTypeName - Строка - Тип документа
Перем docTypeName Экспорт;

// quantity - Число - Количество
Перем quantity Экспорт;

// retailPrice - Строка - Цена розничная
Перем retailPrice Экспорт;

// retailAmount - Строка - Wildberries реализовал Товар (Пр)
Перем retailAmount Экспорт;

// salePercent - Число - Согласованный продуктовый дисконт, %
Перем salePercent Экспорт;

// commissionPercent - Число - Размер кВВ, %
Перем commissionPercent Экспорт;

// officeName - Строка - Склад
Перем officeName Экспорт;

// sellerOperName - Строка - Обоснование для оплаты
Перем sellerOperName Экспорт;

// orderDt - Дата - Дата и время заказа
Перем orderDt Экспорт;

// saleDt - Дата - Дата и время продажи
Перем saleDt Экспорт;

// rrDate - Дата - Дата операции
Перем rrDate Экспорт;

// shkId - Число - Штрихкод
Перем shkId Экспорт;

// retailPriceWithDisc - Строка - Цена розничная с учётом согласованной скидки
Перем retailPriceWithDisc Экспорт;

// deliveryAmount - Число - Количество доставок
Перем deliveryAmount Экспорт;

// returnAmount - Число - Количество возврата
Перем returnAmount Экспорт;

// deliveryService - Строка - Услуги по доставке товара покупателю
Перем deliveryService Экспорт;

// giBoxTypeName - Строка - Тип коробов
Перем giBoxTypeName Экспорт;

// productDiscountForReport - Число - Итоговая согласованная скидка, %
Перем productDiscountForReport Экспорт;

// sellerPromo - Число - Промокод, %
Перем sellerPromo Экспорт;

// spp - Число - Платформенные скидки, %
Перем spp Экспорт;

// kvwBase - Число - Размер кВВ без НДС, % базовый
Перем kvwBase Экспорт;

// kvw - Число - Итоговый кВВ без НДС, %
Перем kvw Экспорт;

// supRatingUp - Число - Размер снижения кВВ из-за рейтинга, %
Перем supRatingUp Экспорт;

// isKgvpV2 - Число - Размер снижения кВВ из-за акции, %
Перем isKgvpV2 Экспорт;

// ppvzSalesCommission - Строка - Вознаграждение с продаж до вычета услуг поверенного, без НДС
Перем ppvzSalesCommission Экспорт;

// forPay - Строка - К перечислению продавцу за реализованный товар
Перем forPay Экспорт;

// ppvzReward - Строка - Возмещение за выдачу и возврат товаров на ПВЗ
Перем ppvzReward Экспорт;

// acquiringFee - Строка - Компенсация платёжных услуг/комиссия за интеграцию платёжных сервисов
Перем acquiringFee Экспорт;

// acquiringPercent - Число - Размер компенсации платёжных услуг/комиссии за интеграцию платёжных сервисов
Перем acquiringPercent Экспорт;

// paymentProcessing - Строка - Тип платежа: компенсация платёжных услуг/комиссия за интеграцию платёжных сервисов
Перем paymentProcessing Экспорт;

// acquiringBank - Строка - Наименование банка-эквайера
Перем acquiringBank Экспорт;

// vw - Строка - Вознаграждение Wildberries (ВВ), без НДС
Перем vw Экспорт;

// vwNds - Строка - НДС с вознаграждения Wildberries
Перем vwNds Экспорт;

// ppvzOfficeName - Строка - Наименование офиса доставки
Перем ppvzOfficeName Экспорт;

// ppvzOfficeId - Число - ID офиса доставки
Перем ppvzOfficeId Экспорт;

// ppvzSupplierName - Строка - Партнёр
Перем ppvzSupplierName Экспорт;

// ppvzSupplierInn - Строка - ИНН партнёра
Перем ppvzSupplierInn Экспорт;

// declarationNumber - Строка - Номер таможенной декларации
Перем declarationNumber Экспорт;

// bonusTypeName - Строка - Виды доставок, штрафов и корректировок ВВ
Перем bonusTypeName Экспорт;

// stickerId - Строка - Стикер МП
Перем stickerId Экспорт;

// country - Строка - Страна продажи
Перем country Экспорт;

// srvDbs - Булево - Признак услуги платной доставки
Перем srvDbs Экспорт;

// penalty - Строка - Общая сумма штрафов
Перем penalty Экспорт;

// additionalPayment - Строка - Корректировка Вознаграждения Wildberries (ВВ)
Перем additionalPayment Экспорт;

// rebillLogisticCost - Строка - Возмещение издержек по перемещению и операционной обработке товара
Перем rebillLogisticCost Экспорт;

// rebillLogisticOrg - Строка - Организатор перевозки
Перем rebillLogisticOrg Экспорт;

// paidStorage - Строка - Хранение
Перем paidStorage Экспорт;

// deduction - Строка - Удержания
Перем deduction Экспорт;

// paidAcceptance - Строка - Операции на приёмке
Перем paidAcceptance Экспорт;

// orderId - Число - ID сборочного задания
Перем orderId Экспорт;

// kiz - Строка - Код маркировки [Честного знака](https://честныйзнак.рф)
Перем kiz Экспорт;

// isB2b - Булево - Признак B2B-продажи
Перем isB2b Экспорт;

// trbxId - Строка - ID короба для обработки товара
Перем trbxId Экспорт;

// installmentCofinancingAmount - Строка - Скидка по программе софинансирования
Перем installmentCofinancingAmount Экспорт;

// wibesDiscountPercent - Число - Скидка Wibes, %
Перем wibesDiscountPercent Экспорт;

// cashbackAmount - Строка - Сумма баллов, удержанных по программе лояльности
Перем cashbackAmount Экспорт;

// cashbackDiscount - Строка - Компенсация скидки по программе лояльности
Перем cashbackDiscount Экспорт;

// cashbackCommissionChange - Строка - Стоимость участия в программе лояльности
Перем cashbackCommissionChange Экспорт;

// paymentSchedule - Строка - Разовое изменение срока перечисления денежных средств
Перем paymentSchedule Экспорт;

// deliveryMethod - Строка - Способ продажи и тип товара
Перем deliveryMethod Экспорт;

// sellerPromoId - Число - ID собственной акции продавца с дополнительной скидкой
Перем sellerPromoId Экспорт;

// sellerPromoDiscount - Число - Размер дополнительной скидки по собственной акции продавца, %
Перем sellerPromoDiscount Экспорт;

// loyaltyId - Число - ID скидки лояльности от продавца
Перем loyaltyId Экспорт;

// loyaltyDiscount - Число - Размер скидки лояльности от продавца, %
Перем loyaltyDiscount Экспорт;

// uuidPromocode - Строка - ID промокода
Перем uuidPromocode Экспорт;

// salePricePromocodeDiscountPrc - Число - Скидка за промокод, %
Перем salePricePromocodeDiscountPrc Экспорт;

// articleSubstitution - Строка - ID подменного артикула
Перем articleSubstitution Экспорт;

// salePriceAffiliatedDiscountPrc - Число - Скидка по подменному артикулу, %
Перем salePriceAffiliatedDiscountPrc Экспорт;

// agencyVat - Число - Удержание Агентского НДС, %. Только для продавцов из Кыргызстана
Перем agencyVat Экспорт;

// salePriceWholesaleDiscountPrc - Число - Оптовая скидка для бизнеса, %
Перем salePriceWholesaleDiscountPrc Экспорт;

// b2bCustomerTin - Строка - ИНН B2B-покупателя
Перем b2bCustomerTin Экспорт;

// paidWithSocialCertificate - Булево - Оплата социальным сертификатом
Перем paidWithSocialCertificate Экспорт;

// warehouseLogisticsCoeff - Число - Коэффициент доставки
Перем warehouseLogisticsCoeff Экспорт;

// orderUid - Строка - ID корзины заказа — транзакции. Заказы в одной корзине покупателя будут иметь одинаковый `orderUid`
Перем orderUid Экспорт;

// srid - Строка - ID заказа. В ответах методов сборочных заданий [FBS](./orders-fbs#tag/fbsAssemblyOrders), [DBW](./orders-dbw#tag/dbwAssemblyOrders), [DBS](./dbs#tag/dbsAssembly…
Перем srid Экспорт;

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
	Если Значения.Получить("rrdId") <> Неопределено Тогда
		rrdId = Значения.Получить("rrdId");
	КонецЕсли;
	Если Значения.Получить("giId") <> Неопределено Тогда
		giId = Значения.Получить("giId");
	КонецЕсли;
	Если Значения.Получить("dlvPrc") <> Неопределено Тогда
		dlvPrc = Значения.Получить("dlvPrc");
	КонецЕсли;
	Если Значения.Получить("fixTariffDateFrom") <> Неопределено Тогда
		fixTariffDateFrom = Значения.Получить("fixTariffDateFrom");
	КонецЕсли;
	Если Значения.Получить("fixTariffDateTo") <> Неопределено Тогда
		fixTariffDateTo = Значения.Получить("fixTariffDateTo");
	КонецЕсли;
	Если Значения.Получить("subjectName") <> Неопределено Тогда
		subjectName = Значения.Получить("subjectName");
	КонецЕсли;
	Если Значения.Получить("nmId") <> Неопределено Тогда
		nmId = Значения.Получить("nmId");
	КонецЕсли;
	Если Значения.Получить("brandName") <> Неопределено Тогда
		brandName = Значения.Получить("brandName");
	КонецЕсли;
	Если Значения.Получить("vendorCode") <> Неопределено Тогда
		vendorCode = Значения.Получить("vendorCode");
	КонецЕсли;
	Если Значения.Получить("title") <> Неопределено Тогда
		title = Значения.Получить("title");
	КонецЕсли;
	Если Значения.Получить("techSize") <> Неопределено Тогда
		techSize = Значения.Получить("techSize");
	КонецЕсли;
	Если Значения.Получить("sku") <> Неопределено Тогда
		sku = Значения.Получить("sku");
	КонецЕсли;
	Если Значения.Получить("docTypeName") <> Неопределено Тогда
		docTypeName = Значения.Получить("docTypeName");
	КонецЕсли;
	Если Значения.Получить("quantity") <> Неопределено Тогда
		quantity = Значения.Получить("quantity");
	КонецЕсли;
	Если Значения.Получить("retailPrice") <> Неопределено Тогда
		retailPrice = Значения.Получить("retailPrice");
	КонецЕсли;
	Если Значения.Получить("retailAmount") <> Неопределено Тогда
		retailAmount = Значения.Получить("retailAmount");
	КонецЕсли;
	Если Значения.Получить("salePercent") <> Неопределено Тогда
		salePercent = Значения.Получить("salePercent");
	КонецЕсли;
	Если Значения.Получить("commissionPercent") <> Неопределено Тогда
		commissionPercent = Значения.Получить("commissionPercent");
	КонецЕсли;
	Если Значения.Получить("officeName") <> Неопределено Тогда
		officeName = Значения.Получить("officeName");
	КонецЕсли;
	Если Значения.Получить("sellerOperName") <> Неопределено Тогда
		sellerOperName = Значения.Получить("sellerOperName");
	КонецЕсли;
	Если Значения.Получить("orderDt") <> Неопределено Тогда
		orderDt = Значения.Получить("orderDt");
	КонецЕсли;
	Если Значения.Получить("saleDt") <> Неопределено Тогда
		saleDt = Значения.Получить("saleDt");
	КонецЕсли;
	Если Значения.Получить("rrDate") <> Неопределено Тогда
		rrDate = Значения.Получить("rrDate");
	КонецЕсли;
	Если Значения.Получить("shkId") <> Неопределено Тогда
		shkId = Значения.Получить("shkId");
	КонецЕсли;
	Если Значения.Получить("retailPriceWithDisc") <> Неопределено Тогда
		retailPriceWithDisc = Значения.Получить("retailPriceWithDisc");
	КонецЕсли;
	Если Значения.Получить("deliveryAmount") <> Неопределено Тогда
		deliveryAmount = Значения.Получить("deliveryAmount");
	КонецЕсли;
	Если Значения.Получить("returnAmount") <> Неопределено Тогда
		returnAmount = Значения.Получить("returnAmount");
	КонецЕсли;
	Если Значения.Получить("deliveryService") <> Неопределено Тогда
		deliveryService = Значения.Получить("deliveryService");
	КонецЕсли;
	Если Значения.Получить("giBoxTypeName") <> Неопределено Тогда
		giBoxTypeName = Значения.Получить("giBoxTypeName");
	КонецЕсли;
	Если Значения.Получить("productDiscountForReport") <> Неопределено Тогда
		productDiscountForReport = Значения.Получить("productDiscountForReport");
	КонецЕсли;
	Если Значения.Получить("sellerPromo") <> Неопределено Тогда
		sellerPromo = Значения.Получить("sellerPromo");
	КонецЕсли;
	Если Значения.Получить("spp") <> Неопределено Тогда
		spp = Значения.Получить("spp");
	КонецЕсли;
	Если Значения.Получить("kvwBase") <> Неопределено Тогда
		kvwBase = Значения.Получить("kvwBase");
	КонецЕсли;
	Если Значения.Получить("kvw") <> Неопределено Тогда
		kvw = Значения.Получить("kvw");
	КонецЕсли;
	Если Значения.Получить("supRatingUp") <> Неопределено Тогда
		supRatingUp = Значения.Получить("supRatingUp");
	КонецЕсли;
	Если Значения.Получить("isKgvpV2") <> Неопределено Тогда
		isKgvpV2 = Значения.Получить("isKgvpV2");
	КонецЕсли;
	Если Значения.Получить("ppvzSalesCommission") <> Неопределено Тогда
		ppvzSalesCommission = Значения.Получить("ppvzSalesCommission");
	КонецЕсли;
	Если Значения.Получить("forPay") <> Неопределено Тогда
		forPay = Значения.Получить("forPay");
	КонецЕсли;
	Если Значения.Получить("ppvzReward") <> Неопределено Тогда
		ppvzReward = Значения.Получить("ppvzReward");
	КонецЕсли;
	Если Значения.Получить("acquiringFee") <> Неопределено Тогда
		acquiringFee = Значения.Получить("acquiringFee");
	КонецЕсли;
	Если Значения.Получить("acquiringPercent") <> Неопределено Тогда
		acquiringPercent = Значения.Получить("acquiringPercent");
	КонецЕсли;
	Если Значения.Получить("paymentProcessing") <> Неопределено Тогда
		paymentProcessing = Значения.Получить("paymentProcessing");
	КонецЕсли;
	Если Значения.Получить("acquiringBank") <> Неопределено Тогда
		acquiringBank = Значения.Получить("acquiringBank");
	КонецЕсли;
	Если Значения.Получить("vw") <> Неопределено Тогда
		vw = Значения.Получить("vw");
	КонецЕсли;
	Если Значения.Получить("vwNds") <> Неопределено Тогда
		vwNds = Значения.Получить("vwNds");
	КонецЕсли;
	Если Значения.Получить("ppvzOfficeName") <> Неопределено Тогда
		ppvzOfficeName = Значения.Получить("ppvzOfficeName");
	КонецЕсли;
	Если Значения.Получить("ppvzOfficeId") <> Неопределено Тогда
		ppvzOfficeId = Значения.Получить("ppvzOfficeId");
	КонецЕсли;
	Если Значения.Получить("ppvzSupplierName") <> Неопределено Тогда
		ppvzSupplierName = Значения.Получить("ppvzSupplierName");
	КонецЕсли;
	Если Значения.Получить("ppvzSupplierInn") <> Неопределено Тогда
		ppvzSupplierInn = Значения.Получить("ppvzSupplierInn");
	КонецЕсли;
	Если Значения.Получить("declarationNumber") <> Неопределено Тогда
		declarationNumber = Значения.Получить("declarationNumber");
	КонецЕсли;
	Если Значения.Получить("bonusTypeName") <> Неопределено Тогда
		bonusTypeName = Значения.Получить("bonusTypeName");
	КонецЕсли;
	Если Значения.Получить("stickerId") <> Неопределено Тогда
		stickerId = Значения.Получить("stickerId");
	КонецЕсли;
	Если Значения.Получить("country") <> Неопределено Тогда
		country = Значения.Получить("country");
	КонецЕсли;
	Если Значения.Получить("srvDbs") <> Неопределено Тогда
		srvDbs = Значения.Получить("srvDbs");
	КонецЕсли;
	Если Значения.Получить("penalty") <> Неопределено Тогда
		penalty = Значения.Получить("penalty");
	КонецЕсли;
	Если Значения.Получить("additionalPayment") <> Неопределено Тогда
		additionalPayment = Значения.Получить("additionalPayment");
	КонецЕсли;
	Если Значения.Получить("rebillLogisticCost") <> Неопределено Тогда
		rebillLogisticCost = Значения.Получить("rebillLogisticCost");
	КонецЕсли;
	Если Значения.Получить("rebillLogisticOrg") <> Неопределено Тогда
		rebillLogisticOrg = Значения.Получить("rebillLogisticOrg");
	КонецЕсли;
	Если Значения.Получить("paidStorage") <> Неопределено Тогда
		paidStorage = Значения.Получить("paidStorage");
	КонецЕсли;
	Если Значения.Получить("deduction") <> Неопределено Тогда
		deduction = Значения.Получить("deduction");
	КонецЕсли;
	Если Значения.Получить("paidAcceptance") <> Неопределено Тогда
		paidAcceptance = Значения.Получить("paidAcceptance");
	КонецЕсли;
	Если Значения.Получить("orderId") <> Неопределено Тогда
		orderId = Значения.Получить("orderId");
	КонецЕсли;
	Если Значения.Получить("kiz") <> Неопределено Тогда
		kiz = Значения.Получить("kiz");
	КонецЕсли;
	Если Значения.Получить("isB2b") <> Неопределено Тогда
		isB2b = Значения.Получить("isB2b");
	КонецЕсли;
	Если Значения.Получить("trbxId") <> Неопределено Тогда
		trbxId = Значения.Получить("trbxId");
	КонецЕсли;
	Если Значения.Получить("installmentCofinancingAmount") <> Неопределено Тогда
		installmentCofinancingAmount = Значения.Получить("installmentCofinancingAmount");
	КонецЕсли;
	Если Значения.Получить("wibesDiscountPercent") <> Неопределено Тогда
		wibesDiscountPercent = Значения.Получить("wibesDiscountPercent");
	КонецЕсли;
	Если Значения.Получить("cashbackAmount") <> Неопределено Тогда
		cashbackAmount = Значения.Получить("cashbackAmount");
	КонецЕсли;
	Если Значения.Получить("cashbackDiscount") <> Неопределено Тогда
		cashbackDiscount = Значения.Получить("cashbackDiscount");
	КонецЕсли;
	Если Значения.Получить("cashbackCommissionChange") <> Неопределено Тогда
		cashbackCommissionChange = Значения.Получить("cashbackCommissionChange");
	КонецЕсли;
	Если Значения.Получить("paymentSchedule") <> Неопределено Тогда
		paymentSchedule = Значения.Получить("paymentSchedule");
	КонецЕсли;
	Если Значения.Получить("deliveryMethod") <> Неопределено Тогда
		deliveryMethod = Значения.Получить("deliveryMethod");
	КонецЕсли;
	Если Значения.Получить("sellerPromoId") <> Неопределено Тогда
		sellerPromoId = Значения.Получить("sellerPromoId");
	КонецЕсли;
	Если Значения.Получить("sellerPromoDiscount") <> Неопределено Тогда
		sellerPromoDiscount = Значения.Получить("sellerPromoDiscount");
	КонецЕсли;
	Если Значения.Получить("loyaltyId") <> Неопределено Тогда
		loyaltyId = Значения.Получить("loyaltyId");
	КонецЕсли;
	Если Значения.Получить("loyaltyDiscount") <> Неопределено Тогда
		loyaltyDiscount = Значения.Получить("loyaltyDiscount");
	КонецЕсли;
	Если Значения.Получить("uuidPromocode") <> Неопределено Тогда
		uuidPromocode = Значения.Получить("uuidPromocode");
	КонецЕсли;
	Если Значения.Получить("salePricePromocodeDiscountPrc") <> Неопределено Тогда
		salePricePromocodeDiscountPrc = Значения.Получить("salePricePromocodeDiscountPrc");
	КонецЕсли;
	Если Значения.Получить("articleSubstitution") <> Неопределено Тогда
		articleSubstitution = Значения.Получить("articleSubstitution");
	КонецЕсли;
	Если Значения.Получить("salePriceAffiliatedDiscountPrc") <> Неопределено Тогда
		salePriceAffiliatedDiscountPrc = Значения.Получить("salePriceAffiliatedDiscountPrc");
	КонецЕсли;
	Если Значения.Получить("agencyVat") <> Неопределено Тогда
		agencyVat = Значения.Получить("agencyVat");
	КонецЕсли;
	Если Значения.Получить("salePriceWholesaleDiscountPrc") <> Неопределено Тогда
		salePriceWholesaleDiscountPrc = Значения.Получить("salePriceWholesaleDiscountPrc");
	КонецЕсли;
	Если Значения.Получить("b2bCustomerTin") <> Неопределено Тогда
		b2bCustomerTin = Значения.Получить("b2bCustomerTin");
	КонецЕсли;
	Если Значения.Получить("paidWithSocialCertificate") <> Неопределено Тогда
		paidWithSocialCertificate = Значения.Получить("paidWithSocialCertificate");
	КонецЕсли;
	Если Значения.Получить("warehouseLogisticsCoeff") <> Неопределено Тогда
		warehouseLogisticsCoeff = Значения.Получить("warehouseLogisticsCoeff");
	КонецЕсли;
	Если Значения.Получить("orderUid") <> Неопределено Тогда
		orderUid = Значения.Получить("orderUid");
	КонецЕсли;
	Если Значения.Получить("srid") <> Неопределено Тогда
		srid = Значения.Получить("srid");
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
	Если rrdId <> Неопределено Тогда
		Результат.Вставить("rrdId", ЗначениеДляJSON(rrdId));
	КонецЕсли;
	Если giId <> Неопределено Тогда
		Результат.Вставить("giId", ЗначениеДляJSON(giId));
	КонецЕсли;
	Если dlvPrc <> Неопределено Тогда
		Результат.Вставить("dlvPrc", ЗначениеДляJSON(dlvPrc));
	КонецЕсли;
	Если fixTariffDateFrom <> Неопределено Тогда
		Результат.Вставить("fixTariffDateFrom", ЗначениеДляJSON(fixTariffDateFrom));
	КонецЕсли;
	Если fixTariffDateTo <> Неопределено Тогда
		Результат.Вставить("fixTariffDateTo", ЗначениеДляJSON(fixTariffDateTo));
	КонецЕсли;
	Если subjectName <> Неопределено Тогда
		Результат.Вставить("subjectName", ЗначениеДляJSON(subjectName));
	КонецЕсли;
	Если nmId <> Неопределено Тогда
		Результат.Вставить("nmId", ЗначениеДляJSON(nmId));
	КонецЕсли;
	Если brandName <> Неопределено Тогда
		Результат.Вставить("brandName", ЗначениеДляJSON(brandName));
	КонецЕсли;
	Если vendorCode <> Неопределено Тогда
		Результат.Вставить("vendorCode", ЗначениеДляJSON(vendorCode));
	КонецЕсли;
	Если title <> Неопределено Тогда
		Результат.Вставить("title", ЗначениеДляJSON(title));
	КонецЕсли;
	Если techSize <> Неопределено Тогда
		Результат.Вставить("techSize", ЗначениеДляJSON(techSize));
	КонецЕсли;
	Если sku <> Неопределено Тогда
		Результат.Вставить("sku", ЗначениеДляJSON(sku));
	КонецЕсли;
	Если docTypeName <> Неопределено Тогда
		Результат.Вставить("docTypeName", ЗначениеДляJSON(docTypeName));
	КонецЕсли;
	Если quantity <> Неопределено Тогда
		Результат.Вставить("quantity", ЗначениеДляJSON(quantity));
	КонецЕсли;
	Если retailPrice <> Неопределено Тогда
		Результат.Вставить("retailPrice", ЗначениеДляJSON(retailPrice));
	КонецЕсли;
	Если retailAmount <> Неопределено Тогда
		Результат.Вставить("retailAmount", ЗначениеДляJSON(retailAmount));
	КонецЕсли;
	Если salePercent <> Неопределено Тогда
		Результат.Вставить("salePercent", ЗначениеДляJSON(salePercent));
	КонецЕсли;
	Если commissionPercent <> Неопределено Тогда
		Результат.Вставить("commissionPercent", ЗначениеДляJSON(commissionPercent));
	КонецЕсли;
	Если officeName <> Неопределено Тогда
		Результат.Вставить("officeName", ЗначениеДляJSON(officeName));
	КонецЕсли;
	Если sellerOperName <> Неопределено Тогда
		Результат.Вставить("sellerOperName", ЗначениеДляJSON(sellerOperName));
	КонецЕсли;
	Если orderDt <> Неопределено Тогда
		Результат.Вставить("orderDt", ЗначениеДляJSON(orderDt));
	КонецЕсли;
	Если saleDt <> Неопределено Тогда
		Результат.Вставить("saleDt", ЗначениеДляJSON(saleDt));
	КонецЕсли;
	Если rrDate <> Неопределено Тогда
		Результат.Вставить("rrDate", ЗначениеДляJSON(rrDate));
	КонецЕсли;
	Если shkId <> Неопределено Тогда
		Результат.Вставить("shkId", ЗначениеДляJSON(shkId));
	КонецЕсли;
	Если retailPriceWithDisc <> Неопределено Тогда
		Результат.Вставить("retailPriceWithDisc", ЗначениеДляJSON(retailPriceWithDisc));
	КонецЕсли;
	Если deliveryAmount <> Неопределено Тогда
		Результат.Вставить("deliveryAmount", ЗначениеДляJSON(deliveryAmount));
	КонецЕсли;
	Если returnAmount <> Неопределено Тогда
		Результат.Вставить("returnAmount", ЗначениеДляJSON(returnAmount));
	КонецЕсли;
	Если deliveryService <> Неопределено Тогда
		Результат.Вставить("deliveryService", ЗначениеДляJSON(deliveryService));
	КонецЕсли;
	Если giBoxTypeName <> Неопределено Тогда
		Результат.Вставить("giBoxTypeName", ЗначениеДляJSON(giBoxTypeName));
	КонецЕсли;
	Если productDiscountForReport <> Неопределено Тогда
		Результат.Вставить("productDiscountForReport", ЗначениеДляJSON(productDiscountForReport));
	КонецЕсли;
	Если sellerPromo <> Неопределено Тогда
		Результат.Вставить("sellerPromo", ЗначениеДляJSON(sellerPromo));
	КонецЕсли;
	Если spp <> Неопределено Тогда
		Результат.Вставить("spp", ЗначениеДляJSON(spp));
	КонецЕсли;
	Если kvwBase <> Неопределено Тогда
		Результат.Вставить("kvwBase", ЗначениеДляJSON(kvwBase));
	КонецЕсли;
	Если kvw <> Неопределено Тогда
		Результат.Вставить("kvw", ЗначениеДляJSON(kvw));
	КонецЕсли;
	Если supRatingUp <> Неопределено Тогда
		Результат.Вставить("supRatingUp", ЗначениеДляJSON(supRatingUp));
	КонецЕсли;
	Если isKgvpV2 <> Неопределено Тогда
		Результат.Вставить("isKgvpV2", ЗначениеДляJSON(isKgvpV2));
	КонецЕсли;
	Если ppvzSalesCommission <> Неопределено Тогда
		Результат.Вставить("ppvzSalesCommission", ЗначениеДляJSON(ppvzSalesCommission));
	КонецЕсли;
	Если forPay <> Неопределено Тогда
		Результат.Вставить("forPay", ЗначениеДляJSON(forPay));
	КонецЕсли;
	Если ppvzReward <> Неопределено Тогда
		Результат.Вставить("ppvzReward", ЗначениеДляJSON(ppvzReward));
	КонецЕсли;
	Если acquiringFee <> Неопределено Тогда
		Результат.Вставить("acquiringFee", ЗначениеДляJSON(acquiringFee));
	КонецЕсли;
	Если acquiringPercent <> Неопределено Тогда
		Результат.Вставить("acquiringPercent", ЗначениеДляJSON(acquiringPercent));
	КонецЕсли;
	Если paymentProcessing <> Неопределено Тогда
		Результат.Вставить("paymentProcessing", ЗначениеДляJSON(paymentProcessing));
	КонецЕсли;
	Если acquiringBank <> Неопределено Тогда
		Результат.Вставить("acquiringBank", ЗначениеДляJSON(acquiringBank));
	КонецЕсли;
	Если vw <> Неопределено Тогда
		Результат.Вставить("vw", ЗначениеДляJSON(vw));
	КонецЕсли;
	Если vwNds <> Неопределено Тогда
		Результат.Вставить("vwNds", ЗначениеДляJSON(vwNds));
	КонецЕсли;
	Если ppvzOfficeName <> Неопределено Тогда
		Результат.Вставить("ppvzOfficeName", ЗначениеДляJSON(ppvzOfficeName));
	КонецЕсли;
	Если ppvzOfficeId <> Неопределено Тогда
		Результат.Вставить("ppvzOfficeId", ЗначениеДляJSON(ppvzOfficeId));
	КонецЕсли;
	Если ppvzSupplierName <> Неопределено Тогда
		Результат.Вставить("ppvzSupplierName", ЗначениеДляJSON(ppvzSupplierName));
	КонецЕсли;
	Если ppvzSupplierInn <> Неопределено Тогда
		Результат.Вставить("ppvzSupplierInn", ЗначениеДляJSON(ppvzSupplierInn));
	КонецЕсли;
	Если declarationNumber <> Неопределено Тогда
		Результат.Вставить("declarationNumber", ЗначениеДляJSON(declarationNumber));
	КонецЕсли;
	Если bonusTypeName <> Неопределено Тогда
		Результат.Вставить("bonusTypeName", ЗначениеДляJSON(bonusTypeName));
	КонецЕсли;
	Если stickerId <> Неопределено Тогда
		Результат.Вставить("stickerId", ЗначениеДляJSON(stickerId));
	КонецЕсли;
	Если country <> Неопределено Тогда
		Результат.Вставить("country", ЗначениеДляJSON(country));
	КонецЕсли;
	Если srvDbs <> Неопределено Тогда
		Результат.Вставить("srvDbs", ЗначениеДляJSON(srvDbs));
	КонецЕсли;
	Если penalty <> Неопределено Тогда
		Результат.Вставить("penalty", ЗначениеДляJSON(penalty));
	КонецЕсли;
	Если additionalPayment <> Неопределено Тогда
		Результат.Вставить("additionalPayment", ЗначениеДляJSON(additionalPayment));
	КонецЕсли;
	Если rebillLogisticCost <> Неопределено Тогда
		Результат.Вставить("rebillLogisticCost", ЗначениеДляJSON(rebillLogisticCost));
	КонецЕсли;
	Если rebillLogisticOrg <> Неопределено Тогда
		Результат.Вставить("rebillLogisticOrg", ЗначениеДляJSON(rebillLogisticOrg));
	КонецЕсли;
	Если paidStorage <> Неопределено Тогда
		Результат.Вставить("paidStorage", ЗначениеДляJSON(paidStorage));
	КонецЕсли;
	Если deduction <> Неопределено Тогда
		Результат.Вставить("deduction", ЗначениеДляJSON(deduction));
	КонецЕсли;
	Если paidAcceptance <> Неопределено Тогда
		Результат.Вставить("paidAcceptance", ЗначениеДляJSON(paidAcceptance));
	КонецЕсли;
	Если orderId <> Неопределено Тогда
		Результат.Вставить("orderId", ЗначениеДляJSON(orderId));
	КонецЕсли;
	Если kiz <> Неопределено Тогда
		Результат.Вставить("kiz", ЗначениеДляJSON(kiz));
	КонецЕсли;
	Если isB2b <> Неопределено Тогда
		Результат.Вставить("isB2b", ЗначениеДляJSON(isB2b));
	КонецЕсли;
	Если trbxId <> Неопределено Тогда
		Результат.Вставить("trbxId", ЗначениеДляJSON(trbxId));
	КонецЕсли;
	Если installmentCofinancingAmount <> Неопределено Тогда
		Результат.Вставить("installmentCofinancingAmount", ЗначениеДляJSON(installmentCofinancingAmount));
	КонецЕсли;
	Если wibesDiscountPercent <> Неопределено Тогда
		Результат.Вставить("wibesDiscountPercent", ЗначениеДляJSON(wibesDiscountPercent));
	КонецЕсли;
	Если cashbackAmount <> Неопределено Тогда
		Результат.Вставить("cashbackAmount", ЗначениеДляJSON(cashbackAmount));
	КонецЕсли;
	Если cashbackDiscount <> Неопределено Тогда
		Результат.Вставить("cashbackDiscount", ЗначениеДляJSON(cashbackDiscount));
	КонецЕсли;
	Если cashbackCommissionChange <> Неопределено Тогда
		Результат.Вставить("cashbackCommissionChange", ЗначениеДляJSON(cashbackCommissionChange));
	КонецЕсли;
	Если paymentSchedule <> Неопределено Тогда
		Результат.Вставить("paymentSchedule", ЗначениеДляJSON(paymentSchedule));
	КонецЕсли;
	Если deliveryMethod <> Неопределено Тогда
		Результат.Вставить("deliveryMethod", ЗначениеДляJSON(deliveryMethod));
	КонецЕсли;
	Если sellerPromoId <> Неопределено Тогда
		Результат.Вставить("sellerPromoId", ЗначениеДляJSON(sellerPromoId));
	КонецЕсли;
	Если sellerPromoDiscount <> Неопределено Тогда
		Результат.Вставить("sellerPromoDiscount", ЗначениеДляJSON(sellerPromoDiscount));
	КонецЕсли;
	Если loyaltyId <> Неопределено Тогда
		Результат.Вставить("loyaltyId", ЗначениеДляJSON(loyaltyId));
	КонецЕсли;
	Если loyaltyDiscount <> Неопределено Тогда
		Результат.Вставить("loyaltyDiscount", ЗначениеДляJSON(loyaltyDiscount));
	КонецЕсли;
	Если uuidPromocode <> Неопределено Тогда
		Результат.Вставить("uuidPromocode", ЗначениеДляJSON(uuidPromocode));
	КонецЕсли;
	Если salePricePromocodeDiscountPrc <> Неопределено Тогда
		Результат.Вставить("salePricePromocodeDiscountPrc", ЗначениеДляJSON(salePricePromocodeDiscountPrc));
	КонецЕсли;
	Если articleSubstitution <> Неопределено Тогда
		Результат.Вставить("articleSubstitution", ЗначениеДляJSON(articleSubstitution));
	КонецЕсли;
	Если salePriceAffiliatedDiscountPrc <> Неопределено Тогда
		Результат.Вставить("salePriceAffiliatedDiscountPrc", ЗначениеДляJSON(salePriceAffiliatedDiscountPrc));
	КонецЕсли;
	Если agencyVat <> Неопределено Тогда
		Результат.Вставить("agencyVat", ЗначениеДляJSON(agencyVat));
	КонецЕсли;
	Если salePriceWholesaleDiscountPrc <> Неопределено Тогда
		Результат.Вставить("salePriceWholesaleDiscountPrc", ЗначениеДляJSON(salePriceWholesaleDiscountPrc));
	КонецЕсли;
	Если b2bCustomerTin <> Неопределено Тогда
		Результат.Вставить("b2bCustomerTin", ЗначениеДляJSON(b2bCustomerTin));
	КонецЕсли;
	Если paidWithSocialCertificate <> Неопределено Тогда
		Результат.Вставить("paidWithSocialCertificate", ЗначениеДляJSON(paidWithSocialCertificate));
	КонецЕсли;
	Если warehouseLogisticsCoeff <> Неопределено Тогда
		Результат.Вставить("warehouseLogisticsCoeff", ЗначениеДляJSON(warehouseLogisticsCoeff));
	КонецЕсли;
	Если orderUid <> Неопределено Тогда
		Результат.Вставить("orderUid", ЗначениеДляJSON(orderUid));
	КонецЕсли;
	Если srid <> Неопределено Тогда
		Результат.Вставить("srid", ЗначениеДляJSON(srid));
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

