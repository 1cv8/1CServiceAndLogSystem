

Функция СоединениеССерверомSQL(СерверSQL, БазаДанных = Неопределено, Знач ConnectionTimeout = Неопределено) Экспорт
	
	Если ConnectionTimeout = Неопределено Тогда
		ConnectionTimeout = 10;
	КонецЕсли;
	
	ТипСервера = СерверSQL.ТипСервера;
	Если НЕ ЗначениеЗаполнено(ТипСервера) Тогда
		ТипСервера = Справочники.ТипыСерверовSQL.MS_SQL;
	КонецЕсли;
	
	ШаблонСтрокиПодключения = ТипСервера.ШаблонСтрокиПодключения;
	ШаблонСтрокиПодключенияИмяБазы = ТипСервера.ШаблонСтрокиПодключенияИмяБазы;
	Если НЕ ЗначениеЗаполнено(ШаблонСтрокиПодключения) Тогда
		
		ШаблонСтрокиПодключения =
			"Provider=SQLOLEDB.1;
			|Persist Security Info=False;
			|Data Source=%ИмяСервера%;
			|User ID=%ИмяПользователя%;
			|Password=%Пароль%;";
		
		Если НЕ ЗначениеЗаполнено(ШаблонСтрокиПодключенияИмяБазы) Тогда
			ШаблонСтрокиПодключенияИмяБазы = "Initial Catalog=%ИмяБазы%";
		КонецЕсли;
		
	КонецЕсли;
	
	ConnectionString = ШаблонСтрокиПодключения;
	ConnectionString = СтрЗаменить(ConnectionString, "%ИмяСервера%", СокрЛП(СерверSQL.СетевоеИмя));
	Если БазаДанных <> Неопределено
		И ЗначениеЗаполнено(ШаблонСтрокиПодключенияИмяБазы) Тогда
		ConnectionString = ConnectionString + Символы.ПС + СтрЗаменить(ШаблонСтрокиПодключенияИмяБазы, "%ИмяБазы%", СокрЛП(БазаДанных.Наименование));
	КонецЕсли;
	
	ИмяСлужебногоПользователя = "";
	Если БазаДанных <> Неопределено Тогда
		ИмяСлужебногоПользователя = ОбщегоНазначения.ПрочитатьДанныеИзБезопасногоХранилища(БазаДанных, "ИмяСлужебногоПользователяSQL");
		ПарольСлужебногоПользователя = ОбщегоНазначения.ПрочитатьДанныеИзБезопасногоХранилища(БазаДанных, "ПарольСлужебногоПользователяSQL");
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ИмяСлужебногоПользователя) Тогда
		ИмяСлужебногоПользователя = ОбщегоНазначения.ПрочитатьДанныеИзБезопасногоХранилища(СерверSQL, "ИмяСлужебногоПользователяSQL");
		ПарольСлужебногоПользователя = ОбщегоНазначения.ПрочитатьДанныеИзБезопасногоХранилища(СерверSQL, "ПарольСлужебногоПользователяSQL");
	КонецЕсли;
	
	ConnectionString = СтрЗаменить(ConnectionString, "%ИмяПользователя%", ИмяСлужебногоПользователя);
	ConnectionString = СтрЗаменить(ConnectionString, "%Пароль%", ПарольСлужебногоПользователя);
	
	Connection  = Новый COMОбъект("ADODB.Connection");
	Connection.ConnectionTimeout = ConnectionTimeout;
	Connection.CommandTimeout = ConnectionTimeout;
  	Connection.Open(ConnectionString);
	
	Возврат Connection;
	
КонецФункции

Процедура ЗакрытьСоединение(Connection) Экспорт
	
	Попытка
		Connection.Close();
	Исключение
	КонецПопытки;
	
КонецПроцедуры

Функция ВВыборкеЕстьЗаписи(RecordSet) Экспорт
	
	ЕстьЗаписи = Ложь;
	
	Попытка
		
		Если НЕ RecordSet.EOF() И НЕ RecordSet.BOF() Тогда
			ЕстьЗаписи = Истина;
		КонецЕсли;
		
	Исключение
		
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		
	КонецПопытки;
	
	Возврат ЕстьЗаписи;
	
КонецФункции

Функция СледующаяЗаписьВыборки(RecordSet) Экспорт
	
	ЕстьСледующаяЗаписьВыборки = Ложь;
	Попытка
		ЕстьСледующаяЗаписьВыборки = НЕ RecordSet.EOF();
	Исключение
		ЕстьСледующаяЗаписьВыборки = Ложь;
	КонецПопытки;
	
	Возврат ЕстьСледующаяЗаписьВыборки;
	
КонецФункции

Функция ЗначениеПолейВыборки(RecordSet, ИменаПолей) Экспорт
	
	ОписаниеПолей = Новый Структура(ИменаПолей);
	
	Для Каждого ОписаниеПоля ИЗ ОписаниеПолей Цикл
		
		Попытка
			ЗначениеПоля = RecordSet.Fields(ОписаниеПоля.Ключ).Value;
		Исключение
			ЗначениеПоля = Неопределено;
		КонецПопытки;
		
		ОписаниеПолей.Вставить(ОписаниеПоля.Ключ, ЗначениеПоля);
		
	КонецЦикла;
	
	Возврат ОписаниеПолей;
	
КонецФункции

Функция РезультатЗапросаSQL(Connection, ТекстЗапроса, Знач CommandTimeout = Неопределено) Экспорт
	
	Попытка
		
		Если CommandTimeout = Неопределено Тогда
			CommandTimeout = Connection.CommandTimeout;
		КонецЕсли;
		
		Command = Новый COMОбъект("ADODB.Command");
		Command.ActiveConnection = Connection;
		Command.CommandText = ТекстЗапроса;
		Command.CommandTimeout = CommandTimeout;
		
		RecordSet = Command.Execute();
		
		//RecordSet =  Новый COMОбъект("ADODB.RecordSet");
		////RecordSet.ActiveConnection = Connection;
		//////RecordSet.CursorType = 3;
		//////RecordSet.LockType = 2;
		////RecordSet.CursorType = 0;
		////RecordSet.LockType = 1;
		//RecordSet.Open(ТекстЗапроса, Connection, 3, 1, 1);
		
		Возврат RecordSet;
		
	Исключение
		
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		
		ЗакрытьСоединение(Connection);
		ВызватьИсключение (ТекстОшибки);
		
	КонецПопытки;
	
КонецФункции

Процедура ВыполнитьКомандуSQL(ТекстЗапроса, СерверSQL, БазаДанных = Неопределено, ConnectionTimeout = Неопределено) Экспорт
	
	Connection = СоединениеССерверомSQL(СерверSQL, БазаДанных, ConnectionTimeout);
	
	Попытка
		
		Command = Новый COMОбъект("ADODB.Command");
		Command.ActiveConnection = Connection;
		Command.CommandText = ТекстЗапроса;
		
		Command.CommandTimeout = Connection.CommandTimeout;
		Command.Execute();
		
	Исключение
		
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		
		ЗакрытьСоединение(Connection);
		ВызватьИсключение (ТекстОшибки);
		
	КонецПопытки;
	
	ЗакрытьСоединение(Connection);
	
КонецПроцедуры

Функция ВсеЗаписиВыборки(RecordSet, ИменаПолей = Неопределено) Экспорт
	
	Если ИменаПолей = Неопределено Тогда
		ИменаПолей = ИменаПолейВыборки(RecordSet);
	КонецЕсли;
	
	ТаблицаЗаписей = Новый ТаблицаЗначений;
	Для Каждого ИмяПоля ИЗ СтрРазделить(ИменаПолей, ",", Ложь) Цикл
		ТаблицаЗаписей.Колонки.Добавить(СокрЛП(ИмяПоля));
	КонецЦикла;
	
	Если НЕ ВВыборкеЕстьЗаписи(RecordSet) Тогда
		Возврат ТаблицаЗаписей;
	КонецЕсли;
	
	Пока СледующаяЗаписьВыборки(RecordSet) Цикл
		
		СтрокаТЧ = ТаблицаЗаписей.Добавить();
		ЗначенияПолей = ЗначениеПолейВыборки(RecordSet, ИменаПолей);
		ЗаполнитьЗначенияСвойств(СтрокаТЧ, ЗначенияПолей);
		
		Попытка
			RecordSet.MoveNext();
		Исключение
			Прервать;
		КонецПопытки;
		
	КонецЦикла;
	
	RecordSet.Close();
	
	Возврат ТаблицаЗаписей;
	
КонецФункции

Функция ИменаПолейВыборки(RecordSet) Экспорт
	
	Если RecordSet = Неопределено Тогда
		Возврат "";
	КонецЕсли;
	
	МассивИменПолей = Новый Массив;
	Для НомерСтолбца = 0 По RecordSet.Fields.Count-1 Цикл
 		ИмяСтолбца = RecordSet.Fields.Item(НомерСтолбца).Name;
		МассивИменПолей.Добавить(ИмяСтолбца);
	КонецЦикла;
	
	Возврат СтрСоединить(МассивИменПолей, ",");
	
КонецФункции

Функция ДатаИзSQLСтроки(Значение) Экспорт
	//ОбщегоНазначенияКлиентСервер.СтрокаВДату(Значение);

	ПустаяДата = Дата(1, 1, 1);
	
	Если Не ЗначениеЗаполнено(Значение) Тогда 
		Возврат ПустаяДата;
	КонецЕсли;
	
	ОписаниеДаты = Новый ОписаниеТипов("Дата");
	Дата = ОписаниеДаты.ПривестиЗначение(Значение);
	
	Если ТипЗнч(Дата) = Тип("Дата")
		И ЗначениеЗаполнено(Дата) Тогда 
		
		Возврат Дата;
	КонецЕсли;
	
	#Область ПодготовкаЧастейДаты
	
	КоличествоСимволов = СтрДлина(Значение);
	
	Если КоличествоСимволов > 25 Тогда 
		Возврат ПустаяДата;
	КонецЕсли;
	
	ЧастиЗначения = Новый Массив;
	ЧастьЗначения = "";
	
	Для НомерСимвола = 1 По КоличествоСимволов Цикл 
		
		Символ = Сред(Значение, НомерСимвола, 1);
		
		Если ОбщегоНазначенияКлиентСервер.ЭтоЧисло(Символ) Тогда 
			
			ЧастьЗначения = ЧастьЗначения + Символ;
			
		Иначе
			
			Если Не ПустаяСтрока(ЧастьЗначения) Тогда 
				ЧастиЗначения.Добавить(ЧастьЗначения);
			КонецЕсли;
			
			ЧастьЗначения = "";
			
		КонецЕсли;
		
		Если НомерСимвола = КоличествоСимволов
			И Не ПустаяСтрока(ЧастьЗначения) Тогда 
			
			ЧастиЗначения.Добавить(ЧастьЗначения);
		КонецЕсли;
		
	КонецЦикла;
	
	Если ЧастиЗначения.Количество() < 3 Тогда 
		Возврат ПустаяДата;
	КонецЕсли;
	
	Если ЧастиЗначения.Количество() < 4 Тогда 
		ЧастиЗначения.Добавить("00");
	КонецЕсли;
	
	Если ЧастиЗначения.Количество() < 5 Тогда 
		ЧастиЗначения.Добавить("00");
	КонецЕсли;
	
	Если ЧастиЗначения.Количество() < 6 Тогда 
		ЧастиЗначения.Добавить("00");
	КонецЕсли;
	
	#КонецОбласти
	
	// Если формат ггггММддЧЧммсс:
	НормализованноеЗначение = ЧастиЗначения[0] + ЧастиЗначения[1] + ЧастиЗначения[2]
		+ ЧастиЗначения[3] + ЧастиЗначения[4] + ЧастиЗначения[5];
	
	Дата = ОписаниеДаты.ПривестиЗначение(НормализованноеЗначение);
	
	Если ТипЗнч(Дата) = Тип("Дата")
		И ЗначениеЗаполнено(Дата) Тогда 
		
		Возврат Дата;
	КонецЕсли;
	
	// Если формат ггггддММЧЧммсс
	НормализованноеЗначение = ЧастиЗначения[2] + ЧастиЗначения[0] + ЧастиЗначения[1]
		+ ЧастиЗначения[3] + ЧастиЗначения[4] + ЧастиЗначения[5];
	
	Дата = ОписаниеДаты.ПривестиЗначение(НормализованноеЗначение);
	
	Если ТипЗнч(Дата) = Тип("Дата")
		И ЗначениеЗаполнено(Дата) Тогда 
		
		Возврат Дата;
	КонецЕсли;
	
	Возврат ПустаяДата;
	
КонецФункции

