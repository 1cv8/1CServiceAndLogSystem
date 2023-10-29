#Область СлужебныеПроцедурыИФункции

// Возвращает соответствие имен "функциональных" подсистем и значения Истина.
// У "функциональной" подсистемы снят флажок "Включать в командный интерфейс".
//
Функция ИменаПодсистем() Экспорт
	
	ОтключенныеПодсистемы = Новый Соответствие;
	
	Имена = Новый Соответствие;
	ВставитьИменаПодчиненныхПодсистем(Имена, Метаданные, ОтключенныеПодсистемы);
	
	Возврат Новый ФиксированноеСоответствие(Имена);
	
КонецФункции

// Позволяет виртуально отключать подсистемы для целей тестирования.
// Если подсистема отключена, то функция ОбщегоНазначения.ПодсистемаСуществует вернет Ложь.
// В этой процедуре нельзя использовать функцию ОбщегоНазначения.ПодсистемСуществует, т.к. это приводит к рекурсии.
//
// Параметры:
//   ОтключенныеПодсистемы - Соответствие - в ключе указывается имя отключаемой подсистемы, 
//                                          в значении - установить в Истина.
//
Процедура ВставитьИменаПодчиненныхПодсистем(Имена, РодительскаяПодсистема, ОтключенныеПодсистемы, ИмяРодительскойПодсистемы = "")
	
	Для Каждого ТекущаяПодсистема Из РодительскаяПодсистема.Подсистемы Цикл
		
		Если ТекущаяПодсистема.ВключатьВКомандныйИнтерфейс Тогда
			Продолжить;
		КонецЕсли;
		
		ИмяТекущейПодсистемы = ИмяРодительскойПодсистемы + ТекущаяПодсистема.Имя;
		Если ОтключенныеПодсистемы.Получить(ИмяТекущейПодсистемы) = Истина Тогда
			Продолжить;
		Иначе
			Имена.Вставить(ИмяТекущейПодсистемы, Истина);
		КонецЕсли;
		
		Если ТекущаяПодсистема.Подсистемы.Количество() = 0 Тогда
			Продолжить;
		КонецЕсли;
		
		ВставитьИменаПодчиненныхПодсистем(Имена, ТекущаяПодсистема, ОтключенныеПодсистемы, ИмяТекущейПодсистемы + ".");
	КонецЦикла;
	
КонецПроцедуры

Функция КодОсновногоЯзыка() Экспорт
	Возврат Метаданные.ОсновнойЯзык.КодЯзыка;
КонецФункции

// Возвращает соответствие имен предопределенных значений ссылкам на них.
//
// Параметры:
//  ПолноеИмяОбъектаМетаданных - Строка, например, "Справочник.ВидыНоменклатуры",
//                               Поддерживаются только таблицы
//                               с предопределенными элементами:
//                               - Справочники,
//                               - Планы видов характеристик,
//                               - Планы счетов,
//                               - Планы видов расчета.
// 
// Возвращаемое значение:
//  ФиксированноеСоответствие, Неопределено, где
//      * Ключ     - Строка - имя предопределенного,
//      * Значение - Ссылка, Null - ссылка предопределенного или Null, если объекта нет в ИБ.
//
//  Если ошибка в имени метаданных или неподходящий тип метаданного, то возвращается Неопределено.
//  Если предопределенных у метаданного нет, то возвращается пустое фиксированное соответствие.
//  Если предопределенный определен в метаданных, но не создан в ИБ, то для него в соответствии возвращается Null.
//
Функция СсылкиПоИменамПредопределенных(ПолноеИмяОбъектаМетаданных) Экспорт
	
	ПредопределенныеЗначения = Новый Соответствие;
	
	МетаданныеОбъекта = Метаданные.НайтиПоПолномуИмени(ПолноеИмяОбъектаМетаданных);
	
	// Если метаданных не существует.
	Если МетаданныеОбъекта = Неопределено Тогда 
		Возврат Неопределено;
	КонецЕсли;
	
	// Если не подходящий тип метаданных.
	Если Не Метаданные.Справочники.Содержит(МетаданныеОбъекта)
		И Не Метаданные.ПланыВидовХарактеристик.Содержит(МетаданныеОбъекта)
		И Не Метаданные.ПланыСчетов.Содержит(МетаданныеОбъекта)
		И Не Метаданные.ПланыВидовРасчета.Содержит(МетаданныеОбъекта) Тогда 
		
		Возврат Неопределено;
	КонецЕсли;
	
	ИменаПредопределенных = МетаданныеОбъекта.ПолучитьИменаПредопределенных();
	
	// Если предопределенных у метаданного нет.
	Если ИменаПредопределенных.Количество() = 0 Тогда 
		Возврат Новый ФиксированноеСоответствие(ПредопределенныеЗначения);
	КонецЕсли;
	
	// Заполнение по умолчанию признаком отсутствия в ИБ (присутствующие переопределятся).
	Для каждого ИмяПредопределенного Из ИменаПредопределенных Цикл 
		ПредопределенныеЗначения.Вставить(ИмяПредопределенного, Null);
	КонецЦикла;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ТекущаяТаблица.Ссылка КАК Ссылка,
		|	ТекущаяТаблица.ИмяПредопределенныхДанных КАК ИмяПредопределенныхДанных
		|ИЗ
		|	&ТекущаяТаблица КАК ТекущаяТаблица
		|ГДЕ
		|	ТекущаяТаблица.Предопределенный";
	
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "&ТекущаяТаблица", ПолноеИмяОбъектаМетаданных);
	
	УстановитьОтключениеБезопасногоРежима(Истина);
	УстановитьПривилегированныйРежим(Истина);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	УстановитьПривилегированныйРежим(Ложь);
	УстановитьОтключениеБезопасногоРежима(Ложь);
	
	// Заполнение присутствующих в ИБ.
	Пока Выборка.Следующий() Цикл
		ПредопределенныеЗначения.Вставить(Выборка.ИмяПредопределенныхДанных, Выборка.Ссылка);
	КонецЦикла;
	
	Возврат Новый ФиксированноеСоответствие(ПредопределенныеЗначения);
	
КонецФункции

Функция ОписаниеТипаВсеСсылки() Экспорт
	
	Возврат Новый ОписаниеТипов(Новый ОписаниеТипов(Новый ОписаниеТипов(Новый ОписаниеТипов(Новый ОписаниеТипов(
		Новый ОписаниеТипов(Новый ОписаниеТипов(Новый ОписаниеТипов(Новый ОписаниеТипов(
			Справочники.ТипВсеСсылки(),
			Документы.ТипВсеСсылки().Типы()),
			ПланыОбмена.ТипВсеСсылки().Типы()),
			Перечисления.ТипВсеСсылки().Типы()),
			ПланыВидовХарактеристик.ТипВсеСсылки().Типы()),
			ПланыСчетов.ТипВсеСсылки().Типы()),
			ПланыВидовРасчета.ТипВсеСсылки().Типы()),
			БизнесПроцессы.ТипВсеСсылки().Типы()),
			БизнесПроцессы.ТипВсеСсылкиТочекМаршрутаБизнесПроцессов().Типы()),
			Задачи.ТипВсеСсылки().Типы());
	
КонецФункции

Функция ОбщийМодуль(Имя) Экспорт
	Возврат УИ_ОбщегоНазначения.ОбщийМодуль(Имя);
КонецФункции

#КонецОбласти


#Область СлужебныйПрограммныйИнтерфейс

Функция СоответствиеСтавокНДС() Экспорт
	
	СоответствиеСтавокНДС = Новый Соответствие;
	
	//Соответствие значения ставки перечислению
	СоответствиеСтавокНДС.Вставить(Перечисления.СтавкиНДС.БезНДС, 	"Не облагается");
	СоответствиеСтавокНДС.Вставить(Перечисления.СтавкиНДС.НДС0, 	"Не облагается");
	СоответствиеСтавокНДС.Вставить(Перечисления.СтавкиНДС.НДС10, 	"10%");
	СоответствиеСтавокНДС.Вставить(Перечисления.СтавкиНДС.НДС18, 	"20%");
	Попытка 
		СоответствиеСтавокНДС.Вставить(Перечисления.СтавкиНДС.НДС20, 	"20%");
	Исключение КонецПопытки;
		
	//Соответствие значения ставки представлению
	СоответствиеСтавокНДС.Вставить("Не облагается", "0.0");
	СоответствиеСтавокНДС.Вставить("10%", "0.1");
	СоответствиеСтавокНДС.Вставить("20%", "0.2");
	
	//Соответствие представления ставки значению
	СоответствиеСтавокНДС.Вставить("0.0", "Не облагается");
	СоответствиеСтавокНДС.Вставить("0.1", "10%");
	СоответствиеСтавокНДС.Вставить("0.2", "20%");

	
	Возврат Новый ФиксированноеСоответствие(СоответствиеСтавокНДС);
	
КонецФункции

Функция ТипРеквизита(type, МножественныйВыбор, ЗначенияИзСправочника) Экспорт
	
	Тип = Новый ОписаниеТипов("Строка", , Новый КвалификаторыСтроки(500, ДопустимаяДлина.Переменная));
	typeНР = НРег(type);
	Если МножественныйВыбор Тогда
		Тип = Новый ОписаниеТипов("СписокЗначений");
	ИначеЕсли typeНР = "string" Тогда
		Тип = Новый ОписаниеТипов("Строка", , Новый КвалификаторыСтроки(0, ДопустимаяДлина.Переменная));		
	ИначеЕсли typeНР = "decimal" Тогда
		Тип = Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(10, 3, ДопустимыйЗнак.Любой));
	ИначеЕсли typeНР = "integer" Тогда
		Тип = Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(10, 0, ДопустимыйЗнак.Любой));
	ИначеЕсли typeНР = "boolean" Тогда
		Тип = Новый ОписаниеТипов("Булево");
	ИначеЕсли typeНР = "multiline" Тогда
		Тип = Новый ОписаниеТипов("Строка", , Новый КвалификаторыСтроки(0, ДопустимаяДлина.Переменная));
	КонецЕсли;	
	
	Возврат Тип;
	
КонецФункции

Функция ВидПоля(type) Экспорт
	
	ВидПоля = ВидПоляФормы.ПолеВвода;
	
	Если НРег(type) = "boolean" Тогда
		 ВидПоля = ВидПоляФормы.ПолеФлажка;
	КонецЕсли;
	
	Возврат ВидПоля;
	
КонецФункции

#КонецОбласти
