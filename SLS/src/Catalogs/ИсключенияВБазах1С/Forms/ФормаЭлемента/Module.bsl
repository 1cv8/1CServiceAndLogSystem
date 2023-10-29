
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Элементы.Игнорировать.Видимость = Пользователи.РолиДоступны("ПравоПереводитьИсключенияВСтатусИгнорировать");
		
	ОбщегоНазначенияКлиентСервер.УстановитьПараметрДинамическогоСписка(
		СписокРешений,
		"Исключение",
		Объект.Ссылка);
		
	ОбновитьДанныеПоЗадачеJIRA();	
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)

	ОбщегоНазначенияКлиентСервер.УстановитьПараметрДинамическогоСписка(
		СписокРешений,
		"Исключение",
		Объект.Ссылка);
	
	ОбновитьДанныеПоЗадачеJIRA();
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура РешитьНаСервере(ИсключениеСсылка, ДатаДо)
	
	Для Каждого База1С ИЗ ЖурналИсключений.Базы1СИсключения(ИсключениеСсылка) Цикл
		
		ЖурналИсключений.ОтметитьИсправлениеИсключения(База1С, ИсключениеСсылка, ДатаДо);
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура Решить(Команда)
	
	Если ЗначениеЗаполнено(Объект.Ссылка) Тогда
		РешитьНаСервере(Объект.Ссылка, ДатаДо);
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ИгнорироватьНаСервере(ИсключениеСсылка)
	
	Для Каждого База1С ИЗ ЖурналИсключений.Базы1СИсключения(ИсключениеСсылка) Цикл
		
		ЖурналИсключений.УстановитьИгнорИсключения(База1С, ИсключениеСсылка);
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура Игнорировать(Команда)
	
	Если ЗначениеЗаполнено(Объект.Ссылка) Тогда
		ИгнорироватьНаСервере(Объект.Ссылка);
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ОтложитьНаСервере(ИсключениеСсылка, ДатаДо)
	
	Для Каждого База1С ИЗ ЖурналИсключений.Базы1СИсключения(ИсключениеСсылка) Цикл
		
		ЖурналИсключений.ОтложитьОбработкуИсключения(База1С, ИсключениеСсылка, ДатаДо);
		
	КонецЦикла;

КонецПроцедуры

&НаКлиенте
Процедура Отложить(Команда)
	
	Если ЗначениеЗаполнено(Объект.Ссылка) Тогда
		ОтложитьНаСервере(Объект.Ссылка, ДатаДо);
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ВернутьВРаботуНаСервере(ИсключениеСсылка)

	Для Каждого База1С ИЗ ЖурналИсключений.Базы1СИсключения(ИсключениеСсылка) Цикл
		
		ЖурналИсключений.ВернутьВРаботуИсключение(База1С, ИсключениеСсылка);
		
	КонецЦикла;

КонецПроцедуры

&НаКлиенте
Процедура ВернутьВРаботу(Команда)

	Если ЗначениеЗаполнено(Объект.Ссылка) Тогда
		ВернутьВРаботуНаСервере(Объект.Ссылка);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ДатаДоПриИзменении(Элемент)

	ДатаДоМакс = КонецДня(ТекущаяДата()) + 1;
	ДатаДоМакс = ДатаДоМакс + 7*24*60*60;
	
	ДатаДоМин = КонецДня(ТекущаяДата()) + 1;
	ДатаДоМин = ДатаДоМин + 2*60*60;

	ДатаДо = Мин(ДатаДо, ДатаДоМакс);
	ДатаДо = Макс(ДатаДо, ДатаДоМин);
	
КонецПроцедуры


&НаСервере
Процедура СоздатьЗадачуВJiraНаСервере()
	
	Шаблон = Константы.ШаблонДляСозданияНовыхЗадач.Получить();
	
	База1С = Неопределено;
	Для Каждого База1С ИЗ ЖурналИсключений.Базы1СИсключения(Объект.Ссылка) Цикл
		Прервать;
	КонецЦикла;
	
	ПодробноеОписаниеЗадачи =
		СтрШаблон(
			"В базе %1 возникло исключение:
			|%2",
			База1С,
			Объект.ТекстИсключения);
	
	ПараметрыЗадачи = Новый Структура;
	ПараметрыЗадачи.Вставить("Наименование", "[Исключение] " + Объект.Наименование);
	ПараметрыЗадачи.Вставить("ПодробноеОписаниеЗадачи", ПодробноеОписаниеЗадачи);
	
	ИнтеграцияСJira.СоздатьЗадачу(Шаблон, ПараметрыЗадачи, Объект.Ссылка);
	
	ОбновитьДанныеПоЗадачеJIRA();
	
КонецПроцедуры


&НаКлиенте
Процедура СоздатьЗадачуВJira(Команда)
	
	Обработчик = Новый ОписаниеОповещения("СоздатьЗадачуВJira_ПослеЗаписи", ЭтотОбъект);
	РаботаСДиалогамиКлиент.ЗаписатьСправочникВФормеПриНеобходимости(Обработчик, ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура СоздатьЗадачуВJira_ПослеЗаписи(ЗаписаноУспешно, ДополнительныеПараметры) Экспорт
	
	Если НЕ ЗаписаноУспешно Тогда
		Возврат;
	КонецЕсли;
	
	СоздатьЗадачуВJiraНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьДанныеПоЗадачеJIRA()
	
	СсылкаНаЗадачуJira = "";
	
	ДанныеПоЗадаче = ИнтеграцияСJira.ПарамерыПоследнейЗадачиПоОснованию(Объект.Ссылка);
	Если ЗначениеЗаполнено(ДанныеПоЗадаче.key) Тогда
		СсылкаНаЗадачуJira = ИнтеграцияСJira.ТекстСсылкиJira(ДанныеПоЗадаче.Jira, ДанныеПоЗадаче.key);
	КонецЕсли;
	
	Элементы.СоздатьЗадачуВJira.Видимость = НЕ ЗначениеЗаполнено(СсылкаНаЗадачуJira);
	
КонецПроцедуры

&НаКлиенте
Процедура СсылкаНаЗадачуJiraНажатие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	Если ЗначениеЗаполнено(СсылкаНаЗадачуJira) Тогда
		ЗапуститьПриложение(СсылкаНаЗадачуJira);
	КонецЕсли;
	
КонецПроцедуры
