
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Элементы.ТестTG.Видимость = ИнтеграцияСTelegramВызовСервераПовтИсп.ВключенаИнтеграцияСTelegram();
	
КонецПроцедуры

&НаСервере
Процедура ТестTGНаСервере()
	
	ИнтеграцияСTelegram.ОтправитьСообщениеГруппе(Объект.Ссылка, "Тест", 30, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ТестTG(Команда)
	ТестTGНаСервере();
КонецПроцедуры

