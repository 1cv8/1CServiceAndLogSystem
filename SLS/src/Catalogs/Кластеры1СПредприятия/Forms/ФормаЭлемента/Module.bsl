
&НаСервере
Процедура ЗагрузитьСписокБазНаСервере()
	
	ПараметрыАдминистрированияКластера = АдминистрированиеКластера.ПараметрыАдминистрированияКластера();
	ПараметрыАдминистрированияКластера.АдресАгентаСервера = Объект.СетевоеИмя;
	
	COMСоединитель = АдминистрированиеКластераCOM.COMСоединитель();
	
	СоединениеСАгентомСервера = АдминистрированиеКластераCOM.СоединениеСАгентомСервера(
		COMСоединитель,
		ПараметрыАдминистрированияКластера.АдресАгентаСервера,
		ПараметрыАдминистрированияКластера.ПортАгентаСервера);
	
	Кластер = АдминистрированиеКластераCOM.ПолучитьКластер(СоединениеСАгентомСервера,
		ПараметрыАдминистрированияКластера.ПортКластера,
		ПараметрыАдминистрированияКластера.ИмяАдминистратораКластера,
		ПараметрыАдминистрированияКластера.ПарольАдминистратораКластера);
		
	ОписаниеБаз = АдминистрированиеКластераCOM.ОписаниеБазКластера(СоединениеСАгентомСервера, Кластер);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Владелец", Объект.Ссылка);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	БазыДанных1С.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.БазыДанных1С КАК БазыДанных1С
	|ГДЕ
	|	БазыДанных1С.Владелец = &Владелец
	|	И БазыДанных1С.ИмяВКластере = &ИмяВКластере";
	
	Для Каждого ИмяБазы ИЗ ОписаниеБаз Цикл
		
		Запрос.УстановитьПараметр("ИмяВКластере", СокрЛП(ИмяБазы));
		
		Если НЕ Запрос.Выполнить().Пустой() Тогда
			Продолжить;
		КонецЕсли;
		
		БазаОБ = Справочники.БазыДанных1С.СоздатьЭлемент();
		БазаОБ.Владелец		= Объект.Ссылка;
		БазаОБ.ИмяВКластере	= СокрЛП(ИмяБазы);
		БазаОБ.Наименование	= СокрЛП(ИмяБазы);
		
		БазаОБ.Записать();
		
	КонецЦикла;

КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьСписокБаз(Команда)
	
	Если НЕ ЗначениеЗаполнено(Объект.Ссылка) Тогда
		Возврат;
	КонецЕсли;
	
	ЗагрузитьСписокБазНаСервере();
	
КонецПроцедуры
