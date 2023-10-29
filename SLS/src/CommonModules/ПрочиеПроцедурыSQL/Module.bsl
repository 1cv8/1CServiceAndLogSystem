
Функция ОписаниеФайлаБэкапаSQL(СерверSQL, ПолноеИмяФайла) Экспорт
	
	Если НЕ ФайлСуществует(ПолноеИмяФайла) Тогда
		ВызватьИсключение ("Не удалось найти файл бэкапа");
	КонецЕсли;
	
	Connection = РаботаСSQLСервером.СоединениеССерверомSQL(СерверSQL);
	
	ТекстЗапроса =
	"RESTORE FILELISTONLY
	|FROM DISK = '" + ПолноеИмяФайла + "'";
	RecordSet = РаботаСSQLСервером.РезультатЗапросаSQL(Connection, ТекстЗапроса);
	
	РаботаСSQLСервером.ВсеЗаписиВыборки = РаботаСSQLСервером.ВсеЗаписиВыборки(RecordSet, "LogicalName,Type");
	РаботаСSQLСервером.ЗакрытьСоединение(Connection);
	
	Если РаботаСSQLСервером.ВсеЗаписиВыборки.Количество() = 0 Тогда
		ВызватьИсключение ("Не удалось прочитать данные файла бэкапа");
	КонецЕсли;
	
	Если РаботаСSQLСервером.ВсеЗаписиВыборки.Количество() <> 2 Тогда
		ВызватьИсключение ("Количество файлов в бэкапе не равно 2ум");
	КонецЕсли;
	
	СинонимФайлаДанных = "";
	СинонимФайлаЛога = "";
	Для Каждого СтрокаВыборки ИЗ РаботаСSQLСервером.ВсеЗаписиВыборки Цикл
		
		Если СтрокаВыборки.Type = "D" Тогда
			СинонимФайлаДанных = СтрокаВыборки.LogicalName;
		ИначеЕсли СтрокаВыборки.Type = "L" Тогда
			СинонимФайлаЛога = СтрокаВыборки.LogicalName;
		КонецЕсли;
		
	КонецЦикла;
	
	ОписаниеФайла = Новый Структура("СинонимФайлаДанных, СинонимФайлаЛога",
		СинонимФайлаДанных,
		СинонимФайлаЛога);
		
	Возврат ОписаниеФайла;
	
КонецФункции

Функция ОписаниеФайловБазыSQL(СерверSQL, БазаДанных) Экспорт
	
	Если НЕ ЗначениеЗаполнено(БазаДанных) Тогда
		ВызватьИсключение ("Не заполнена база данных");
	КонецЕсли;
	
	Connection = РаботаСSQLСервером.СоединениеССерверомSQL(СерверSQL);
	
	ТекстЗапроса =
	"SELECT
	|	name,
	|	physical_name,
	|	type
	|FROM sys.master_files
	|WHERE database_id = DB_ID('%DBName%')";
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "%DBName%", СокрЛП(БазаДанных.ИмяВКластере));
	
	RecordSet = РаботаСSQLСервером.РезультатЗапросаSQL(Connection, ТекстЗапроса);
	
	РаботаСSQLСервером.ВсеЗаписиВыборки = РаботаСSQLСервером.ВсеЗаписиВыборки(RecordSet, "name,physical_name,type");
	РаботаСSQLСервером.ЗакрытьСоединение(Connection);
	
	Если РаботаСSQLСервером.ВсеЗаписиВыборки.Количество() = 0 Тогда
		ВызватьИсключение ("Не удалось прочитать данные файла бэкапа");
	КонецЕсли;
	
	Если РаботаСSQLСервером.ВсеЗаписиВыборки.Количество() <> 2 Тогда
		ВызватьИсключение ("Количество файлов в бэкапе не равно 2ум");
	КонецЕсли;
	
	СинонимФайлаДанных = "";
	СинонимФайлаЛога = "";
	ПутьФайлаДанных = "";
	ПутьФайлаЛога = "";
	Для Каждого СтрокаВыборки ИЗ РаботаСSQLСервером.ВсеЗаписиВыборки Цикл
		
		Если СтрокаВыборки.Type = 0 Тогда
			СинонимФайлаДанных = СтрокаВыборки.name;
			ПутьФайлаДанных = СтрокаВыборки.physical_name;
		ИначеЕсли СтрокаВыборки.Type = 1 Тогда
			СинонимФайлаЛога = СтрокаВыборки.name;
			ПутьФайлаЛога = СтрокаВыборки.physical_name;
		КонецЕсли;
		
	КонецЦикла;
	
	ОписаниеБазы = Новый Структура("СинонимФайлаДанных, СинонимФайлаЛога, ПутьФайлаДанных, ПутьФайлаЛога",
		СинонимФайлаДанных,
		СинонимФайлаЛога,
		ПутьФайлаДанных,
		ПутьФайлаЛога);
		
	Возврат ОписаниеБазы;
	
КонецФункции

Процедура РазвернутьБэкапВБазу(СерверSQL, БазаДанных, ПолноеИмяФайла) Экспорт
	
	ОписаниеФайла = ОписаниеФайлаБэкапаSQL(СерверSQL, ПолноеИмяФайла);
	ОписаниеБазы = ОписаниеФайловБазыSQL(СерверSQL, БазаДанных);
	
	ТекстЗапроса =
	"RESTORE DATABASE [%DBName%]
	|  FROM DISK = N'%FileName%'
	|  WITH  FILE = 1,
	|MOVE N'%DataSynonim%' TO N'%DataFileName%',
	|MOVE N'%LogSynonim%' TO N'%LogFileName%',
	|RECOVERY,
	|REPLACE,
	|STATS = 5";
	
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "%DBName%", СокрЛП(БазаДанных.ИмяВКластере));
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "%FileName%", СокрЛП(ПолноеИмяФайла));
	
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "%DataSynonim%", СокрЛП(ОписаниеФайла.СинонимФайлаДанных));
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "%LogSynonim%", СокрЛП(ОписаниеФайла.СинонимФайлаЛога));
	
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "%DataFileName%", СокрЛП(ОписаниеБазы.ПутьФайлаДанных));
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "%LogFileName%", СокрЛП(ОписаниеБазы.ПутьФайлаЛога));
	
	РаботаСSQLСервером.ВыполнитьКомандуSQL(ТекстЗапроса, СерверSQL,, 2*3600);
	
КонецПроцедуры

Процедура ОтключитьСеансыБазыSQL(СерверSQL, БазаДанных) Экспорт
	
	Если НЕ ЗначениеЗаполнено(БазаДанных) Тогда
		ВызватьИсключение ("Не заполнена база данных");
	КонецЕсли;
	
	Connection = РаботаСSQLСервером.СоединениеССерверомSQL(СерверSQL);
	
	ТекстЗапроса =
	"SELECT session_id  
	|	FROM sys.dm_exec_sessions
	|	WHERE database_id  = db_id('%DBName%')";
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "%DBName%", СокрЛП(БазаДанных.ИмяВКластере));
	
	RecordSet = РаботаСSQLСервером.РезультатЗапросаSQL(Connection, ТекстЗапроса);
	
	РаботаСSQLСервером.ВсеЗаписиВыборки = РаботаСSQLСервером.ВсеЗаписиВыборки(RecordSet, "session_id");
	РаботаСSQLСервером.ЗакрытьСоединение(Connection);
	
	ТекстЗапроса = "";
	Для Каждого ЗаписьВыборки ИЗ РаботаСSQLСервером.ВсеЗаписиВыборки Цикл
		
		Если НЕ ЗначениеЗаполнено(ЗаписьВыборки.session_id) Тогда
			Продолжить;
		КонецЕсли;
		
		ТекстЗапроса = ТекстЗапроса + "kill " + СокрЛП(ЗаписьВыборки.session_id) + ";";
		
	КонецЦикла;
	
	Если НЕ ПустаяСтрока(ТекстЗапроса) Тогда
		РаботаСSQLСервером.ВыполнитьКомандуSQL(ТекстЗапроса, СерверSQL,, 240);
	КонецЕсли;
	
КонецПроцедуры

Процедура УстановитьМодельХраненияБазыSimple(СерверSQL, БазаДанных) Экспорт
	
	Если НЕ ЗначениеЗаполнено(БазаДанных) Тогда
		ВызватьИсключение ("Не заполнена база данных");
	КонецЕсли;
	
	ТекстЗапроса =
	"ALTER DATABASE [%DBName%] SET RECOVERY SIMPLE;";
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "%DBName%", СокрЛП(БазаДанных.ИмяВКластере));
	
	РаботаСSQLСервером.ВыполнитьКомандуSQL(ТекстЗапроса, СерверSQL,, 240);
	
КонецПроцедуры

Процедура СжатьБазуДанных(СерверSQL, БазаДанных) Экспорт
	
	Если НЕ ЗначениеЗаполнено(БазаДанных) Тогда
		ВызватьИсключение ("Не заполнена база данных");
	КонецЕсли;
	
	ТекстЗапроса =
	"DBCC SHRINKDATABASE([%DBName%]);";
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "%DBName%", СокрЛП(БазаДанных.ИмяВКластере));
	РаботаСSQLСервером.ВыполнитьКомандуSQL(ТекстЗапроса, СерверSQL,, 2*3600);
	
КонецПроцедуры

Процедура СжатьЛогФайлБазыДанных(СерверSQL, БазаДанных) Экспорт
	
	Если НЕ ЗначениеЗаполнено(БазаДанных) Тогда
		ВызватьИсключение ("Не заполнена база данных");
	КонецЕсли;
	
	ОписаниеБазы = ОписаниеФайловБазыSQL(СерверSQL, БазаДанных);
	
	ТекстЗапроса =
	"USE [%DBName%]
	|	DBCC SHRINKFILE(N'%LogSynonim%' , 0);";
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "%DBName%", СокрЛП(БазаДанных.ИмяВКластере));
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "%LogSynonim%", СокрЛП(ОписаниеБазы.СинонимФайлаЛога));
	
	РаботаСSQLСервером.ВыполнитьКомандуSQL(ТекстЗапроса, СерверSQL,, 3600);
	
КонецПроцедуры

Функция ТаблицыБазыДанныхДляОбновленияСтатистики(СерверSQL, БазаДанных) Экспорт
	
	Если НЕ ЗначениеЗаполнено(БазаДанных) Тогда
		ВызватьИсключение ("Не заполнена база данных");
	КонецЕсли;
	
	Connection = РаботаСSQLСервером.СоединениеССерверомSQL(СерверSQL, БазаДанных, 1200);
	
	ТекстЗапроса =
	"USE [%DBName%]
	|SELECT
	|	SCHEMA_NAME(o.schema_id) as schema_name,
	|	o.[name] as table_name
	|FROM sys.objects as o WITH(NOLOCK)
	|WHERE
	|	o.[type] in ('U', 'V')
	|	AND o.is_ms_shipped = 0";
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "%DBName%", СокрЛП(БазаДанных.ИмяВКластере));
	
	RecordSet = РаботаСSQLСервером.РезультатЗапросаSQL(Connection, ТекстЗапроса);
	
	РаботаСSQLСервером.ВсеЗаписиВыборки = РаботаСSQLСервером.ВсеЗаписиВыборки(RecordSet, "schema_name,table_name");
	РаботаСSQLСервером.ЗакрытьСоединение(Connection);
	
	Возврат РаботаСSQLСервером.ВсеЗаписиВыборки;
	
КонецФункции	

Процедура ОбновитьСтатистикуБазыДанных(СерверSQL, БазаДанных) Экспорт
	
	Если НЕ ЗначениеЗаполнено(БазаДанных) Тогда
		ВызватьИсключение ("Не заполнена база данных");
	КонецЕсли;
	
	ТекстЗапросаТаблица =
	"UPDATE STATISTICS [%DBName%].[%schema_name%].[%table_name%] WITH FULLSCAN, MAXDOP = 0;";
	ТекстЗапросаТаблица = СтрЗаменить(ТекстЗапросаТаблица, "%DBName%", СокрЛП(БазаДанных.ИмяВКластере));
	
	ТЧТаблицБД = ТаблицыБазыДанныхДляОбновленияСтатистики(СерверSQL, БазаДанных);
	
	Сч = 0;
	МаксимальныйРазмерБлока = 3;
	ТекстЗапроса = "";
	
	Для Каждого СтрокаОписанияИндекса ИЗ ТЧТаблицБД Цикл
		
		Сч = Сч + 1;
		РазмерБлока = РазмерБлока + СтрокаОписанияИндекса.page_count;
		
		ТекстЗапросаДляТаблицы = ТекстЗапросаТаблица;
		
		ТекстЗапросаДляТаблицы = СтрЗаменить(ТекстЗапросаДляТаблицы, "%schema_name%",	СокрЛП(СтрокаОписанияИндекса.schema_name));
		ТекстЗапросаДляТаблицы = СтрЗаменить(ТекстЗапросаДляТаблицы, "%table_name%",	СокрЛП(СтрокаОписанияИндекса.table_name));
		
		ТекстЗапроса = ТекстЗапроса + Символы.ПС + ТекстЗапросаДляТаблицы;
		
		Если Сч % МаксимальныйРазмерБлока = 0 Тогда
			
			РаботаСSQLСервером.ВыполнитьКомандуSQL(ТекстЗапроса, СерверSQL, БазаДанных, 3600);
			
			ТекстЗапроса = "";
			
		КонецЕсли;
		
	КонецЦикла;
	
	Если НЕ ПустаяСтрока(ТекстЗапроса) Тогда
		РаботаСSQLСервером.ВыполнитьКомандуSQL(ТекстЗапроса, СерверSQL, БазаДанных, 3600);
	КонецЕсли;
	
	ТекстЗапроса =
	"USE [%DBName%]
	//|DBCC FREEPROCCACHE";
	|ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE";
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "%DBName%", СокрЛП(БазаДанных.ИмяВКластере));
	
	РаботаСSQLСервером.ВыполнитьКомандуSQL(ТекстЗапроса, СерверSQL, БазаДанных, 3600);
	
	//ТекстЗапроса =
	//"USE [%DBName%]
	//|exec sp_msforeachtable N'UPDATE STATISTICS ? WITH FULLSCAN, MAXDOP = 0';
	//|DBCC FREEPROCCACHE";
	//ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "%DBName%", СокрЛП(БазаДанных.ИмяВКластере));
	//
	//РаботаСSQLСервером.ВыполнитьКомандуSQL(ТекстЗапроса, СерверSQL, БазаДанных, 3600);
	
КонецПроцедуры

Функция СостояниеИндексовБазыДанных(СерверSQL, БазаДанных) Экспорт
	
	Если НЕ ЗначениеЗаполнено(БазаДанных) Тогда
		ВызватьИсключение ("Не заполнена база данных");
	КонецЕсли;
	
	Connection = РаботаСSQLСервером.СоединениеССерверомSQL(СерверSQL, БазаДанных, 1200);
	
	ТекстЗапроса =
	"SELECT
	|	sys_indexes.name as index_name,
	|	SCHEMA_NAME(sys_objects.[schema_id]) as [schema_name],
	|	sys_objects.name as table_name,
	|	cur_stats.page_count as page_count,
	|	cur_stats.avg_fragmentation_in_percent as [avg_fragmentation_in_percent]
	|FROM(
	|	SELECT
	|		stats.index_id,
	|		stats.[object_id],
	|		stats.page_count,
	|		avg_fragmentation_in_percent = MAX(stats.avg_fragmentation_in_percent)
	|	FROM sys.dm_db_index_physical_stats(DB_ID(N'%DBName%'), NULL, NULL, NULL, NULL) AS stats
	|	WHERE
	|		stats.page_count > 128 -- > 1 MB
	|		AND stats.index_id > 0 -- <> HEAP
	|		AND stats.avg_fragmentation_in_percent > 5
	|	GROUP BY
	|		stats.[object_id],
	|		stats.index_id,
	|		stats.page_count) AS cur_stats
	|	JOIN sys.indexes sys_indexes WITH(NOLOCK)
	|		ON cur_stats.[object_id] = sys_indexes.[object_id]
	|		AND cur_stats.index_id = sys_indexes.index_id
	|	JOIN sys.objects sys_objects WITH(NOLOCK)
	|		ON cur_stats.[object_id] = sys_objects.[object_id]
	|	ORDER BY
	|		page_count DESC,
	|		avg_fragmentation_in_percent DESC";
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "%DBName%", СокрЛП(БазаДанных.ИмяВКластере));
	
	RecordSet = РаботаСSQLСервером.РезультатЗапросаSQL(Connection, ТекстЗапроса);
	
	РаботаСSQLСервером.ВсеЗаписиВыборки = РаботаСSQLСервером.ВсеЗаписиВыборки(RecordSet, "index_name,schema_name,table_name,page_count,avg_fragmentation_in_percent");
	РаботаСSQLСервером.ЗакрытьСоединение(Connection);
	
	Возврат РаботаСSQLСервером.ВсеЗаписиВыборки;
	
КонецФункции	

Процедура ПереиндексироватьБазуДанных(СерверSQL, БазаДанных, РежимОнлайн = Ложь) Экспорт
	
	Если НЕ ЗначениеЗаполнено(БазаДанных) Тогда
		ВызватьИсключение ("Не заполнена база данных");
	КонецЕсли;
	
	ТЧСостояниеИндексов = СостояниеИндексовБазыДанных(СерверSQL, БазаДанных);
	
	ТекстЗапросаТаблица = "ALTER INDEX [%index_name%] ON [%schema_name%].[%table_name%]";
	ТекстЗапросаREBUILD = ТекстЗапросаТаблица + " REBUILD WITH (SORT_IN_TEMPDB = ON, MAXDOP = 0, ONLINE = OFF);";
	ТекстЗапросаREORGANIZE = ТекстЗапросаТаблица + " REORGANIZE;";
	
	Если РежимОнлайн = Истина Тогда
		ТекстЗапросаREBUILD = СтрЗаменить(ТекстЗапросаREBUILD, "ONLINE = OFF", "ONLINE = ON");
	КонецЕсли;
	
	Сч = 0;
	РазмерБлока = 0;
	МаксимальныйРазмерБлока = 250 * 128; //250МБ
	ТекстЗапроса = "";
	
	Для Каждого СтрокаОписанияИндекса ИЗ ТЧСостояниеИндексов Цикл
		
		Сч = Сч + 1;
		РазмерБлока = РазмерБлока + СтрокаОписанияИндекса.page_count;
		
		ТекстЗапросаДляТаблицы = "";
		Если СтрокаОписанияИндекса.avg_fragmentation_in_percent > 30 Тогда
			ТекстЗапросаДляТаблицы = ТекстЗапросаREBUILD;
		Иначе
			ТекстЗапросаДляТаблицы = ТекстЗапросаREORGANIZE;
		КонецЕсли;
		
		ТекстЗапросаДляТаблицы = СтрЗаменить(ТекстЗапросаДляТаблицы, "%index_name%",	СокрЛП(СтрокаОписанияИндекса.index_name));
		ТекстЗапросаДляТаблицы = СтрЗаменить(ТекстЗапросаДляТаблицы, "%schema_name%",	СокрЛП(СтрокаОписанияИндекса.schema_name));
		ТекстЗапросаДляТаблицы = СтрЗаменить(ТекстЗапросаДляТаблицы, "%table_name%",	СокрЛП(СтрокаОписанияИндекса.table_name));
		
		ТекстЗапроса = ТекстЗапроса + Символы.ПС + ТекстЗапросаДляТаблицы;
		
		Если РазмерБлока >= МаксимальныйРазмерБлока Тогда
			
			ВыполнитьКомандуПереиндексации(ТекстЗапроса, СерверSQL, БазаДанных);
			
			ТекстЗапроса = "";
			РазмерБлока = 0;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Если НЕ ПустаяСтрока(ТекстЗапроса) Тогда
		ВыполнитьКомандуПереиндексации(ТекстЗапроса, СерверSQL, БазаДанных);
	КонецЕсли;
	
КонецПроцедуры

Процедура ВыполнитьКомандуПереиндексации(ТекстЗапроса, СерверSQL, БазаДанных)
	
	Попытка
		
		РаботаСSQLСервером.ВыполнитьКомандуSQL(ТекстЗапроса, СерверSQL, БазаДанных, 3600);
		
	Исключение
		
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		Если СтрНайти(ТекстОшибки, "online operation cannot be performed") > 0 Тогда
			
			ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "ONLINE = ON", "ONLINE = OFF"); 
			РаботаСSQLСервером.ВыполнитьКомандуSQL(ТекстЗапроса, СерверSQL, БазаДанных, 3600);
			
		Иначе
			
			ВызватьИсключение (ТекстОшибки);
			
		КонецЕсли;
		
	КонецПопытки;
	
КонецПроцедуры

Функция ФайлСуществует(ПолноеИмяФайла)
	Файл = Новый Файл(ПолноеИмяФайла);
	Возврат Файл.Существует();
КонецФункции

