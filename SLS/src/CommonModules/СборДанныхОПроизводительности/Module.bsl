
#Область АктивныеЗапросыИТранзакции

Процедура Регламент_СборДанныхSQL() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	НастройкиСбораДанныхSQL.СерверSQL КАК СерверSQL,
	|	НастройкиСбораДанныхSQL.АктивныеЗапросы КАК АктивныеЗапросы,
	|	НастройкиСбораДанныхSQL.АктивныеТранзакции КАК АктивныеТранзакции,
	|	НастройкиСбораДанныхSQL.ДлительностьЗапросовОт КАК ДлительностьЗапросовОт,
	|	НастройкиСбораДанныхSQL.ДлительностьТранзакцийОт КАК ДлительностьТранзакцийОт
	|ИЗ
	|	РегистрСведений.НастройкиСбораДанныхSQL КАК НастройкиСбораДанныхSQL
	|ГДЕ
	|	(НастройкиСбораДанныхSQL.АктивныеЗапросы
	|			ИЛИ НастройкиСбораДанныхSQL.АктивныеТранзакции)
	|	И НЕ НастройкиСбораДанныхSQL.СерверSQL.ПометкаУдаления";
	
	ВыборкаСерверов = Запрос.Выполнить().Выбрать();
	Пока ВыборкаСерверов.Следующий() Цикл
		Регламент_СобратьДанныеОСервереSQL(ВыборкаСерверов);
	КонецЦикла;
	
КонецПроцедуры

Процедура Регламент_СобратьДанныеОСервереSQL(ВыборкаСерверов)
	
	Если ВыборкаСерверов.АктивныеЗапросы Тогда
		Регламент_СобратьДанныеОСервереSQL_АктивныеЗапросы(ВыборкаСерверов.СерверSQL, ВыборкаСерверов.ДлительностьЗапросовОт);
	КонецЕсли;
	
	Если ВыборкаСерверов.АктивныеТранзакции Тогда
		Регламент_СобратьДанныеОСервереSQL_АктивныеТранзакции(ВыборкаСерверов.СерверSQL, ВыборкаСерверов.ДлительностьТранзакцийОт);
	КонецЕсли;
	
КонецПроцедуры

#Область АктивныеЗапросы

Функция АктивныеЗапросыНаSQLСервере(СерверSQL, МинДлительность = Неопределено) Экспорт
	
	//|	qerPlan.query_plan AS [plan_text]
	//|	OUTER APPLY sys.dm_exec_query_plan(req.plan_handle) qerPlan
	
	ТекстЗапроса_SQL =
	"SELECT 
	|	sqltext.TEXT AS [sql_text],
	|	case when sql_handle IS NULL
	|		then ' '
	|	else 
	|		substring(sqltext.text,
	|			(req.statement_start_offset+2)/2, 
	|			(case 
	|				when req.statement_end_offset = -1 then 
	|					100000 
	|				else 
	|					req.statement_end_offset  
	|				end
	|			- req.statement_start_offset
	|			)/2 + 1
	|		)
	|	end as query_text,
	|	req.database_id as dbid,
	|	dtb.name as dbname,
	|	req.session_id AS [session],
	|	req.status AS [status],
	|	req.command AS [commad],
	|	req.cpu_time/1000 AS [CPU],
	|	req.start_time as [start_time],
	|	req.total_elapsed_time/1000 AS [duration]
	|FROM sys.dm_exec_requests req
	|	CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS sqltext
	|	LEFT OUTER JOIN sys.databases as dtb
	|	on req.database_id = dtb.database_id
	|";
	
	Если МинДлительность <> Неопределено
		И МинДлительность > 0
		Тогда
		
		ТекстЗапроса_SQL = ТекстЗапроса_SQL + "
		|
		|WHERE
		|	req.total_elapsed_time >= " + Формат(МинДлительность*1000, "ЧГ=");
		
	КонецЕсли;
	
	ТекстЗапроса_SQL = ТекстЗапроса_SQL + "
	|
	|ORDER BY
	|	req.total_elapsed_time desc";
	
	Connection = РаботаСSQLСервером.СоединениеССерверомSQL(СерверSQL);
	RecordSet = РаботаСSQLСервером.РезультатЗапросаSQL(Connection, ТекстЗапроса_SQL);
	ТЧ_SQL = РаботаСSQLСервером.ВсеЗаписиВыборки(RecordSet);
	РаботаСSQLСервером.ЗакрытьСоединение(Connection);
	
	Возврат ТЧ_SQL;
	
КонецФункции

Процедура Регламент_СобратьДанныеОСервереSQL_АктивныеЗапросы(СерверSQL, ДлительностьЗапросовОт) Экспорт
	
	СохранятьПланыЗапросовSQL = Константы.СохранятьПланыЗапросовSQL.Получить();

	МодульRegExp = МодульRegExpДляЗапроса();
	
	//ТекДата = ТекущаяУниверсальнаяДата();
	ТекДата = ТекущаяДатаСеанса();
	
	ТЧЗапросов = АктивныеЗапросыНаSQLСервере(СерверSQL, ДлительностьЗапросовОт);
	Для Каждого ОписаниеЗапросаSQL Из ТЧЗапросов Цикл
		
		ДатаНачала = ОписаниеЗапросаSQL.start_time;
		
		//ДанныеЗапроса = ДанныеЗапросаSQLВБазеПоТексту(ОписаниеЗапросаSQL.sql_text);
		ДанныеЗапроса = ДанныеЗапросаSQLВБазеПоТексту(ОписаниеЗапросаSQL.query_text,, МодульRegExp);
		
		ЗапросSQL = ДанныеЗапроса.ЗапросSQL;
		
		КлючЗаписи = КлючЗаписи_СобранныеЗапросы(ДатаНачала, СерверSQL, ОписаниеЗапросаSQL.session, ДанныеЗапроса.ЗапросSQL);
		ЕстьЗаписи = Истина;
		Если КлючЗаписи.ID = Неопределено Тогда
			КлючЗаписи.ID = Новый УникальныйИдентификатор();
			ЕстьЗаписи = Ложь;
		КонецЕсли;

		НЗ_Запросы = РегистрыСведений.СобранныеЗапросыSQL.СоздатьНаборЗаписей();
		НЗ_Запросы.Отбор.ДатаНачала.Установить(КлючЗаписи.ДатаНачала);
		НЗ_Запросы.Отбор.СерверSQL.Установить(КлючЗаписи.СерверSQL);
		НЗ_Запросы.Отбор.ID.Установить(КлючЗаписи.ID);
		
		Если ЕстьЗаписи Тогда
			НЗ_Запросы.Прочитать();
			Запись_Запросы = НЗ_Запросы[0];
		Иначе
			Запись_Запросы = НЗ_Запросы.Добавить();
			ЗаполнитьЗначенияСвойств(Запись_Запросы, КлючЗаписи);
		КонецЕсли;
		
		ЗаполнитьЗначенияСвойств(Запись_Запросы, ОписаниеЗапросаSQL);
		
		Запись_Запросы.ЗапросSQL = ЗапросSQL;
		Запись_Запросы.ДатаОбновления = ТекДата;
		
		НЗ_Запросы.ОбменДанными.Загрузка = Истина;
		НЗ_Запросы.Записать(Истина);
		
	КонецЦикла;
	
	МЗ = РегистрыСведений.ДатыСобранныхЗапросовSQL.СоздатьМенеджерЗаписи();
	МЗ.СерверSQL = СерверSQL;
	МЗ.ДатаПоследнегоСбора = ТекДата;
	
	МЗ.Записать(Истина);
	
КонецПроцедуры

Функция КлючЗаписи_СобранныеЗапросы(ДатаНачала, СерверSQL, session, ЗапросSQL)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ДатаНачала", ДатаНачала);
	Запрос.УстановитьПараметр("СерверSQL", СерверSQL);
	Запрос.УстановитьПараметр("session", session);
	Запрос.УстановитьПараметр("ЗапросSQL", ЗапросSQL);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	СобранныеЗапросыSQL.ДатаНачала КАК ДатаНачала,
	|	СобранныеЗапросыSQL.СерверSQL КАК СерверSQL,
	|	СобранныеЗапросыSQL.ID КАК ID,
	|	СобранныеЗапросыSQL.session КАК session,
	|	СобранныеЗапросыSQL.ЗапросSQL КАК ЗапросSQL
	|ИЗ
	|	РегистрСведений.СобранныеЗапросыSQL КАК СобранныеЗапросыSQL
	|ГДЕ
	|	СобранныеЗапросыSQL.ДатаНачала = &ДатаНачала
	|	И СобранныеЗапросыSQL.СерверSQL = &СерверSQL
	|	И СобранныеЗапросыSQL.session = &session
	|	И СобранныеЗапросыSQL.ЗапросSQL = &ЗапросSQL";
	
	КлючЗаписи = Новый Структура("ДатаНачала, СерверSQL, ID",
		ДатаНачала,
		СерверSQL
		);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		
		КлючЗаписи.ID = Выборка.ID;
		Возврат КлючЗаписи;
		
	КонецЦикла;
	
	Возврат КлючЗаписи;
	
КонецФункции

#КонецОбласти

#Область АктивныеТранзакции

Функция АктивныеТранзакцииНаSQLСервере(СерверSQL) Экспорт
	
	//|	PLAN_INFO.query_plan as [plan_text]
	//|	LEFT JOIN (
	//|		SELECT
	//|			VL_SESSION_TRAN.session_id AS session_id,
	//|			VL_PLAN_INFO.query_plan AS query_plan
	//|		FROM sys.dm_tran_session_transactions AS VL_SESSION_TRAN
	//|		INNER JOIN sys.dm_exec_requests AS VL_QUERIES_INFO
	//|			ON VL_SESSION_TRAN.session_id = VL_QUERIES_INFO.session_id
	//|		OUTER APPLY sys.dm_exec_text_query_plan(VL_QUERIES_INFO.plan_handle, VL_QUERIES_INFO.statement_start_offset, VL_QUERIES_INFO.statement_end_offset) AS VL_PLAN_INFO
	//|	) AS PLAN_INFO
	//|		ON SESSION_TRAN.session_id = PLAN_INFO.session_id
	
	//|	SQL_TEXT.dbid,
	//|	db_name(SQL_TEXT.dbid) AS ib_name,
	
	
	ТекстЗапроса_SQL =
	"DECLARE @curr_date as DATETIME
	|
	|SET @curr_date = GETDATE()
	|
	|select
	|	SESSION_TRAN.session_id AS [session],
	|	SESSION_TRAN.transaction_id as [transaction],
	|	
	|	TRAN_INFO.transaction_begin_time AS [start_time],
	|	DateDiff(second, TRAN_INFO.transaction_begin_time, @curr_date) AS [duration],
	|	CASE   
	|      WHEN TRAN_INFO.transaction_type = 1 THEN 'read-write'
	|	  WHEN TRAN_INFO.transaction_type = 1 THEN 'read-only'
	|	  WHEN TRAN_INFO.transaction_type = 1 THEN 'system'
	|	  WHEN TRAN_INFO.transaction_type = 1 THEN 'distributed'
	|	  ELSE 'unknown'
	|	END as [type],
	|	
	|	CASE   
	|      WHEN TRAN_INFO.transaction_state = 0 THEN 'new'
	|      WHEN TRAN_INFO.transaction_state = 1 THEN 'initialized'
	|	  WHEN TRAN_INFO.transaction_state = 2 THEN 'active'
	|	  WHEN TRAN_INFO.transaction_state = 3 THEN 'ended'
	|	  WHEN TRAN_INFO.transaction_state = 4 THEN 'commit_begin'
	|	  WHEN TRAN_INFO.transaction_state = 5 THEN 'commit'
	|	  WHEN TRAN_INFO.transaction_state = 6 THEN 'commit_done'
	|	  WHEN TRAN_INFO.transaction_state = 7 THEN 'rollback'
	|	  WHEN TRAN_INFO.transaction_state = 8 THEN 'rollback_done'
	|	  ELSE 'unknown'
	|	END as [state],
	|
	|	CONN_INFO.num_reads AS num_reads,
	|	CONN_INFO.num_writes AS num_writes,
	|	CONN_INFO.last_read AS last_read,
	|	CONN_INFO.last_write AS last_write,
	|	CONN_INFO.client_net_address AS client_ip,
	|	
	|	dbt.database_id as dbid,
	|	dtb.name as dbname,
	|	SQL_TEXT.text AS [sql_text],
	|	case when sql_handle IS NULL
	|		then ' '
	|	else 
	|		substring(SQL_TEXT.text,
	|			(QUERIES_INFO.statement_start_offset+2)/2, 
	|			(case 
	|				when QUERIES_INFO.statement_end_offset = -1 then 
	|					100000 
	|				else 
	|					QUERIES_INFO.statement_end_offset  
	|				end
	|			- QUERIES_INFO.statement_start_offset
	|			)/2 + 1
	|		)
	|	end as query_text,
	|	
	//|	QUERIES_INFO.start_time,
	|	QUERIES_INFO.status,
	|	QUERIES_INFO.command,
	|	QUERIES_INFO.wait_type,
	|	QUERIES_INFO.wait_time
	|
	|FROM sys.dm_tran_session_transactions AS SESSION_TRAN
	|	JOIN sys.dm_tran_active_transactions AS TRAN_INFO
	|		ON SESSION_TRAN.transaction_id = TRAN_INFO.transaction_id
	|	LEFT JOIN (
	|		SELECT
	|			dbt.transaction_id as transaction_id,
	|			min(dbt.database_id) as database_id
	|		FROM sys.dm_tran_database_transactions as dbt
	|		WHERE
	|			dbt.database_id <> DB_ID(N'tempdb')
	|		GROUP BY
	|			dbt.transaction_id) as dbt
	|		ON SESSION_TRAN.transaction_id = dbt.transaction_id
	|	LEFT OUTER JOIN sys.databases as dtb
	|		ON dbt.database_id = dtb.database_id
	|	LEFT JOIN sys.dm_exec_connections AS CONN_INFO
	|		ON SESSION_TRAN.session_id = CONN_INFO.session_id
	|	CROSS APPLY sys.dm_exec_sql_text(CONN_INFO.most_recent_sql_handle) AS SQL_TEXT
	|	LEFT JOIN sys.dm_exec_requests AS QUERIES_INFO
	|		ON SESSION_TRAN.session_id = QUERIES_INFO.session_id
	|
	|ORDER BY transaction_begin_time ASC
	|";
	
	Connection = РаботаСSQLСервером.СоединениеССерверомSQL(СерверSQL);
	RecordSet = РаботаСSQLСервером.РезультатЗапросаSQL(Connection, ТекстЗапроса_SQL);
	ТЧ_SQL = РаботаСSQLСервером.ВсеЗаписиВыборки(RecordSet);
	РаботаСSQLСервером.ЗакрытьСоединение(Connection);
	
	Возврат ТЧ_SQL;
	
КонецФункции

Процедура Регламент_СобратьДанныеОСервереSQL_АктивныеТранзакции(СерверSQL, ДлительностьЗапросовОт) Экспорт
	
	//ТекДата = ТекущаяУниверсальнаяДата();
	ТекДата = ТекущаяДатаСеанса();
	МодульRegExp = МодульRegExpДляЗапроса();
	
	ТЧЗапросов = АктивныеТранзакцииНаSQLСервере(СерверSQL);
	Для Каждого ОписаниеЗапросаSQL Из ТЧЗапросов Цикл
		
		Если ДлительностьЗапросовОт <> Неопределено
			И ДлительностьЗапросовОт > 0
			И ОписаниеЗапросаSQL.duration < ДлительностьЗапросовОт Тогда
			
			Продолжить;
		КонецЕсли;
		
		//ДанныеЗапроса = ДанныеЗапросаSQLВБазеПоТексту(ОписаниеЗапросаSQL.sql_text);		
		ДанныеЗапроса = ДанныеЗапросаSQLВБазеПоТексту(ОписаниеЗапросаSQL.query_text,, МодульRegExp);
		
		ДатаНачала = ОписаниеЗапросаSQL.start_time;
		ЗапросSQL = ДанныеЗапроса.ЗапросSQL;
		
		КлючЗаписи = КлючЗаписи_СобранныеТранзакции(ДатаНачала, СерверSQL, ОписаниеЗапросаSQL.session, ЗапросSQL);
		ЕстьЗаписи = Истина;
		Если КлючЗаписи.ID = Неопределено Тогда
			КлючЗаписи.ID = Новый УникальныйИдентификатор();
			ЕстьЗаписи = Ложь;
		КонецЕсли;

		НЗ_Запросы = РегистрыСведений.СобранныеТранзакцииSQL.СоздатьНаборЗаписей();
		НЗ_Запросы.Отбор.ДатаНачала.Установить(КлючЗаписи.ДатаНачала);
		НЗ_Запросы.Отбор.СерверSQL.Установить(КлючЗаписи.СерверSQL);
		НЗ_Запросы.Отбор.ID.Установить(КлючЗаписи.ID);
		
		Если ЕстьЗаписи Тогда
			НЗ_Запросы.Прочитать();
			Запись_Запросы = НЗ_Запросы[0];
		Иначе
			Запись_Запросы = НЗ_Запросы.Добавить();
			ЗаполнитьЗначенияСвойств(Запись_Запросы, КлючЗаписи);
		КонецЕсли;
		
		ЗаполнитьЗначенияСвойств(Запись_Запросы, ОписаниеЗапросаSQL);

		Запись_Запросы.ЗапросSQL = ЗапросSQL;
		Запись_Запросы.ДатаОбновления = ТекДата;
		
		НЗ_Запросы.ОбменДанными.Загрузка = Истина;
		НЗ_Запросы.Записать(Истина);
		
	КонецЦикла;

	МЗ = РегистрыСведений.ДатыСобранныхТранзакцийSQL.СоздатьМенеджерЗаписи();
	МЗ.СерверSQL = СерверSQL;
	МЗ.ДатаПоследнегоСбора = ТекДата;
	
	МЗ.Записать(Истина);

КонецПроцедуры

Функция КлючЗаписи_СобранныеТранзакции(ДатаНачала, СерверSQL, session, ЗапросSQL)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ДатаНачала", ДатаНачала);
	Запрос.УстановитьПараметр("СерверSQL", СерверSQL);
	Запрос.УстановитьПараметр("session", session);
	Запрос.УстановитьПараметр("ЗапросSQL", ЗапросSQL);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	СобранныеЗапросыSQL.ДатаНачала КАК ДатаНачала,
	|	СобранныеЗапросыSQL.СерверSQL КАК СерверSQL,
	|	СобранныеЗапросыSQL.ID КАК ID,
	|	СобранныеЗапросыSQL.session КАК session,
	|	СобранныеЗапросыSQL.ЗапросSQL КАК ЗапросSQL
	|ИЗ
	|	РегистрСведений.СобранныеТранзакцииSQL КАК СобранныеЗапросыSQL
	|ГДЕ
	|	СобранныеЗапросыSQL.ДатаНачала = &ДатаНачала
	|	И СобранныеЗапросыSQL.СерверSQL = &СерверSQL
	|	И СобранныеЗапросыSQL.session = &session
	|	И СобранныеЗапросыSQL.ЗапросSQL = &ЗапросSQL";
	
	КлючЗаписи = Новый Структура("ДатаНачала, СерверSQL, ID",
		ДатаНачала,
		СерверSQL
		);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		
		КлючЗаписи.ID = Выборка.ID;
		Возврат КлючЗаписи;
		
	КонецЦикла;
	
	Возврат КлючЗаписи;
	
КонецФункции

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ХэшТекстаЗапросаSQL(sql_text) Экспорт
	
	//// откат на старую версию
	//ХешированиеДанных = Новый ХешированиеДанных(ХешФункция.SHA512);
	ХешированиеДанных = Новый ХешированиеДанных(ХешФункция.SHA256);
	ХешированиеДанных.Добавить(sql_text);
	
	Возврат СтрЗаменить(ХешированиеДанных.ХешСумма, " ", "");
	
КонецФункции

Функция ВалидныйТекстаЗапросаSQL(Знач sql_text, МодульRegExp = Неопределено) Экспорт
	
	sql_text = СокрЛП(sql_text);
	
	sql_text = СтрЗаменить(sql_text, Символы.ПС, " ");
	sql_text = СтрЗаменить(sql_text, Символы.ПФ, " ");
	sql_text = СтрЗаменить(sql_text, Символы.Таб, " ");
	sql_text = СтрЗаменить(sql_text, Символы.ВТаб, " ");
	sql_text = СтрЗаменить(sql_text, Символы.НПП, " ");
	
	sql_text = СтрЗаменить(sql_text, Символ(13), " ");
	
	
	sql_text = СтрЗаменить(sql_text, "     ", " ");
	sql_text = СтрЗаменить(sql_text, "   ", " ");
	sql_text = СтрЗаменить(sql_text, "  ", " ");
	sql_text = СтрЗаменить(sql_text, "  ", " ");
	
	
	Если МодульRegExp = Неопределено Тогда
		МодульRegExp = МодульRegExpДляЗапроса();
	КонецЕсли;

	ЗаменаПеременныхФрагментов = "1";
	Префикс = "[!@!~=+]";
	
	МодульRegExp.IgnoreCase = Истина;
	МодульRegExp.Global = Истина;
	МодульRegExp.Pattern = "([^A-ZА-ЯЁ_0-9]|^)(?:[A-F0-9]+:[A-F0-9]+|0x[A-F0-9]+|[A-F0-9]+(?:-[A-F0-9]+)+-[A-F0-9]+|(#TT?)[_A-F0-9]+|[0-9]+)"; // для стирания констант и имен временных таблиц
	
	ЗаменаПеременныхФрагментов = Префикс + ЗаменаПеременныхФрагментов;
	sql_text = МодульRegExp.Заменить(sql_text, "$1$2" + ЗаменаПеременныхФрагментов);
	sql_text = СтрЗаменить(sql_text, Префикс, "");
	
	Если СтрНайти(sql_text, "BACKUP DATABASE") > 0 Тогда
		
		МодульRegExp.IgnoreCase = Истина;
		МодульRegExp.Global = Истина;
		МодульRegExp.Pattern = "(\'[^\s]+\')";
		
		КоллекцияРезультат = МодульRegExp.НайтиВхождения(sql_text);
		ЧислоВхождений = КоллекцияРезультат.Количество();
		Если ЧислоВхождений>0 Тогда 
			Для Каждого ОписаниеВхождения Из КоллекцияРезультат Цикл
				sql_text = СтрЗаменить(sql_text, ОписаниеВхождения.Value, "'...'");
			КонецЦикла;
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат sql_text;
	
КонецФункции

Функция ДанныеЗапросаSQLВБазеПоТексту(Знач ТекстЗапросаSQL, КешДанных = Неопределено, МодульRegExp = Неопределено) Экспорт
	
	РезультатРаботы = Новый Структура("sql_text_hash, ЗапросSQL", "", Неопределено);
	
	Если НЕ ЗначениеЗаполнено(ТекстЗапросаSQL) Тогда
		Возврат РезультатРаботы;
	КонецЕсли;
	
	sql_text = ВалидныйТекстаЗапросаSQL(ТекстЗапросаSQL, МодульRegExp);
	sql_text_hash = ХэшТекстаЗапросаSQL(sql_text);
	РезультатРаботы.Вставить("sql_text_hash", sql_text_hash);
	
	Если КешДанных <> Неопределено Тогда
		РезультатВКэше = КешДанных.Получить(sql_text_hash);
		Если РезультатВКэше <> Неопределено Тогда
			Возврат РезультатВКэше;
		КонецЕсли;
	КонецЕсли;
	
	ЗапросSQL = ЗапросSQLВБазе(sql_text_hash, sql_text);
	РезультатРаботы.Вставить("ЗапросSQL", ЗапросSQL);
	
	Если КешДанных <> Неопределено Тогда
		КешДанных.Вставить(sql_text_hash, РезультатРаботы);
	КонецЕсли;
	
	Возврат РезультатРаботы;
	
КонецФункции

Функция ЗапросSQLВБазе(sql_text_hash, sql_text)
	
	ЗапросSQL = Неопределено;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("sql_text_hash", sql_text_hash);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ЗапросыSQL.Ссылка КАК ЗапросSQL,
	|	ЗапросыSQL.sql_text_hash КАК sql_text_hash
	|ИЗ
	|	Справочник.ЗапросыSQL КАК ЗапросыSQL
	|ГДЕ
	//// откат на старую версию
	//|	ЗапросыSQL.sql_text_hash = &sql_text_hash";
	|	ЗапросыSQL.sql_text_hash256 = &sql_text_hash";
	
	РезультатЗапроса = Запрос.Выполнить();
	Если НЕ РезультатЗапроса.Пустой() Тогда
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		ЗапросSQL = Выборка.ЗапросSQL;
		Возврат ЗапросSQL;
	КонецЕсли;
	
	НачатьТранзакцию();
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("Справочник.ЗапросыSQL");
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	//// откат на старую версию
	//ЭлементБлокировки.УстановитьЗначение("sql_text_hash", sql_text_hash);
	ЭлементБлокировки.УстановитьЗначение("sql_text_hash256", sql_text_hash);
	Блокировка.Заблокировать();
	
	Если Запрос.Выполнить().Пустой() Тогда
		
		ОБ = Справочники.ЗапросыSQL.СоздатьЭлемент();
		
		//// откат на старую версию
		//ОБ.sql_text_hash = sql_text_hash;
		ОБ.sql_text_hash256 = sql_text_hash;
		ОБ.текстЗапросаSQL = sql_text;
		ОБ.Записать();
		
		ЗапросSQL = ОБ.Ссылка;
		
	КонецЕсли;
	
	ЗафиксироватьТранзакцию();
	
	Возврат ЗапросSQL;
	
КонецФункции

Функция МодульRegExpДляЗапроса()
	
	RegExpПараметры = Обработки._ирОболочкаРегВыражение.Создать();

	RegExpПараметры.IgnoreCase = Истина;
	RegExpПараметры.Global = Истина;
	RegExpПараметры.Pattern = "([^A-ZА-ЯЁ_0-9]|^)(?:[A-F0-9]+:[A-F0-9]+|0x[A-F0-9]+|[A-F0-9]+(?:-[A-F0-9]+)+-[A-F0-9]+|(#TT?)[_A-F0-9]+|[0-9]+)"; // для стирания констант и имен временных таблиц

	Возврат RegExpПараметры;
	
КонецФункции

#КонецОбласти


Процедура Регламент_СборСтатискиЗапросовSQL() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	НастройкиСбораДанныхSQL.СерверSQL КАК СерверSQL
	|ИЗ
	|	РегистрСведений.НастройкиСбораДанныхSQL КАК НастройкиСбораДанныхSQL
	|ГДЕ
	|	НастройкиСбораДанныхSQL.СобиратьСтатистикуЗапросов
	|	И НЕ НастройкиСбораДанныхSQL.СерверSQL.ПометкаУдаления";
	
	ВыборкаСерверов = Запрос.Выполнить().Выбрать();
	Пока ВыборкаСерверов.Следующий() Цикл
		СобратьДанныеОСтатистикеНаСервереSQL(ВыборкаСерверов);
	КонецЦикла;
	
КонецПроцедуры

Процедура СобратьДанныеОСтатистикеНаСервереSQL(ВыборкаСерверов)
	
	СохранятьПланыЗапросовSQL = Константы.СохранятьПланыЗапросовSQL.Получить();
	
	ДатаСбора = ТекущаяДатаСеанса();
	МодульRegExp = МодульRegExpДляЗапроса();
	
	ТЧ_SQL = РегистрыСведений.СтатистикаПоЗапросамSQL.СоздатьНаборЗаписей().ВыгрузитьКолонки();
	
	RecordSet = СтатистикаНаSQLСервере(ВыборкаСерверов.СерверSQL);
	
	Если НЕ РаботаСSQLСервером.ВВыборкеЕстьЗаписи(RecordSet) Тогда
		RecordSet.Close();
		Возврат;
	КонецЕсли;
	
	КэшДанных = ПолныйКэшЗапросов();
	//КэшДанныхПланов = ПолныйКэшПланов();

	Попытка
		ИменаПолей = "dbname,creation_time,last_execution_time,execution_count,total_worker_time,last_worker_time,min_worker_time,max_worker_time,plan_generation_num,total_physical_reads";
		ИменаПолей = ИменаПолей + ",min_physical_reads,max_physical_reads,total_logical_reads,min_logical_reads,max_logical_reads,total_logical_writes,min_logical_writes,max_logical_writes";
		ИменаПолей = ИменаПолей + ",total_elapsed_time,min_elapsed_time,max_elapsed_time,total_rows,last_rows,min_rows,max_rows,total_dop,last_dop,min_dop,max_dop";	
		
		Сч = 0;
		
		Пока РаботаСSQLСервером.СледующаяЗаписьВыборки(RecordSet) Цикл
			
			Сч = Сч + 1;
			
			//sql_text = RecordSet.Fields("text").Value;
			sql_text = RecordSet.Fields("query_text").Value;
			Если sql_text = null Тогда
				Продолжить;
			КонецЕсли;
			
			СтрокаТЧ = ТЧ_SQL.Добавить();
			ЗначенияПолей = РаботаСSQLСервером.ЗначениеПолейВыборки(RecordSet, ИменаПолей);
			ЗаполнитьЗначенияСвойств(СтрокаТЧ, ЗначенияПолей);
			
			СтрокаТЧ.ЗапросSQL = ДанныеЗапросаSQLВБазеПоТексту(sql_text, КэшДанных, МодульRegExp).ЗапросSQL;
			
			Попытка
				RecordSet.MoveNext();
			Исключение
				Прервать;
			КонецПопытки;
			
		КонецЦикла;
	
		RecordSet.Close();
	Исключение
		RecordSet.Close();
		ТекстОшибки = ОписаниеОшибки();
		ВызватьИсключение (ТекстОшибки);
	КонецПопытки;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТЧ_SQL", ТЧ_SQL);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	T.ЗапросSQL КАК ЗапросSQL,
	|	T.sql_plan_hash КАК sql_plan_hash,
	|	T.dbname КАК dbname,
	|	T.creation_time КАК creation_time,
	|	T.last_execution_time КАК last_execution_time,
	|	T.execution_count КАК execution_count,
	|	T.total_worker_time КАК total_worker_time,
	|	T.last_worker_time КАК last_worker_time,
	|	T.min_worker_time КАК min_worker_time,
	|	T.max_worker_time КАК max_worker_time,
	|	T.plan_generation_num КАК plan_generation_num,
	|	T.total_physical_reads КАК total_physical_reads,
	|	T.min_physical_reads КАК min_physical_reads,
	|	T.max_physical_reads КАК max_physical_reads,
	|	T.total_logical_reads КАК total_logical_reads,
	|	T.min_logical_reads КАК min_logical_reads,
	|	T.max_logical_reads КАК max_logical_reads,
	|	T.total_logical_writes КАК total_logical_writes,
	|	T.min_logical_writes КАК min_logical_writes,
	|	T.max_logical_writes КАК max_logical_writes,
	|	T.total_elapsed_time КАК total_elapsed_time,
	|	T.min_elapsed_time КАК min_elapsed_time,
	|	T.max_elapsed_time КАК max_elapsed_time,
	|	T.total_rows КАК total_rows,
	|	T.last_rows КАК last_rows,
	|	T.min_rows КАК min_rows,
	|	T.max_rows КАК max_rows,
	|	T.total_dop КАК total_dop,
	|	T.last_dop КАК last_dop,
	|	T.min_dop КАК min_dop,
	|	T.max_dop КАК max_dop
	|ПОМЕСТИТЬ ВТ_СтатистикаSQL
	|ИЗ
	|	&ТЧ_SQL КАК T
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ЗапросSQL
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_СтатистикаSQL.ЗапросSQL КАК ЗапросSQL,
	|	ВТ_СтатистикаSQL.dbname КАК dbname,
	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ВТ_СтатистикаSQL.sql_plan_hash) КАК ВариантовЗапроса,
	|	МИНИМУМ(ВТ_СтатистикаSQL.creation_time) КАК creation_time,
	|	СУММА(ВТ_СтатистикаSQL.plan_generation_num) КАК plan_generation_num,
	|	МАКСИМУМ(ВТ_СтатистикаSQL.last_execution_time) КАК last_execution_time,
	|	СУММА(ВТ_СтатистикаSQL.execution_count) КАК execution_count,
	|	СУММА(ВТ_СтатистикаSQL.total_worker_time) КАК total_worker_time,
	|	СУММА(ВТ_СтатистикаSQL.total_physical_reads) КАК total_physical_reads,
	|	СУММА(ВТ_СтатистикаSQL.total_logical_reads) КАК total_logical_reads,
	|	СУММА(ВТ_СтатистикаSQL.total_logical_writes) КАК total_logical_writes,
	|	СУММА(ВТ_СтатистикаSQL.total_elapsed_time) КАК total_elapsed_time,
	|	СУММА(ВТ_СтатистикаSQL.total_rows) КАК total_rows,
	|	СУММА(ВТ_СтатистикаSQL.total_dop) КАК total_dop,
	|	МАКСИМУМ(ВТ_СтатистикаSQL.last_worker_time) КАК last_worker_time,
	|	МАКСИМУМ(ВТ_СтатистикаSQL.last_rows) КАК last_rows,
	|	МАКСИМУМ(ВТ_СтатистикаSQL.last_dop) КАК last_dop,
	|	МИНИМУМ(ВТ_СтатистикаSQL.min_worker_time) КАК min_worker_time,
	|	МИНИМУМ(ВТ_СтатистикаSQL.min_physical_reads) КАК min_physical_reads,
	|	МИНИМУМ(ВТ_СтатистикаSQL.min_logical_reads) КАК min_logical_reads,
	|	МИНИМУМ(ВТ_СтатистикаSQL.min_logical_writes) КАК min_logical_writes,
	|	МИНИМУМ(ВТ_СтатистикаSQL.min_elapsed_time) КАК min_elapsed_time,
	|	МИНИМУМ(ВТ_СтатистикаSQL.min_rows) КАК min_rows,
	|	МИНИМУМ(ВТ_СтатистикаSQL.min_dop) КАК min_dop,
	|	МАКСИМУМ(ВТ_СтатистикаSQL.max_worker_time) КАК max_worker_time,
	|	МАКСИМУМ(ВТ_СтатистикаSQL.max_physical_reads) КАК max_physical_reads,
	|	МАКСИМУМ(ВТ_СтатистикаSQL.max_logical_reads) КАК max_logical_reads,
	|	МАКСИМУМ(ВТ_СтатистикаSQL.max_logical_writes) КАК max_logical_writes,
	|	МАКСИМУМ(ВТ_СтатистикаSQL.max_elapsed_time) КАК max_elapsed_time,
	|	МАКСИМУМ(ВТ_СтатистикаSQL.max_rows) КАК max_rows,
	|	МАКСИМУМ(ВТ_СтатистикаSQL.max_dop) КАК max_dop
	|ИЗ
	|	ВТ_СтатистикаSQL КАК ВТ_СтатистикаSQL
	|
	|СГРУППИРОВАТЬ ПО
	|	ВТ_СтатистикаSQL.ЗапросSQL,
	|	ВТ_СтатистикаSQL.dbname";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Сч = 0;
	КолВсего = Выборка.Количество();
	
	НачатьТранзакцию();
	
	Пока Выборка.Следующий() Цикл
		
		НЗ = РегистрыСведений.СтатистикаПоЗапросамSQL.СоздатьНаборЗаписей();
		НЗ.Отбор.СерверSQL.Установить(ВыборкаСерверов.СерверSQL);
		НЗ.Отбор.ДатаСбора.Установить(ДатаСбора);
		НЗ.Отбор.ЗапросSQL.Установить(Выборка.ЗапросSQL);
		НЗ.Отбор.dbname.Установить(Выборка.dbname);
		
		СтрокаНЗ = НЗ.Добавить();
		
		ЗаполнитьЗначенияСвойств(СтрокаНЗ, Выборка);
		
		СтрокаНЗ.СерверSQL		= ВыборкаСерверов.СерверSQL;
		СтрокаНЗ.ДатаСбора		= ДатаСбора;
		СтрокаНЗ.ЗапросSQL		= Выборка.ЗапросSQL;
		СтрокаНЗ.dbname			= Выборка.dbname;
		
		НЗ.ОбменДанными.Загрузка = Истина;
		НЗ.Записать(Ложь);
		
		Сч = Сч + 1;
		
		Если Сч % 200 = 0 Тогда
			ЗафиксироватьТранзакцию();
			НачатьТранзакцию();
		КонецЕсли;
		
	КонецЦикла;
	
	ЗафиксироватьТранзакцию();
	
	ОбновитьОбщиеДанныеОСтатистикеНаСервереSQL(ВыборкаСерверов.СерверSQL, ДатаСбора);
	
КонецПроцедуры

Процедура ОбновитьОбщиеДанныеОСтатистикеНаСервереSQL(СерверSQL, ДатаСбора) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("СерверSQL", СерверSQL);
	Запрос.УстановитьПараметр("ДатаСбора", ДатаСбора);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	СУММА(СтатистикаПоЗапросамSQL.total_elapsed_time) КАК total_elapsed_time,
	|	СУММА(СтатистикаПоЗапросамSQL.total_worker_time) КАК total_worker_time,
	|	СУММА(СтатистикаПоЗапросамSQL.total_physical_reads) КАК total_physical_reads,
	|	СУММА(СтатистикаПоЗапросамSQL.total_logical_reads) КАК total_logical_reads,
	|	СУММА(СтатистикаПоЗапросамSQL.total_logical_writes) КАК total_logical_writes,
	|	СтатистикаПоЗапросамSQL.СерверSQL КАК СерверSQL,
	|	СтатистикаПоЗапросамSQL.ДатаСбора КАК ДатаСбора
	|ИЗ
	|	РегистрСведений.СтатистикаПоЗапросамSQL КАК СтатистикаПоЗапросамSQL
	|ГДЕ
	|	СтатистикаПоЗапросамSQL.СерверSQL = &СерверSQL
	|	И СтатистикаПоЗапросамSQL.ДатаСбора = &ДатаСбора
	|
	|СГРУППИРОВАТЬ ПО
	|	СтатистикаПоЗапросамSQL.ДатаСбора,
	|	СтатистикаПоЗапросамSQL.СерверSQL";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		НЗ = РегистрыСведений.СтатистикаПоЗапросамSQLОбщиеДанные.СоздатьНаборЗаписей();
		НЗ.Отбор.СерверSQL.Установить(Выборка.СерверSQL);
		НЗ.Отбор.ДатаСбора.Установить(Выборка.ДатаСбора);
		
		СтрокаНЗ = НЗ.Добавить();
		
		ЗаполнитьЗначенияСвойств(СтрокаНЗ, Выборка);
		
		НЗ.Записать(Истина);
		
	КонецЦикла;
	
КонецПроцедуры


Функция ПолныйКэшЗапросов()
	
	КэшДанных = Новый Соответствие;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	//// Откат на старую версию
	//|	ЗапросыSQL.sql_text_hash КАК sql_text_hash,
	|	ЗапросыSQL.sql_text_hash256 КАК sql_text_hash,
	|	ЗапросыSQL.Ссылка КАК ЗапросSQL
	|ИЗ
	|	Справочник.ЗапросыSQL КАК ЗапросыSQL";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		СтрокаКэша = Новый Структура("sql_text_hash, ЗапросSQL", Выборка.sql_text_hash, Выборка.ЗапросSQL);
		КэшДанных.Вставить(Выборка.sql_text_hash, СтрокаКэша);
	КонецЦикла;
	
	Возврат КэшДанных;
	
КонецФункции

Функция СтатистикаНаSQLСервере(СерверSQL) Экспорт
	
	ЧасовПросматривать = Час(ТекущаяДатаСеанса())-9;
	
	ТекстЗапроса_SQL =
	"select top 10000000
	//|	qp.query_plan,
	|	'' as query_plan,
	|	st.text,
	|	case when sql_handle IS NULL
	|		then ' '
	|	else 
	|		substring(st.text,
	|			(qs.statement_start_offset+2)/2, 
	|			(case 
	|				when qs.statement_end_offset = -1 then 
	|					100000 
	|				else 
	|					qs.statement_end_offset  
	|				end
	|			- qs.statement_start_offset
	|			)/2 + 1
	|		)
	|	end as query_text,
	|	ISNULL(st.dbid,CONVERT(SMALLINT,att.value)) as dbid,
	|	dtb.name as dbname,
	|	qs.creation_time,
	|	qs.last_execution_time,
	|	qs.execution_count,
	|	qs.total_worker_time,
	|	qs.last_worker_time,
	|	qs.min_worker_time,
	|	qs.max_worker_time,
	|	qs.plan_generation_num,
	|	qs.total_physical_reads,
	|	qs.min_physical_reads,
	|	qs.max_physical_reads,
	|	qs.total_logical_reads,
	|	qs.min_logical_reads,
	|	qs.max_logical_reads,
	|	qs.total_logical_writes,
	|	qs.min_logical_writes,
	|	qs.max_logical_writes,
	|	qs.total_elapsed_time,
	|	qs.min_elapsed_time,
	|	qs.max_elapsed_time,
	|	qs.total_rows,
	|	qs.last_rows,
	|	qs.min_rows,
	|	qs.max_rows,
	|	qs.total_dop,
	|	qs.last_dop,
	|	qs.min_dop,
	|	qs.max_dop
	|FROM sys.dm_exec_query_stats qs
	|	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
	//|	OUTER APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
	|	LEFT OUTER JOIN(
	|		SELECT DISTINCT
	|			qs.plan_handle,
	|			att.value
	|		FROM sys.dm_exec_query_stats qs
	|		CROSS APPLY sys.dm_exec_plan_attributes(qs.plan_handle) att
	|		WHERE
	|			att.attribute='dbid') as att
	|	ON
	|		qs.plan_handle = att.plan_handle
	|	LEFT OUTER JOIN sys.databases as dtb
	|		on ISNULL(st.dbid,CONVERT(SMALLINT,att.value)) = dtb.database_id
	|where
	|	qs.last_execution_time > (CURRENT_TIMESTAMP - '" + ЧасовПросматривать + ":00:00.000')
	|ORDER BY
	|	qs.total_worker_time desc";
	
	Connection = РаботаСSQLСервером.СоединениеССерверомSQL(СерверSQL,, 1200);
	RecordSet = РаботаСSQLСервером.РезультатЗапросаSQL(Connection, ТекстЗапроса_SQL, 1200);
	
	Возврат RecordSet;
	
	//ТЧ_SQL = РаботаСSQLСервером.ВсеЗаписиВыборки(RecordSet);
	//РаботаСSQLСервером.ЗакрытьСоединение(Connection);
	//Возврат ТЧ_SQL;
	
КонецФункции


Функция СтатистикаОжиданийSQLСервера(СерверSQL)
	
	ТекстЗапроса_SQL =
	"SELECT
	|	[wait_type],
	|	CAST([wait_time_ms] / 1000.0 AS DECIMAL (17,0)) AS [wait_time_s],
	|	CAST([signal_wait_time_ms] / 1000.0 AS DECIMAL (17,0)) AS [signal_wait_time_s],
	|	[waiting_tasks_count] AS [waiting_tasks_count]
	|
	|	FROM sys.dm_os_wait_stats
	|	WHERE [wait_type] NOT IN (
	|        N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR',
	|        N'BROKER_TASK_STOP', N'BROKER_TO_FLUSH',
	|        N'BROKER_TRANSMITTER', N'CHECKPOINT_QUEUE',
	|        N'CHKPT', N'CLR_AUTO_EVENT',
	|        N'CLR_MANUAL_EVENT', N'CLR_SEMAPHORE',
	|        
	|        -- Maybe uncomment these four if you have mirroring issues
	|        N'DBMIRROR_DBM_EVENT', N'DBMIRROR_EVENTS_QUEUE',
	|        N'DBMIRROR_WORKER_QUEUE', N'DBMIRRORING_CMD',
	| 
	|        N'DIRTY_PAGE_POLL', N'DISPATCHER_QUEUE_SEMAPHORE',
	|        N'EXECSYNC', N'FSAGENT',
	|        N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
	| 
	|        -- Maybe uncomment these six if you have AG issues
	|        N'HADR_CLUSAPI_CALL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
	|        N'HADR_LOGCAPTURE_WAIT', N'HADR_NOTIFICATION_DEQUEUE',
	|        N'HADR_TIMER_TASK', N'HADR_WORK_QUEUE',
	| 
	|        N'KSOURCE_WAKEUP', N'LAZYWRITER_SLEEP',
	|        N'LOGMGR_QUEUE', N'MEMORY_ALLOCATION_EXT',
	|        N'ONDEMAND_TASK_QUEUE',
	|        N'PREEMPTIVE_XE_GETTARGETSTATE',
	|        N'PWAIT_ALL_COMPONENTS_INITIALIZED',
	|        N'PWAIT_DIRECTLOGCONSUMER_GETNEXT',
	|        N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP', N'QDS_ASYNC_QUEUE',
	|        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
	|        N'QDS_SHUTDOWN_QUEUE', N'REDO_THREAD_PENDING_WORK',
	|        N'REQUEST_FOR_DEADLOCK_SEARCH', N'RESOURCE_QUEUE',
	|        N'SERVER_IDLE_CHECK', N'SLEEP_BPOOL_FLUSH',
	|        N'SLEEP_DBSTARTUP', N'SLEEP_DCOMSTARTUP',
	|        N'SLEEP_MASTERDBREADY', N'SLEEP_MASTERMDREADY',
	|        N'SLEEP_MASTERUPGRADED', N'SLEEP_MSDBSTARTUP',
	|        N'SLEEP_SYSTEMTASK', N'SLEEP_TASK',
	|        N'SLEEP_TEMPDBSTARTUP', N'SNI_HTTP_ACCEPT',
	|        N'SP_SERVER_DIAGNOSTICS_SLEEP', N'SQLTRACE_BUFFER_FLUSH',
	|        N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
	|        N'SQLTRACE_WAIT_ENTRIES', N'WAIT_FOR_RESULTS',
	|        N'WAITFOR', N'WAITFOR_TASKSHUTDOWN',
	|        N'WAIT_XTP_RECOVERY',
	|        N'WAIT_XTP_HOST_WAIT', N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',
	|        N'WAIT_XTP_CKPT_CLOSE', N'XE_DISPATCHER_JOIN',
	|        N'XE_DISPATCHER_WAIT', N'XE_TIMER_EVENT')
	|	AND [waiting_tasks_count] > 0
	|ORDER BY
	|	[wait_time_ms] desc";
	
	Connection = РаботаСSQLСервером.СоединениеССерверомSQL(СерверSQL,, 60);
	RecordSet = РаботаСSQLСервером.РезультатЗапросаSQL(Connection, ТекстЗапроса_SQL, 60);
	
	ТЧ_SQL = РаботаСSQLСервером.ВсеЗаписиВыборки(RecordSet);
	РаботаСSQLСервером.ЗакрытьСоединение(Connection);
	
	Возврат ТЧ_SQL;
	
КонецФункции


Процедура Регламент_СборСтатискиОжиданийSQL() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	НастройкиСбораДанныхSQL.СерверSQL КАК СерверSQL
	|ИЗ
	|	РегистрСведений.НастройкиСбораДанныхSQL КАК НастройкиСбораДанныхSQL
	|ГДЕ
	|	НастройкиСбораДанныхSQL.СобиратьСтатистикуОжиданий
	|	И НЕ НастройкиСбораДанныхSQL.СерверSQL.ПометкаУдаления";
	
	ВыборкаСерверов = Запрос.Выполнить().Выбрать();
	Пока ВыборкаСерверов.Следующий() Цикл
		СобратьДанныеОСтатистикеОжиданийНаСервереSQL(ВыборкаСерверов.СерверSQL);
	КонецЦикла;
	
КонецПроцедуры

Процедура СобратьДанныеОСтатистикеОжиданийНаСервереSQL(СерверSQL)
	
	ДатаСбора = ТекущаяДатаСеанса();
	ТЧ_Ожиданий = СтатистикаОжиданийSQLСервера(СерверSQL);
	
	НачатьТранзакцию();
	Попытка
		
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.КэшСтатистикаПоОжиданиямSQL");
		ЭлементБлокировки.УстановитьЗначение("СерверSQL", СерверSQL);
		ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
		Блокировка.Заблокировать();

		ЗаписатьСобранныеДанныеОСтатистикеОжиданийНаСервереSQL(СерверSQL, ТЧ_Ожиданий, ДатаСбора);
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ВызватьИсключение (ТекстОшибки);
	КонецПопытки;
	
КонецПроцедуры

Процедура ЗаписатьСобранныеДанныеОСтатистикеОжиданийНаСервереSQL(СерверSQL, ТЧ_Ожиданий, ДатаСбора)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("СерверSQL", СерверSQL);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	КэшСтатистикаПоОжиданиямSQL.СерверSQL КАК СерверSQL,
	|	КэшСтатистикаПоОжиданиямSQL.wait_type КАК wait_type,
	|	КэшСтатистикаПоОжиданиямSQL.wait_time_s КАК wait_time_s,
	|	КэшСтатистикаПоОжиданиямSQL.signal_wait_time_s КАК signal_wait_time_s,
	|	КэшСтатистикаПоОжиданиямSQL.waiting_tasks_count КАК waiting_tasks_count,
	|	КэшСтатистикаПоОжиданиямSQL.ДатаСбора КАК ДатаСбора
	|ИЗ
	|	РегистрСведений.КэшСтатистикаПоОжиданиямSQL КАК КэшСтатистикаПоОжиданиямSQL
	|ГДЕ
	|	КэшСтатистикаПоОжиданиямSQL.СерверSQL = &СерверSQL";
	
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		ЗаписатьСтатистикуОжиданийВКэш(СерверSQL, ТЧ_Ожиданий, ДатаСбора);
		Возврат;
	КонецЕсли;
	
	ТЧ_Ожиданий_Кэш = РезультатЗапроса.Выгрузить();
	duration_s = (ДатаСбора - ТЧ_Ожиданий_Кэш[0].ДатаСбора);
	
	Если duration_s <= 0 Тогда
		Возврат;
	КонецЕсли;
	
	Если duration_s > 36000 Тогда
		ЗаписатьСтатистикуОжиданийВКэш(СерверSQL, ТЧ_Ожиданий, ДатаСбора);
		Возврат;
	КонецЕсли;
	
	НЗ = РегистрыСведений.СтатистикаПоОжиданиямSQL.СоздатьНаборЗаписей();
	НЗ.Отбор.СерверSQL.Установить(СерверSQL);
	НЗ.Отбор.ДатаСбора.Установить(ДатаСбора);
	
	Для Каждого СтрокаОжиданий ИЗ ТЧ_Ожиданий Цикл
		
		Если НЕ ЗначениеЗаполнено(СтрокаОжиданий.wait_time_s) Тогда
			Продолжить;
		КонецЕсли;
		
		wait_type = РаботаСSQLСерверомПовтИсп.ВидыОжиданийSQLПоИмени(СтрокаОжиданий.wait_type);
		
		СтрокиВКэше = ТЧ_Ожиданий_Кэш.НайтиСтроки(Новый Структура("wait_type", wait_type));
		Если СтрокиВКэше.Количество() = 0 Тогда
			СтрокаВКэше = Неопределено;
		Иначе
			СтрокаВКэше = СтрокиВКэше[0];
		КонецЕсли;
		
		НоваяСтрока = НЗ.Добавить();
		НоваяСтрока.СерверSQL = СерверSQL;
		НоваяСтрока.ДатаСбора = ДатаСбора;
		НоваяСтрока.wait_type = wait_type;
		
		НоваяСтрока.duration_s = duration_s;
		
		НоваяСтрока.wait_time_s			= ?(ЗначениеЗаполнено(СтрокаОжиданий.wait_time_s),			СтрокаОжиданий.wait_time_s, 0);
		НоваяСтрока.signal_wait_time_s	= ?(ЗначениеЗаполнено(СтрокаОжиданий.signal_wait_time_s),	СтрокаОжиданий.signal_wait_time_s, 0);
		НоваяСтрока.waiting_tasks_count	= ?(ЗначениеЗаполнено(СтрокаОжиданий.waiting_tasks_count),	СтрокаОжиданий.waiting_tasks_count, 0);
		
		Если СтрокаВКэше <> Неопределено Тогда
			НоваяСтрока.wait_time_s			= НоваяСтрока.wait_time_s			- ?(ЗначениеЗаполнено(СтрокаВКэше.wait_time_s),			СтрокаВКэше.wait_time_s, 0);
			НоваяСтрока.signal_wait_time_s	= НоваяСтрока.signal_wait_time_s	- ?(ЗначениеЗаполнено(СтрокаВКэше.signal_wait_time_s),	СтрокаВКэше.signal_wait_time_s, 0);
			НоваяСтрока.waiting_tasks_count	= НоваяСтрока.waiting_tasks_count	- ?(ЗначениеЗаполнено(СтрокаВКэше.waiting_tasks_count),	СтрокаВКэше.waiting_tasks_count, 0);
		КонецЕсли;
		
	КонецЦикла;
	
	НЗ.Записать(Ложь);
	
	ЗаписатьСтатистикуОжиданийВКэш(СерверSQL, ТЧ_Ожиданий, ДатаСбора);
	
КонецПроцедуры

Процедура ЗаписатьСтатистикуОжиданийВКэш(СерверSQL, ТЧ_Ожиданий, ДатаСбора)
	
	НЗ = РегистрыСведений.КэшСтатистикаПоОжиданиямSQL.СоздатьНаборЗаписей();
	НЗ.Отбор.СерверSQL.Установить(СерверSQL);
	
	Для Каждого СтрокаОжиданий ИЗ ТЧ_Ожиданий Цикл
		
		Если НЕ ЗначениеЗаполнено(СтрокаОжиданий.wait_time_s) Тогда
			Продолжить;
		КонецЕсли;

		wait_type = РаботаСSQLСерверомПовтИсп.ВидыОжиданийSQLПоИмени(СтрокаОжиданий.wait_type);
		
		НоваяСтрока = НЗ.Добавить();
		НоваяСтрока.СерверSQL = СерверSQL;
		НоваяСтрока.wait_type = wait_type;
		
		НоваяСтрока.ДатаСбора			= ДатаСбора;
		НоваяСтрока.wait_time_s			= СтрокаОжиданий.wait_time_s;
		НоваяСтрока.signal_wait_time_s	= СтрокаОжиданий.signal_wait_time_s;
		НоваяСтрока.waiting_tasks_count	= СтрокаОжиданий.waiting_tasks_count;
		
	КонецЦикла;
	
	НЗ.Записать(Истина);
	
КонецПроцедуры

#Область ОповещенияОДлительныхЗапросах

Процедура ОповещениеОДлительныхЗапросахSQL() Экспорт
	
	ГруппаПолучателей = Константы.ГруппаПолучателейПисемОДлиттельныхЗапросов.Получить();
	Если НЕ ЗначениеЗаполнено(ГруппаПолучателей) Тогда
		ВызватьИсключение "Не заполнена группа получателей рассылки";
	КонецЕсли;
	
	ДлительностьЗапросов = Константы.ДлительностьЗапросовСОповещениями.Получить();
	ДлительностьЗапросов = Макс(ДлительностьЗапросов, 20);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ДатаОрганичения", ТекущаяДата()-ДлительностьЗапросов*10-14400);
	Запрос.УстановитьПараметр("ДлительностьЗапросов", ДлительностьЗапросов);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	СобранныеЗапросыSQL.ДатаНачала КАК ДатаНачала,
	|	СобранныеЗапросыSQL.СерверSQL КАК СерверSQL,
	|	СобранныеЗапросыSQL.ID КАК ID,
	|	СобранныеЗапросыSQL.session КАК session,
	|	СобранныеЗапросыSQL.status КАК status,
	|	СобранныеЗапросыSQL.commad КАК commad,
	|	СобранныеЗапросыSQL.CPU КАК CPU,
	|	СобранныеЗапросыSQL.duration КАК duration,
	|	СобранныеЗапросыSQL.ЗапросSQL КАК ЗапросSQL,
	|	СобранныеЗапросыSQL.dbname КАК dbname,
	|	СобранныеЗапросыSQL.dbid КАК dbid,
	|	СобранныеЗапросыSQL.ДатаОбновления КАК ДатаОбновления
	|ПОМЕСТИТЬ ВТ_ДолгиеЗапросы
	|ИЗ
	|	РегистрСведений.СобранныеЗапросыSQL КАК СобранныеЗапросыSQL
	|ГДЕ
	|	СобранныеЗапросыSQL.ДатаНачала > &ДатаОрганичения
	|	И СобранныеЗапросыSQL.duration > &ДлительностьЗапросов
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ДолгиеЗапросы.ДатаНачала КАК ДатаНачала,
	|	ВТ_ДолгиеЗапросы.СерверSQL КАК СерверSQL,
	|	ВТ_ДолгиеЗапросы.ID КАК ID,
	|	ВТ_ДолгиеЗапросы.session КАК session,
	|	ВТ_ДолгиеЗапросы.status КАК status,
	|	ВТ_ДолгиеЗапросы.commad КАК commad,
	|	ВТ_ДолгиеЗапросы.CPU КАК CPU,
	|	ВТ_ДолгиеЗапросы.duration КАК duration,
	|	ВТ_ДолгиеЗапросы.ЗапросSQL КАК ЗапросSQL,
	|	ВТ_ДолгиеЗапросы.dbname КАК dbname,
	|	ВТ_ДолгиеЗапросы.dbid КАК dbid,
	|	ВТ_ДолгиеЗапросы.ДатаОбновления КАК ДатаОбновления
	|ИЗ
	|	ВТ_ДолгиеЗапросы КАК ВТ_ДолгиеЗапросы
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ДатыСобранныхЗапросовSQL КАК ДатыСобранныхЗапросовSQL
	|		ПО ВТ_ДолгиеЗапросы.ДатаОбновления = ДатыСобранныхЗапросовSQL.ДатаПоследнегоСбора
	|			И ВТ_ДолгиеЗапросы.СерверSQL = ДатыСобранныхЗапросовSQL.СерверSQL
	|ГДЕ
	|	(ВТ_ДолгиеЗапросы.ЗапросSQL = ЗНАЧЕНИЕ(Справочник.ЗапросыSQL.ПустаяСсылка)
	|			ИЛИ НЕ ВТ_ДолгиеЗапросы.ЗапросSQL.Игнорирорвать)";
	
	// Тут только не завершенные запросы!
	//		Услови соединения: "ДатыСобранныхЗапросовSQL"
	
	РезальтатЗапроса = Запрос.Выполнить();
	
	Если НЕ РезальтатЗапроса.Пустой() Тогда
		
		СформироватьПисьмоОДлительныхЗапросахSQL(ГруппаПолучателей, РезальтатЗапроса);
		
	КонецЕсли;
	
КонецПроцедуры

Процедура СформироватьПисьмоОДлительныхЗапросахSQL(ГруппаПолучателей, РезальтатЗапроса)
	
	ЭтоРассылкаЛинк = Ложь;
	
	СписокПолучателей = Новый СписокЗначений;
	СписокПолучателейКопии = Новый СписокЗначений;

	Справочники.ГруппыПолучателейРассылок.ЗаполнитьМассивАдресатовРассылки(ГруппаПолучателей,	ЭтоРассылкаЛинк,	"Получатели",	СписокПолучателей,		Ложь,	Ложь,	Истина);
	Справочники.ГруппыПолучателейРассылок.ЗаполнитьМассивАдресатовРассылки(ГруппаПолучателей,	ЭтоРассылкаЛинк,	"Копии",		СписокПолучателейКопии, Ложь,	Ложь,	Истина);
	
	Тема = "Обнаружены долгие запросы на серверах SQL";
	ТекстСообщенияTG = "Обнаружены долгие запросы SQL:";
	
	мТекстПисьма =
	"<!DOCTYPE html>
	|<html lang=""ru"">
	|<head>
	|<meta charset=""UTF-8"">
	|<style>
	|td{border: 1px solid black;text-align: center;}
	|table{border-collapse: collapse;}
	|</style>
	|</head>
	|<body>
	|";
	
	мТекстПисьма = мТекстПисьма + "
	|<p>Недобрый день!</p>
	|<p>Обнаружены долгие запросы на серверах SQL!</p>";
	
	СтильТД		= "style='background: #365F91; text-align: left; border-width: 1px; padding: 1px 2px; border-style: solid; border-color: black;'";
	СтильШрифт	= "style='font-size:9.0pt;font-family:Arial;color:white'";
	СтильТДлево = "style='background: #FFFFFF; text-align:  left; border: 1px solid #000000; padding: 1px 2px;'>";
	СтильТДправ = "style='background: #FFFFFF; text-align: right; border: 1px solid #000000; padding: 1px 2px;'>";
	СтильТДШапка = СтильТД + "><b " + СтильШрифт + ">";
	
	ТекстТаблицыHTML = "
	| <table style='border-collapse: collapse; font-family: Arial; font-size: 10pt;'>";
	
	ТекстТаблицыHTML = ТекстТаблицыHTML + "
	|	<tr>
	|		<td " + СтильТДШапка + "ДатаНачала" + "</td>
	|		<td " + СтильТДШапка + "СерверSQL" + "</td>
	|		<td " + СтильТДШапка + "duration" + "</td>
	|		<td " + СтильТДШапка + "dbname" + "</td>
	|		<td " + СтильТДШапка + "commad" + "</td>
	|		<td " + СтильТДШапка + "session" + "</td>
	|		<td " + СтильТДШапка + "ЗапросSQL" + "</td>
	|	</tr>";
	
	ШаблонСтрокиСообщенияTG = "%1/%2: %3 с. (%4)";
	
	Выборка = РезальтатЗапроса.Выбрать();
	Пока Выборка.Следующий() Цикл
		
		ТекстСообщенияTG = ТекстСообщенияTG
			+ Символы.ПС
			+ СтрШаблон(ШаблонСтрокиСообщенияTG,
				Выборка.СерверSQL,
				Выборка.dbname,
				Выборка.duration,
				Выборка.session
			);
		
		ТекстТаблицыHTML = ТекстТаблицыHTML + "
		|	<tr>
		|		<td " + СтильТДлево + Выборка.ДатаНачала + "</td>
		|		<td " + СтильТДлево + Выборка.СерверSQL + "</td>
		|		<td " + СтильТДлево + Выборка.duration + "</td>
		|		<td " + СтильТДлево + Выборка.dbname + "</td>
		|		<td " + СтильТДлево + Выборка.commad + "</td>
		|		<td " + СтильТДлево + Выборка.session + "</td>
		|		<td " + СтильТДлево + Выборка.ЗапросSQL + "</td>
		|	</tr>";
		
	КонецЦикла;
	
	ТекстТаблицыHTML = ТекстТаблицыHTML + "
	|</table>";
	
	мТекстПисьма = мТекстПисьма + "
	|" + ТекстТаблицыHTML;
	
	
	мТекстПисьма = мТекстПисьма + "
	|<p>С уважением, <br>1C Robot</p>";
	
	мТекстПисьма = мТекстПисьма + "
	|
	|</body>
	|</html>";
	
	Сообщение = Новый ИнтернетПочтовоеСообщение;
	
	Сообщение.Отправитель.Адрес = "1crobot@lancetpharm.ru";
	
	Сообщение.Тема = Тема;
	
	Текст = Сообщение.Тексты.Добавить();
	Текст.ТипТекста = ТипТекстаПочтовогоСообщения.HTML;
	Текст.Текст = мТекстПисьма;
	
	Для Каждого ОписаниеАдреса Из СписокПолучателей Цикл
		Сообщение.Получатели.Добавить(ОписаниеАдреса.Значение);
	КонецЦикла;

	Для Каждого ОписаниеАдреса Из СписокПолучателейКопии Цикл
		Сообщение.Копии.Добавить(ОписаниеАдреса.Значение);
	КонецЦикла;
	
	РегистрыСведений.УС_ОчередьПочта.СоздатьЗаписьИзСообщения(Сообщение);
	
	ИнтеграцияСTelegram.ОтправитьСообщениеГруппе(ГруппаПолучателей, ТекстСообщенияTG);
	
КонецПроцедуры

#КонецОбласти

#Область ОповещенияОДлительныхТранзакциях

Процедура ОповещениеОДлительныхТранзакцияхSQL() Экспорт
	
	ГруппаПолучателей = Константы.ГруппаПолучателейПисемОДлиттельныхЗапросов.Получить();
	Если НЕ ЗначениеЗаполнено(ГруппаПолучателей) Тогда
		ВызватьИсключение "Не заполнена группа получателей рассылки";
	КонецЕсли;
	
	ДлительностьЗапросов = Константы.ДлительностьЗапросовСОповещениями.Получить();
	ДлительностьЗапросов = Макс(ДлительностьЗапросов, 20);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ДатаОрганичения",( ТекущаяДата()-ДлительностьЗапросов*10-14400));
	Запрос.УстановитьПараметр("ДлительностьЗапросов", ДлительностьЗапросов);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	СобранныеТранзакцииSQL.ДатаНачала КАК ДатаНачала,
	|	СобранныеТранзакцииSQL.СерверSQL КАК СерверSQL,
	|	СобранныеТранзакцииSQL.ID КАК ID,
	|	СобранныеТранзакцииSQL.session КАК session,
	|	СобранныеТранзакцииSQL.state КАК state,
	|	СобранныеТранзакцииSQL.duration КАК duration,
	|	СобранныеТранзакцииSQL.ЗапросSQL КАК ЗапросSQL,
	|	СобранныеТранзакцииSQL.dbname КАК dbname,
	|	СобранныеТранзакцииSQL.dbid КАК dbid,
	|	СобранныеТранзакцииSQL.ДатаОбновления КАК ДатаОбновления
	|ПОМЕСТИТЬ ВТ_ДолгиеТранзакции
	|ИЗ
	|	РегистрСведений.СобранныеТранзакцииSQL КАК СобранныеТранзакцииSQL
	|ГДЕ
	|	СобранныеТранзакцииSQL.ДатаНачала > &ДатаОрганичения
	|	И СобранныеТранзакцииSQL.duration > &ДлительностьЗапросов
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ДолгиеТранзакции.ДатаНачала КАК ДатаНачала,
	|	ВТ_ДолгиеТранзакции.СерверSQL КАК СерверSQL,
	|	ВТ_ДолгиеТранзакции.ID КАК ID,
	|	ВТ_ДолгиеТранзакции.session КАК session,
	|	ВТ_ДолгиеТранзакции.state КАК state,
	|	ВТ_ДолгиеТранзакции.duration КАК duration,
	|	ВТ_ДолгиеТранзакции.ЗапросSQL КАК ЗапросSQL,
	|	ВТ_ДолгиеТранзакции.dbname КАК dbname,
	|	ВТ_ДолгиеТранзакции.dbid КАК dbid,
	|	ВТ_ДолгиеТранзакции.ДатаОбновления КАК ДатаОбновления
	|ИЗ
	|	ВТ_ДолгиеТранзакции КАК ВТ_ДолгиеТранзакции
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ДатыСобранныхТранзакцийSQL КАК ДатыСобранныхТранзакцийSQL
	|		ПО ВТ_ДолгиеТранзакции.ДатаОбновления = ДатыСобранныхТранзакцийSQL.ДатаПоследнегоСбора
	|			И ВТ_ДолгиеТранзакции.СерверSQL = ДатыСобранныхТранзакцийSQL.СерверSQL
	|ГДЕ
	|	(ВТ_ДолгиеТранзакции.ЗапросSQL = ЗНАЧЕНИЕ(Справочник.ЗапросыSQL.ПустаяСсылка)
	|			ИЛИ НЕ ВТ_ДолгиеТранзакции.ЗапросSQL.Игнорирорвать)";
	
	// Тут только не завершенные запросы!
	//		Услови соединения: "ДатыСобранныхТранзакцийSQL"
	
	РезальтатЗапроса = Запрос.Выполнить();
	
	Если НЕ РезальтатЗапроса.Пустой() Тогда
		
		СформироватьПисьмоОДлительныхТранзакцияхSQL(ГруппаПолучателей, РезальтатЗапроса);
		
	КонецЕсли;
	
КонецПроцедуры

Процедура СформироватьПисьмоОДлительныхТранзакцияхSQL(ГруппаПолучателей, РезальтатЗапроса)
	
	ЭтоРассылкаЛинк = Ложь;
	
	СписокПолучателей = Новый СписокЗначений;
	СписокПолучателейКопии = Новый СписокЗначений;

	Справочники.ГруппыПолучателейРассылок.ЗаполнитьМассивАдресатовРассылки(ГруппаПолучателей,	ЭтоРассылкаЛинк,	"Получатели",	СписокПолучателей,		Ложь,	Ложь,	Истина);
	Справочники.ГруппыПолучателейРассылок.ЗаполнитьМассивАдресатовРассылки(ГруппаПолучателей,	ЭтоРассылкаЛинк,	"Копии",		СписокПолучателейКопии, Ложь,	Ложь,	Истина);
	
	Тема = "Обнаружены долгие транзакции на серверах SQL";
	ТекстСообщенияTG = "Обнаружены долгие транзакции SQL:";
	
	мТекстПисьма =
	"<!DOCTYPE html>
	|<html lang=""ru"">
	|<head>
	|<meta charset=""UTF-8"">
	|<style>
	|td{border: 1px solid black;text-align: center;}
	|table{border-collapse: collapse;}
	|</style>
	|</head>
	|<body>
	|";
	
	мТекстПисьма = мТекстПисьма + "
	|<p>Недобрый день!</p>
	|<p>Обнаружены долгие транзакции на серверах SQL!</p>";
	
	СтильТД		= "style='background: #365F91; text-align: left; border-width: 1px; padding: 1px 2px; border-style: solid; border-color: black;'";
	СтильШрифт	= "style='font-size:9.0pt;font-family:Arial;color:white'";
	СтильТДлево = "style='background: #FFFFFF; text-align:  left; border: 1px solid #000000; padding: 1px 2px;'>";
	СтильТДправ = "style='background: #FFFFFF; text-align: right; border: 1px solid #000000; padding: 1px 2px;'>";
	СтильТДШапка = СтильТД + "><b " + СтильШрифт + ">";
	
	ТекстТаблицыHTML = "
	| <table style='border-collapse: collapse; font-family: Arial; font-size: 10pt;'>";
	
	ТекстТаблицыHTML = ТекстТаблицыHTML + "
	|	<tr>
	|		<td " + СтильТДШапка + "ДатаНачала" + "</td>
	|		<td " + СтильТДШапка + "СерверSQL" + "</td>
	|		<td " + СтильТДШапка + "duration" + "</td>
	|		<td " + СтильТДШапка + "dbname" + "</td>
	|		<td " + СтильТДШапка + "state" + "</td>
	|		<td " + СтильТДШапка + "session" + "</td>
	|		<td " + СтильТДШапка + "ЗапросSQL" + "</td>
	|	</tr>";
	
	ШаблонСтрокиСообщенияTG = "%1/%2: %3 с. (%4)";
	
	Выборка = РезальтатЗапроса.Выбрать();
	Пока Выборка.Следующий() Цикл
		
		ТекстСообщенияTG = ТекстСообщенияTG
			+ Символы.ПС
			+ СтрШаблон(ШаблонСтрокиСообщенияTG,
				Выборка.СерверSQL,
				Выборка.dbname,
				Выборка.duration,
				Выборка.session
			);
			
		ТекстТаблицыHTML = ТекстТаблицыHTML + "
		|	<tr>
		|		<td " + СтильТДлево + Выборка.ДатаНачала + "</td>
		|		<td " + СтильТДлево + Выборка.СерверSQL + "</td>
		|		<td " + СтильТДлево + Выборка.duration + "</td>
		|		<td " + СтильТДлево + Выборка.dbname + "</td>
		|		<td " + СтильТДлево + Выборка.state + "</td>
		|		<td " + СтильТДлево + Выборка.session + "</td>
		|		<td " + СтильТДлево + Выборка.ЗапросSQL + "</td>
		|	</tr>";
		
	КонецЦикла;
	
	ТекстТаблицыHTML = ТекстТаблицыHTML + "
	|</table>";
	
	мТекстПисьма = мТекстПисьма + "
	|" + ТекстТаблицыHTML;
	
	
	мТекстПисьма = мТекстПисьма + "
	|<p>С уважением, <br>1C Robot</p>";
	
	мТекстПисьма = мТекстПисьма + "
	|
	|</body>
	|</html>";
	
	Сообщение = Новый ИнтернетПочтовоеСообщение;
	
	Сообщение.Отправитель.Адрес = "1crobot@lancetpharm.ru";
	
	Сообщение.Тема = Тема;
	
	Текст = Сообщение.Тексты.Добавить();
	Текст.ТипТекста = ТипТекстаПочтовогоСообщения.HTML;
	Текст.Текст = мТекстПисьма;
	
	Для Каждого ОписаниеАдреса Из СписокПолучателей Цикл
		Сообщение.Получатели.Добавить(ОписаниеАдреса.Значение);
	КонецЦикла;

	Для Каждого ОписаниеАдреса Из СписокПолучателейКопии Цикл
		Сообщение.Копии.Добавить(ОписаниеАдреса.Значение);
	КонецЦикла;
	
	РегистрыСведений.УС_ОчередьПочта.СоздатьЗаписьИзСообщения(Сообщение);
	
	ИнтеграцияСTelegram.ОтправитьСообщениеГруппе(ГруппаПолучателей, ТекстСообщенияTG);
	
КонецПроцедуры

#КонецОбласти

