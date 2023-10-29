
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ИменаКонстант = "УчетнаяЗаписьTelegramПоУмолчанию,ИнтеграцияСTelegram";
	Если ЗначениеЗаполнено(ИменаКонстант) Тогда
		
		Для Каждого ИмяКонстанты ИЗ СтрРазделить(ИменаКонстант, ",", Ложь) Цикл
			ЭтаФорма[ИмяКонстанты] = Константы[ИмяКонстанты].Получить();
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриИзмененииКонстанты(Элемент)
	
	ИзмененитьКонстантуНаСервере(Элемент.Имя);
	
КонецПроцедуры

&НаСервере
Процедура ИзмененитьКонстантуНаСервере(ИмяКонстанты)
	
	Константы[ИмяКонстанты].Установить(ЭтаФорма[ИмяКонстанты]);
	
КонецПроцедуры

&НаКлиенте
Процедура ОчередьПочтаАрхив(Команда)
	
	ОткрытьФорму("РегистрСведений.УС_ОчередьПочтаАрхив.ФормаСписка");
	
КонецПроцедуры

&НаКлиенте
Процедура УчетныеЗаписиЭлектроннойПочты(Команда)
	
	ОткрытьФорму("Справочник.УчетныеЗаписиЭлектроннойПочты.ФормаСписка");
	
КонецПроцедуры

&НаКлиенте
Процедура ФизическиеЛица(Команда)
	
	ОткрытьФорму("Справочник.ФизическиеЛица.ФормаСписка");
	
КонецПроцедуры

&НаКлиенте
Процедура УчетныеЗаписиTelegram(Команда)
	
	ОткрытьФорму("Справочник.УчетныеЗаписиTelegram.ФормаСписка");
	
КонецПроцедуры

