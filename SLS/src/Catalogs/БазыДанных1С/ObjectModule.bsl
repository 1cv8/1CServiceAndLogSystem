
Процедура ПриКопировании(ОбъектКопирования)
	
	ИдентификаторЖурналаИсключений = "";
	
	Если ЗначениеЗаполнено(ИмяВКластере) Тогда
		ИмяВКластере = ИмяВКластере + "1";
	КонецЕсли;
	
	БазаДаннызSQL = Неопределено;
	
	ИмяСервераПубликации = "";
	ПортПубликации = 0;
	ПутьКПубликацииНаСервере = "";
	
КонецПроцедуры
