
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	Если НЕ ЗначениеЗаполнено(База1С) Тогда
		База1С = Константы.База1СДляПросмотраИсключенийПоУмолчанию.Получить();
	КонецЕсли;
	
	ОбщегоНазначенияКлиентСервер.УстановитьПараметрДинамическогоСписка(
		Список,
		"База1С",
		База1С);
	
КонецПроцедуры

&НаКлиенте
Процедура База1СПриИзменении(Элемент)

	ОбщегоНазначенияКлиентСервер.УстановитьПараметрДинамическогоСписка(
		Список,
		"База1С",
		База1С);

КонецПроцедуры
