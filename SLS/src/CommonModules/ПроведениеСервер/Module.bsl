///////////////////////////////////////////////////////////////////////////////////
// Процедуры для подготовки и записи движений документа.

// Процедура инициализирует общие структуры, используемые при проведении документов.
// Вызывается из модуля документов при проведении.
//
Процедура ИнициализироватьДополнительныеСвойстваДляПроведения(ДокументСсылка, ДополнительныеСвойства, РежимПроведения = Неопределено) Экспорт

	// В структуре "ДополнительныеСвойства" создаются свойства с ключами "ТаблицыДляДвижений", "ДляПроведения".

	// "ТаблицыДляДвижений" - структура, которая будет содержать таблицы значений с данными для выполнения движений.
	ДополнительныеСвойства.Вставить("ТаблицыДляДвижений", Новый Структура);

	// "ДляПроведения" - структура, содержащая свойства и реквизиты документа, необходимые для проведения.
	ДополнительныеСвойства.Вставить("ДляПроведения", Новый Структура);
	
	// Структура, содержащая ключ с именем "МенеджерВременныхТаблиц", в значении которого хранится менеджер временных таблиц.
	// Содержит для каждой временной таблицы ключ (имя временной таблицы) и значение (признак наличия записей во временной таблице).
	ДополнительныеСвойства.ДляПроведения.Вставить("СтруктураВременныеТаблицы", Новый Структура("МенеджерВременныхТаблиц", Новый МенеджерВременныхТаблиц));
	ДополнительныеСвойства.ДляПроведения.Вставить("РежимПроведения",           РежимПроведения);
	ДополнительныеСвойства.ДляПроведения.Вставить("МетаданныеДокумента",       ДокументСсылка.Метаданные());
	ДополнительныеСвойства.ДляПроведения.Вставить("Ссылка",                    ДокументСсылка);

КонецПроцедуры

Процедура ОчиститьДополнительныеСвойстваДляПроведения(ДополнительныеСвойства) Экспорт

	ДополнительныеСвойства.ДляПроведения.СтруктураВременныеТаблицы.МенеджерВременныхТаблиц.Закрыть();

КонецПроцедуры

// Функция формирует массив имен регистров, по которым документ имеет движения.
// Вызывается при подготовке записей к регистрации движений.
//
Функция ПолучитьМассивИспользуемыхРегистров(Регистратор, Движения, МассивИсключаемыхРегистров = Неопределено) Экспорт

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Регистратор", Регистратор);

	Результат = Новый Массив;
	МаксимумТаблицВЗапросе = 256;

	СчетчикТаблиц   = 0;
	СчетчикДвижений = 0;

	ВсегоДвижений = Движения.Количество();
	ТекстЗапроса  = "";
	Для Каждого Движение Из Движения Цикл

		СчетчикДвижений = СчетчикДвижений + 1;

		ПропуститьРегистр = МассивИсключаемыхРегистров <> Неопределено
							И МассивИсключаемыхРегистров.Найти(Движение.Имя) <> Неопределено;

		Если Не ПропуститьРегистр Тогда

			Если СчетчикТаблиц > 0 Тогда

				ТекстЗапроса = ТекстЗапроса + "
				|ОБЪЕДИНИТЬ ВСЕ
				|";

			КонецЕсли;

			СчетчикТаблиц = СчетчикТаблиц + 1;

			ТекстЗапроса = ТекстЗапроса + 
			"
			|ВЫБРАТЬ ПЕРВЫЕ 1
			|""" + Движение.Имя + """ КАК ИмяРегистра
			|
			|ИЗ " + Движение.ПолноеИмя() + "
			|
			|ГДЕ Регистратор = &Регистратор
			|";

		КонецЕсли;

		Если СчетчикТаблиц = МаксимумТаблицВЗапросе Или СчетчикДвижений = ВсегоДвижений Тогда

			Запрос.Текст  = ТекстЗапроса;
			ТекстЗапроса  = "";
			СчетчикТаблиц = 0;

			Если Результат.Количество() = 0 Тогда

				Результат = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("ИмяРегистра");

			Иначе

				Выборка = Запрос.Выполнить().Выбрать();
				Пока Выборка.Следующий() Цикл
					Результат.Добавить(Выборка.ИмяРегистра);
				КонецЦикла;

			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

	Возврат Результат;

КонецФункции

// Процедура выполняет пордготовку наборов записей документа к записи движений.
// 1. Очищает наборы записей от "старых записей" (ситуация возможна только в толстом клиенте)
// 2. Взводит флаг записи у наборов, по которым документ имеет движения
// Вызывается из модуля документов при проведении.
//
Процедура ПодготовитьНаборыЗаписейКРегистрацииДвижений(Объект, ЭтоНовый = Ложь) Экспорт
	Перем ЭтоНовыйДокумент, МетаданныеДвижения;
	
	Для Каждого НаборЗаписей Из Объект.Движения Цикл

		Если НаборЗаписей.Количество() > 0 Тогда
			НаборЗаписей.Очистить();
		КонецЕсли;

	КонецЦикла;
	
	Если НЕ Объект.ДополнительныеСвойства.Свойство("ЭтоНовый", ЭтоНовыйДокумент) Тогда
		ЭтоНовыйДокумент = ЭтоНовый;
	КонецЕсли;
	
	Если НЕ ЭтоНовыйДокумент Тогда

		// Регистры, движения по которым формируются не из модуля менеджера документа.
		ИсключаемыеРегистры = Новый Массив;
		//ИсключаемыеРегистры.Добавить("ГрафикДвиженияТоваров");
		
		Если Объект.ДополнительныеСвойства.Свойство("ДляПроведения")
		 И Объект.ДополнительныеСвойства.ДляПроведения.Свойство("МетаданныеДокумента") Тогда
			МетаданныеДвижения = Объект.ДополнительныеСвойства.ДляПроведения.МетаданныеДокумента.Движения;
		Иначе
			МетаданныеДвижения = Объект.Метаданные().Движения;
		КонецЕсли;
		
		МассивИменРегистров = ПолучитьМассивИспользуемыхРегистров(
			Объект.Ссылка,
			МетаданныеДвижения,
			ИсключаемыеРегистры);

		Для Каждого ИмяРегистра Из МассивИменРегистров Цикл
			Объект.Движения[ИмяРегистра].Записывать = Истина;
		КонецЦикла;
		
	КонецЕсли;

КонецПроцедуры

// Процедура записывает движения документа. Дополнительно происходит копирование параметров
// в модули наборов записей для выполнения регистрации изменений в движениях.
// Процедура вызывается из модуля документов при проведении.
//
Процедура ЗаписатьНаборыЗаписей(Объект) Экспорт
	Перем РегистрыДляКонтроля, РассчитыватьИзменения;

	// Регистры, для которых будут рассчитаны таблицы изменений движений.
	Если Объект.ДополнительныеСвойства.ДляПроведения.Свойство("РегистрыДляКонтроля", РегистрыДляКонтроля) Тогда
		Для Каждого НаборЗаписей Из РегистрыДляКонтроля Цикл
			Если НаборЗаписей.Записывать Тогда

				// Установка флага регистрации изменений в наборе записей.
				Если НЕ Объект.ДополнительныеСвойства.Свойство("РассчитыватьИзменения", РассчитыватьИзменения) Тогда
					РассчитыватьИзменения = Истина;
				КонецЕсли;
				
				НаборЗаписей.ДополнительныеСвойства.Вставить("РассчитыватьИзменения", РассчитыватьИзменения);
				НаборЗаписей.ДополнительныеСвойства.Вставить("ЭтоНовый", Объект.ДополнительныеСвойства.ЭтоНовый);
				//hola +++ 10.01.2018
				НаборЗаписей.ДополнительныеСвойства.Вставить("ДатаРегистратора", Объект.Дата);
				НаборЗаписей.ДополнительныеСвойства.Вставить("РежимЗаписи", Объект.ДополнительныеСвойства.РежимЗаписи);
				//hola ---
				
				// Структура для передачи данных в модули наборов записей.
				НаборЗаписей.ДополнительныеСвойства.Вставить("ДляПроведения", 
						Новый Структура("СтруктураВременныеТаблицы", Объект.ДополнительныеСвойства.ДляПроведения.СтруктураВременныеТаблицы));

				// Необходимость контроля обеспечения устанавливается при выполнении рекомендаций в "Состояние обеспечения заказов".
				КонтролироватьОбеспечение = Неопределено;
				Если Объект.ДополнительныеСвойства.Свойство("КонтролироватьОбеспечение", КонтролироватьОбеспечение) Тогда
					НаборЗаписей.ДополнительныеСвойства.Вставить("КонтролироватьОбеспечение", КонтролироватьОбеспечение);
				КонецЕсли;
				
				//РСВ 12/02/2018
				ОпцииКонтроляРегистров = Неопределено;
				Объект.ДополнительныеСвойства.ДляПроведения.Свойство("ОпцииКонтроляРегистров", ОпцииКонтроляРегистров);
				Если ОпцииКонтроляРегистров = Неопределено Тогда
					ОпцииКонтроляРегистров = Новый Структура;
				КонецЕсли;
				
				НаборЗаписей.ДополнительныеСвойства.ДляПроведения.Вставить("ОпцииКонтроляРегистров", ОпцииКонтроляРегистров);
				//РСВ 12/02/2018 <<<

			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	//++ТКЕ/ЗНИ-1467/ 03.06.2020 Для того, чтобы отслеживать изменения в регистрах, запись в которых
	// идет с предварительной очисткой движений
	Для каждого НаборЗаписей Из Объект.Движения Цикл
		Если НаборЗаписей.ДополнительныеСвойства.Свойство("ДляПроведения") И
			НаборЗаписей.ДополнительныеСвойства.ДляПроведения.Свойство("ЭтапЗаписиДвижений") Тогда		
			НаборЗаписей.ДополнительныеСвойства.ДляПроведения.ЭтапЗаписиДвижений = "Запись";		
		КонецЕсли; 		
	КонецЦикла; 	
	//--ТКЕ 03.06.2020

	Объект.Движения.Записать();
	
КонецПроцедуры

// Процедура очищает и записывает пустые движения по указанным регистрам
//
// Параметры:
// 		Движения - КоллекцияДвижений - Коллекция наборов записей регистров документа
// 		Регистры - Строка - Строка с именами регистров для очистки, перечисленными через запятую
//
Процедура ОчиститьЗаписатьДвижения(Движения, Регистры) Экспорт
	
	СтруктураРегистров = Новый Структура(Регистры);
	Для Каждого КлючИЗначение Из СтруктураРегистров Цикл
		Движения[КлючИЗначение.Ключ].Очистить();
		Движения[КлючИЗначение.Ключ].Записать(Истина);
	КонецЦикла;
	
КонецПроцедуры

// Процедура компонует текст запроса, выполняет запрос и выгружает результаты запроса в таблицы
//
// Параметры:
//	Запрос - Запрос - запрос, параметры которого предварительно установлены.
//	ТекстыЗапроса - Список значений - список значений, значениями которого являются блоки запроса,
//	                                  синонимами - имена таблиц в которые необходимо поместить
//	                                  результат выполнения каждого отдельного блока запроса.
//	Таблицы - Структура - структура в которую будут помещены полученные таблицы для движений.
//	ОбходРезультата - ОбходРезультатаЗапроса - вариант обхода результата запроса.
//
Процедура ИницализироватьТаблицыДляДвижений(Запрос, ТекстыЗапроса, Таблицы, ДобавитьРазделитель = Истина, ДобавлятьСловоТаблица = Истина, ТолькоОтмеченные=Ложь) Экспорт

	ТаблицыЗапроса = ВыгрузитьРезультатыЗапроса(Запрос, ТекстыЗапроса,, ДобавитьРазделитель);
	
	// Помещение результатов запроса в таблицы
	Для Каждого ТекстЗапроса из ТекстыЗапроса Цикл

		ИмяТаблицы = ТекстЗапроса.Представление;

		Если Не ПустаяСтрока(ИмяТаблицы) И (Не ТолькоОтмеченные Или ТекстЗапроса.Пометка) Тогда

			Если ДобавлятьСловоТаблица Тогда
				// Таблицы для проведения должны начинаться с "Таблица"
				Если НЕ СтрНачинаетсяС(ИмяТаблицы, "Таблица") Тогда
					ИмяТаблицы = "Таблица" + ИмяТаблицы;
				КонецЕсли;
			КонецЕсли;
			
			Таблицы.Вставить(ИмяТаблицы, ТаблицыЗапроса[ТекстЗапроса.Представление]);

		КонецЕсли;

	КонецЦикла;

КонецПроцедуры

// Проверяет наличие текста запроса для формирования указанной таблицы
//
// Параметры:
//  ИмяТаблицы		- Строка - имя таблицы
//	ТекстыЗапроса 	- Список значений - список значений, значениями которого являются блоки запроса,
//	                                  синонимами - имена таблиц в которые необходимо поместить
//	                                  результат выполнения каждого отдельного блока запроса.
// 
// Возвращаемое значение:
//   - Булево - Истина, если текст запроса есть.
//
Функция ЕстьТаблицаЗапроса(ИмяТаблицы, ТекстыЗапроса) Экспорт

	Для каждого ТекстЗапроса Из ТекстыЗапроса Цикл
		Если НРег(ТекстЗапроса.Представление) = НРег(ИмяТаблицы) Тогда
			Возврат Истина;
		КонецЕсли; 
	КонецЦикла; 
	
	Возврат Ложь;

КонецФункции

// Определяет необходимость подготовить таблицу для формирования движений
//
// Параметры:
//  ИмяРегистра	- Строка - имя регистра. Например "ТоварыНаСкладах"
//  Регистры	- Строка, Структура, Неопределено - список регистров, разделенных запятой, или структура, в ключах которой - имена регистров
//													Если неопределено - то всегда возвращается ИСТИНА
// 
// Возвращаемое значение:
//   - Булево - Истина, если требуется инициализировать указанную таблицу
//
Функция ТребуетсяТаблицаДляДвижений(ИмяРегистра, Регистры) Экспорт

	Если ЗначениеЗаполнено(Регистры) Тогда
		
		Если ТипЗнч(Регистры) = Тип("Строка") Тогда
			МассивРегистров = Новый Структура(Регистры);
		Иначе
			МассивРегистров = Регистры;
		КонецЕсли;
		
		Если НЕ МассивРегистров.Свойство(ИмяРегистра) Тогда
			Возврат Ложь;
		КонецЕсли; 
		
	КонецЕсли; 
	
	Возврат Истина;

КонецФункции

///////////////////////////////////////////////////////////////////////////////////
// Процедуры контроля движений документов по регистрам.

// Функция проверяет наличие изменений в таблице регистра.
//
Функция ЕстьИзмененияВТаблице(СтруктураДанных, Ключ)
	Перем ЕстьИзменения;

	Возврат СтруктураДанных.Свойство(Ключ, ЕстьИзменения) И ЕстьИзменения;

КонецФункции

// Процедура выполняет контроль результатов проведения.
// Процедура вызывается из модуля документов при проведении.
//
Процедура ВыполнитьКонтрольРезультатовПроведения(Объект, Отказ) Экспорт

	Если Объект.ДополнительныеСвойства.ДляПроведения.РегистрыДляКонтроля.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;

КонецПроцедуры

// Процедура выполняет подготовку наборов записей документа к проведению документа.
// 1. Очищает наборы записей от "старых записей" (ситуация возможна только в толстом клиенте)
// 2. Взводит флаг записи у наборов, по которым документ имел движения при прошлом проведении
// 3. Устанавливает активность наборам записей документов с установленным флагом ручной корректировки
// 4. Записывает пустые наборы, если дата ранее проведенного документа была сдвинута вперед
// Вызывается из модуля документа при проведении.
//
Процедура ПодготовитьНаборыЗаписейКПроведению(Объект, ВыборочноОчищатьРегистры = Истина) Экспорт
	
	Для каждого НаборЗаписей Из Объект.Движения Цикл
		Если НаборЗаписей.Количество() > 0 Тогда
			НаборЗаписей.Очистить();
		КонецЕсли;
	КонецЦикла;

	Если Объект.ДополнительныеСвойства.ЭтоНовый Тогда
		Возврат;
	КонецЕсли;
	
	МетаданныеОбъекта = Объект.Метаданные();
	
	// Регистры, требующие принудительной очистки:
	МассивИменРегистровПринудительнойОчистки = Новый Массив;
	МассивДвиженийДляПринудительнойОчистки = Новый Массив;
	
	МассивИменРегистров = ПолучитьМассивИспользуемыхРегистров(
		Объект.Ссылка, 
		МетаданныеОбъекта.Движения);

	Для каждого ИмяРегистра Из МассивИменРегистров Цикл
		Объект.Движения[ИмяРегистра].Записывать = Истина;
		Если МассивИменРегистровПринудительнойОчистки.Найти(ИмяРегистра) <> Неопределено
			ИЛИ НЕ ВыборочноОчищатьРегистры Тогда
			МассивДвиженийДляПринудительнойОчистки.Добавить(Объект.Движения[ИмяРегистра]);
		КонецЕсли; 
	КонецЦикла;
	
КонецПроцедуры

// Процедура выполняет подготовку наборов записей документа к отмене проведения документа.
// 1. Взводит флаг записи у наборов, по которым документ имел движения при прошлом проведении
// 2. Снимает активность у наборов записей документов с установленным флагом ручной корректировки
// Вызывается из модуля документа при отмене проведения.
//
Процедура ПодготовитьНаборыЗаписейКОтменеПроведения(Объект) Экспорт
	
	МетаданныеОбъекта = Объект.Метаданные();
	
	МассивИменРегистров = ПолучитьМассивИспользуемыхРегистров(
		Объект.Ссылка, 
		МетаданныеОбъекта.Движения);

	Для каждого ИмяРегистра Из МассивИменРегистров Цикл
		Объект.Движения[ИмяРегистра].Записывать = Истина;
	КонецЦикла;
	
	РучнаяКорректировка = МетаданныеОбъекта.Реквизиты.Найти("РучнаяКорректировка") <> Неопределено
		И Объект.РучнаяКорректировка;
	
	Если РучнаяКорректировка Тогда
		Для каждого ИмяРегистра Из МассивИменРегистров Цикл
			Объект.Движения[ИмяРегистра].Прочитать();
			Объект.Движения[ИмяРегистра].УстановитьАктивность(Ложь);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

// Формирует пакет запросов и возвращает результат каждого запроса
//
// Параметры:
//	Запрос			- Запрос - запрос, параметры которого предварительно установлены.
//	ТекстыЗапроса	- Список значений - в списке перечислены тексты запросов и их имена.
//	ОбходРезультата - ОбходРезультатаЗапроса - вариант обхода результата запроса.
//
// Возвращаемое значение:
//   Структура   - структура в которую помещены полученные таблицы
//
Функция ВыгрузитьРезультатыЗапроса(Запрос, ТекстыЗапроса, ОбходРезультата = Неопределено, ДобавитьРазделитель = Ложь) Экспорт

	Таблицы = Новый Структура;
	
	// Инициализация варианта обхода результата запроса.
	Если ОбходРезультата = Неопределено Тогда
		ОбходРезультата = ОбходРезультатаЗапроса.Прямой;
	КонецЕсли;
	
	// Формирование текст запроса.
	Запрос.Текст = "";
	Для Каждого ТекстЗапроса Из ТекстыЗапроса Цикл
		Если ЗначениеЗаполнено(ТекстЗапроса.Представление) Тогда
			Запрос.Текст = Запрос.Текст 
							+ ?(Запрос.Текст <> "", Символы.ПС, "")
							+ "// " + ТекстЗапроса.Представление + Символы.ПС;
		КонецЕсли; 
		Запрос.Текст = Запрос.Текст + ТекстЗапроса.Значение;
		Если ДобавитьРазделитель Тогда
			Запрос.Текст = Запрос.Текст + "
			|;
			|
			|////////////////////////////////////////////////////////////////////////////////
			|"
		КонецЕсли; 
	КонецЦикла;

	// Выполнение запроса.
	Результат = Запрос.ВыполнитьПакет();

	// Помещение результатов запроса в таблицы
	Для Каждого ТекстЗапроса Из ТекстыЗапроса Цикл

		ИмяТаблицы = ТекстЗапроса.Представление;

		Если Не ПустаяСтрока(ИмяТаблицы) Тогда

			Индекс = ТекстыЗапроса.Индекс(ТекстЗапроса);
			Таблицы.Вставить(ИмяТаблицы, Результат[Индекс].Выгрузить(ОбходРезультата));

		КонецЕсли;

	КонецЦикла;

	Возврат Таблицы;
	
КонецФункции

// Процедура формирования движений по регистру 
//
Процедура ОтразитьДвижения(ДополнительныеСвойства, Движения, ИмяРегистра, Отказ) Экспорт

	Таблица = ДополнительныеСвойства.ТаблицыДляДвижений["Таблица" + ИмяРегистра];
	
	Если Отказ Или Таблица.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	ДвиженияЗаказыКлиентов = Движения[ИмяРегистра];
	ДвиженияЗаказыКлиентов.Записывать = Истина;
	ДвиженияЗаказыКлиентов.Загрузить(Таблица);
	
КонецПроцедуры

Функция ЕстьДвиженияПоРегистру(Регистратор, ПолноеИмяРегистра) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Регистратор", Регистратор);
	
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	1 КАК ЕстьЗаписи
	|ИЗ
	|	" + ПолноеИмяРегистра + " КАК ЗаписиРегистра
	|ГДЕ
	|	ЗаписиРегистра.Регистратор = &Регистратор";
	
	УстановитьПривилегированныйРежим(Истина);
	РезультатЗапроса = Запрос.Выполнить();
	УстановитьПривилегированныйРежим(Ложь);
	
	Возврат НЕ РезультатЗапроса.Пустой();
	
КонецФункции

Процедура ОчиститьДвиженияДокументаПриНеобходимости(ДокументОбъект, Регистры) Экспорт
	
	СтруктураРегистров = Новый Структура(Регистры);
	Для Каждого КлючИЗначение Из СтруктураРегистров Цикл
		
		ИмяРегистра = КлючИЗначение.Ключ;
		
		Если ПроведениеСервер.ЕстьДвиженияПоРегистру(ДокументОбъект.Ссылка, ДокументОбъект.Движения[ИмяРегистра].Метаданные().ПолноеИмя()) Тогда
			ПроведениеСервер.ОчиститьЗаписатьДвижения(ДокументОбъект.Движения, ИмяРегистра);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

#Область СобытияДокумента

Процедура ПередЗаписьюДокумента(Документ, РежимЗаписи, РежимПроведения, СтрокаРеквизитовСсылки = "") Экспорт
	
	//Если Документ.Проведен И РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
	//	РежимПроведения = РежимПроведенияДокумента.Неоперативный;
	//КонецЕсли;
	
	Если Документ.ОбменДанными.Загрузка <> Истина Тогда
		ЗамерВремени = ОценкаПроизводительности.НачатьЗамерВремени(); //Данная процедура должна быть первой!
		Документ.ДополнительныеСвойства.Вставить("ЗамерВремени", ЗамерВремени);
	КонецЕсли;
	
	Документ.ДополнительныеСвойства.Вставить("ЭтоНовый",			Документ.ЭтоНовый());
	Документ.ДополнительныеСвойства.Вставить("РежимЗаписи",			РежимЗаписи);
	Документ.ДополнительныеСвойства.Вставить("РежимПроведения",		РежимПроведения);
	Документ.ДополнительныеСвойства.Вставить("Проведен",			Документ.Проведен);
	
	ЭтоПроведение = 
		РежимЗаписи = РежимЗаписиДокумента.Проведение
		ИЛИ
			(
				Документ.Проведен
				И РежимЗаписи <> РежимЗаписиДокумента.ОтменаПроведения
			);
	Документ.ДополнительныеСвойства.Вставить("ЭтоПроведение",		ЭтоПроведение);
	
	
	Если ЗначениеЗаполнено(СтрокаРеквизитовСсылки) Тогда
		Если НЕ Документ.ЭтоНовый() Тогда
			ДанныеСсылки = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Документ.Ссылка, СтрокаРеквизитовСсылки);
		Иначе
			ДанныеСсылки = Новый Структура(СтрокаРеквизитовСсылки);
		КонецЕсли;
	Иначе
		ДанныеСсылки = Новый Структура();
	КонецЕсли;
	Документ.ДополнительныеСвойства.Вставить("ДанныеСсылки", ДанныеСсылки);
	
КонецПроцедуры

Процедура ПередЗаписьюДокументаПодписка(Источник, Отказ, РежимЗаписи, РежимПроведения) Экспорт
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;

	ДополнительныеСвойства = Источник.ДополнительныеСвойства;

	Если НЕ ДополнительныеСвойства.Свойство("ЗамерВремени") Тогда
		Если Источник.ОбменДанными.Загрузка <> Истина
			И ОценкаПроизводительностиВызовСервераПовтИсп.ВыполнятьЗамерыПроизводительности()
			Тогда
			
			ДополнительныеСвойства.Вставить("ЗамерВремени", ОценкаПроизводительности.НачатьЗамерВремени());
		КонецЕсли;
	КонецЕсли;

	
КонецПроцедуры

Процедура ПриЗаписиДокумента(Документ, Отказ) Экспорт
	
	ДополнительныеСвойства = СвойстваДокумента(Документ);
	
	Если НЕ ДополнительныеСвойства.Свойство("РежимЗаписи") Тогда
		Возврат;
	КонецЕсли;
	
	Если Документ.ДополнительныеСвойства.Свойство("Служебный_ОбработкаОбъекта") Тогда
		Возврат;
	КонецЕсли;
	
	Если ДополнительныеСвойства.РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

Процедура ПрослеЗаписиДокумента(Документ, Отказ) Экспорт
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	ДополнительныеСвойства = СвойстваДокумента(Документ);
	
	Если НЕ ДополнительныеСвойства.Свойство("РежимЗаписи") Тогда
		Возврат;
	КонецЕсли;
	
	Если Документ.ДополнительныеСвойства.Свойство("Служебный_ОбработкаОбъекта") Тогда
		Возврат;
	КонецЕсли;
	
	Если ДополнительныеСвойства.РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли;
	

	//ОценкаПроизводительности. Данная процедура должна быть последней!	+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Если ДополнительныеСвойства.Свойство("ЗамерВремени") Тогда
		СтруктураКомментарии = Новый Структура;
		СтруктураКомментарии.Вставить("Ссылка",				Документ.Ссылка);
		СтруктураКомментарии.Вставить("ПараметрыЗаписи",	ДополнительныеСвойства.РежимПроведения);
		
		ОценкаПроизводительности.ЗакончитьЗамерВремени(
			"Запись " + Документ.Метаданные().ПолноеИмя(),
			ДополнительныеСвойства.ЗамерВремени,
			ОценкаПроизводительности.ВернутьВесОбъекта(Документ),
			СтруктураКомментарии);
	КонецЕсли;
	//ОценкаПроизводительности. Данная процедура должна быть последней!	+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	
КонецПроцедуры

Процедура ОбработкаПроведенияДокумента(Документ, Отказ, ДопПараметры = Неопределено) Экспорт
	
	ДополнительныеСвойства = СвойстваДокумента(Документ);
	
	Если НЕ ДополнительныеСвойства.Свойство("РежимЗаписи") Тогда
		Возврат;
	КонецЕсли;
	
	Если Документ.ДополнительныеСвойства.Свойство("Служебный_ОбработкаОбъекта") Тогда
		Возврат;
	КонецЕсли;
	
	Если ДополнительныеСвойства.РежимЗаписи <> РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПослеПроведенияДокумента(Документ, Отказ, РежимПроведения) Экспорт
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	ДополнительныеСвойства = СвойстваДокумента(Документ);

	Если Документ.ДополнительныеСвойства.Свойство("Служебный_ОбработкаОбъекта") Тогда
		Возврат;
	КонецЕсли;
	
	//ОценкаПроизводительности. Данная процедура должна быть последней!	+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Если ДополнительныеСвойства.Свойство("ЗамерВремени") Тогда
		
		СтруктураКомментарии = Новый Структура;
		СтруктураКомментарии.Вставить("Ссылка",				Документ.Ссылка);
		//СтруктураКомментарии.Вставить("ПараметрыЗаписи",	РежимПроведения);
		
		ОценкаПроизводительности.ЗакончитьЗамерВремени(
			"Проведение " + Документ.Метаданные().ПолноеИмя(),
			ДополнительныеСвойства.ЗамерВремени,
			ОценкаПроизводительности.ВернутьВесОбъекта(Документ),
			СтруктураКомментарии);
		
	КонецЕсли;
	//ОценкаПроизводительности. Данная процедура должна быть последней!	+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	
КонецПроцедуры

Процедура ОбработкаУдаленияПроведенияДокумента(Документ, Отказ) Экспорт
	
	ДополнительныеСвойства = СвойстваДокумента(Документ);
	
	Если ДополнительныеСвойства.РежимЗаписи <> РежимЗаписиДокумента.ОтменаПроведения Тогда
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СобытияСправочника

Процедура ПередЗаписьюСправочника(Источник, СтрокаРеквизитовСсылки = "") Экспорт

	Если Источник.ОбменДанными.Загрузка <> Истина Тогда
		ЗамерВремени = ОценкаПроизводительности.НачатьЗамерВремени(); //Данная процедура должна быть первой!
		Источник.ДополнительныеСвойства.Вставить("ЗамерВремени", ЗамерВремени);
	КонецЕсли;
	
	Источник.ДополнительныеСвойства.Вставить("ЭтоНовый",			Источник.ЭтоНовый());
	
	Если ЗначениеЗаполнено(СтрокаРеквизитовСсылки) Тогда
		Если НЕ Источник.ЭтоНовый() Тогда
			ДанныеСсылки = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Источник.Ссылка, СтрокаРеквизитовСсылки);
		Иначе
			ДанныеСсылки = Новый Структура(СтрокаРеквизитовСсылки);
		КонецЕсли;
	Иначе
		ДанныеСсылки = Новый Структура();
	КонецЕсли;
	Источник.ДополнительныеСвойства.Вставить("ДанныеСсылки", ДанныеСсылки);
	
КонецПроцедуры

Процедура ПередЗаписьюСправочникаПодписка(Источник, Отказ) Экспорт

	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	ДополнительныеСвойства = Источник.ДополнительныеСвойства;

	Если НЕ ДополнительныеСвойства.Свойство("ЗамерВремени") Тогда
		Если Источник.ОбменДанными.Загрузка <> Истина
			И ОценкаПроизводительностиВызовСервераПовтИсп.ВыполнятьЗамерыПроизводительности()
			Тогда
			
			ДополнительныеСвойства.Вставить("ЗамерВремени", ОценкаПроизводительности.НачатьЗамерВремени());
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

Процедура ПослеЗаписиСправочника(Источник, Отказ) Экспорт
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	ДополнительныеСвойства = СвойстваДокумента(Источник);
	
	Если Источник.ДополнительныеСвойства.Свойство("Служебный_ОбработкаОбъекта") Тогда
		Возврат;
	КонецЕсли;
	

	
	
	//ОценкаПроизводительности. Данная процедура должна быть последней!	+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Если ДополнительныеСвойства.Свойство("ЗамерВремени") Тогда
		СтруктураКомментарии = Новый Структура;
		СтруктураКомментарии.Вставить("Ссылка",				Источник.Ссылка);
		
		ОценкаПроизводительности.ЗакончитьЗамерВремени(
			"Запись " + Источник.Метаданные().ПолноеИмя(),
			ДополнительныеСвойства.ЗамерВремени,
			,//ОценкаПроизводительности.ВернутьВесОбъекта(Источник),
			СтруктураКомментарии);
	КонецЕсли;
	//ОценкаПроизводительности. Данная процедура должна быть последней!	+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	
КонецПроцедуры

#КонецОбласти

#Область ВспомогательныеФункции

// Возвращает список свойств проводимого документа.
//
// Параметры:
//  Документ - ДокументОбъект - документ, по которому необходимо получить свойства.
//
// Возвращаемое значение:
//  ФиксированнаяСтруктура - со свойствами:
//     * ЭтоНовый - Булево - Истина - документ перед записью не был записан в базу, Ложь - документ уже был записан
//     * Проведен - Булево - Истина - документ перед записью уже был проведен; Ложь - документ не был проведен
//     * РежимЗаписи - РежимЗаписиДокумента - текущий режим записи документа
//     * РежимПроведения - РежимПроведенияДокумента - текущий режим проведения документа.
//
Функция СвойстваДокумента(Знач Документ) Экспорт
	
	Возврат Документ.ДополнительныеСвойства;
	
КонецФункции

#КонецОбласти
