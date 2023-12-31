
// Подсмотрено тут: ИНСТРУМЕНТЫ РАЗРАБОТЧИКА ПОРТАТИВНЫЙ 1С 8.2+ V6.40.1P
//	http://devtool1c.ucoz.ru/load/osnovnye/portativnye_instrumenty_razrabotchika_dlja_1s_8_2/1-1-0-6


Перем ТекущийДвижок;
Перем Вычислитель;
Перем ТипВхождения;
Перем ВхождениеОбразец;
Перем ЧтениеJSON;
Перем СтарыйGlobal;
Перем СтарыйIgnoreCase;
Перем СтарыйMultiline;
Перем СтарыйPattern;
Перем ДоступныеДвижкиСтруктура;

// Execute
Функция НайтиВхождения(Знач ТекстГдеИскать, ТолькоПоследнее = Ложь, РазрешитьЧужуюКоллекцию = Ложь) Экспорт 
	
	Если ТекстГдеИскать = Неопределено Тогда
		ТекстГдеИскать = "";
	КонецЕсли;
	
	Вхождения = Новый Массив;
	
	Если ТекущийДвижок = "VBScript" Тогда
		РезультатПоиска = Вычислитель().Execute(ТекстГдеИскать);
		Если РезультатПоиска.Count > 0 Тогда
			Если ТолькоПоследнее Тогда
				Вхождения.Добавить(РезультатПоиска.Item(РезультатПоиска.Count - 1));
			Иначе 
				Если РазрешитьЧужуюКоллекцию Тогда
					Вхождения = РезультатПоиска;
				Иначе
					Для каждого Элемент из РезультатПоиска Цикл
						Вхождения.Добавить(Элемент);
					КонецЦикла;
				КонецЕсли;
			КонецЕсли; 
		КонецЕсли; 
	Иначе
		
		Попытка
			РезультатJSON = Вычислитель().MatchesJSON(ТекстГдеИскать);
		Исключение
			ВызватьИсключение Вычислитель().ОписаниеОшибки;
		КонецПопытки;
		
		Если ЗначениеЗаполнено(РезультатJSON) Тогда

			ЧтениеJSON = Новый ЧтениеJSON;
			ЧтениеJSON.УстановитьСтроку(РезультатJSON);
			Коллекция = ПрочитатьJSON(ЧтениеJSON, Ложь);
			
			СтруктураРезультат = Новый Структура("FirstIndex, Length, Value");
			Если Коллекция.Количество() > 0 Тогда
				
				Если ТолькоПоследнее Тогда
					Элемент = Коллекция[Коллекция.ВГраница()];
					Коллекция = Новый Массив;
					Коллекция.Добавить(Элемент);
				КонецЕсли;
				
				Для Каждого Элемент Из Коллекция Цикл
					Вхождение = Новый Структура("FirstIndex, Length, Value");
					ЗаполнитьЗначенияСвойств(Вхождение, Элемент, "FirstIndex, Length, Value"); 
					Вхождения.Добавить(Вхождение);
				КонецЦикла;
				
			КонецЕсли; 
			
		КонецЕсли;
		
	КонецЕсли;
	
	Результат = Вхождения;
	Возврат Результат;
КонецФункции

// Replace
Функция Заменить(Знач ТекстГдеИскать, Знач ШаблонЗамены) Экспорт 
	Если ТекстГдеИскать = Неопределено Тогда
		ТекстГдеИскать = "";
	КонецЕсли; 
	Если ТекущийДвижок = "VBScript" Тогда
		Результат = Вычислитель().Replace(ТекстГдеИскать, ШаблонЗамены);
	Иначе
		Попытка
			Результат = Вычислитель().Replace(ТекстГдеИскать,, ШаблонЗамены);
		Исключение
			// После номера группы обязательно делать не цифру. Тогда будет работать одинаково в VBScript и PCRE2. Например вместо "$152" делать "$1 52", иначе PCRE2 будет читать "ссылка на группу 152"
			ВызватьИсключение Вычислитель().ОписаниеОшибки;
		КонецПопытки;
	КонецЕсли; 
	Возврат Результат;
КонецФункции

// Test
Функция Проверить(Знач ТекстГдеИскать) Экспорт 
	Если ТекстГдеИскать = Неопределено Тогда
		ТекстГдеИскать = "";
	КонецЕсли; 
	Если ТекущийДвижок = "VBScript" Тогда
		Результат = Вычислитель().Test(ТекстГдеИскать);
	Иначе
		Результат = Вычислитель().Test(ТекстГдеИскать);
	КонецЕсли;
	Возврат Результат;
КонецФункции

Функция КоличествоПодгрупп(Вхождение) Экспорт 
	Если ТипЗнч(Вхождение.SubMatches) = Тип("Массив") Тогда
		Результат = Вхождение.SubMatches.Количество();
	Иначе
		Результат = Вхождение.SubMatches.Count;
	КонецЕсли;
	Возврат Результат; 
КонецФункции

Функция ДоступенPCRE2() Экспорт 
	
	//Возврат ирКэш.НомерВерсииПлатформыЛкс() >= 803006;
	Возврат Истина;

КонецФункции

Функция ДоступенVBScript() Экспорт 
	
	//Возврат ирКэш.ЛиПлатформаWindowsЛкс();
	Возврат Ложь;

КонецФункции

Функция ДоступныеДвижки(ВернутьСтруктуру = Ложь) Экспорт 
	
	Если ВернутьСтруктуру И ДоступныеДвижкиСтруктура <> Неопределено Тогда
		Возврат ДоступныеДвижкиСтруктура;
	КонецЕсли; 
	Список = Новый СписокЗначений;
	Если ДоступенPCRE2() Тогда
		// https://www.pcre.org/current/doc/html
		// https://github.com/alexkmbk/RegEx1CAddin
		Список.Добавить("PCRE2"); 
	КонецЕсли; 
	Если ДоступенVBScript() Тогда
		Список.Добавить("VBScript");
	КонецЕсли; 
	Если ВернутьСтруктуру Тогда
		ДоступныеДвижкиСтруктура = Новый Структура;
		Для Каждого ЭлементСписка Из Список Цикл
			ДоступныеДвижкиСтруктура.Вставить(ЭлементСписка.Значение, ЭлементСписка.Значение);
		КонецЦикла;
		Список = ДоступныеДвижкиСтруктура;
	КонецЕсли; 
	Возврат Список;

КонецФункции

Функция ТекущийДвижок() Экспорт 
	
	Возврат ТекущийДвижок;

КонецФункции

Функция УстановитьДвижок(НовыйДвижок) Экспорт 
	
	Если ТекущийДвижок = НовыйДвижок Тогда
		Возврат Истина;
	КонецЕсли; 
	Если НовыйДвижок = "PCRE2" Тогда
		Если ДоступенPCRE2() Тогда
			ТекущийДвижок = НовыйДвижок;
		КонецЕсли; 
	ИначеЕсли НовыйДвижок = "VBScript" Тогда
		Если ДоступенVBScript() Тогда
			ТекущийДвижок = НовыйДвижок;
		КонецЕсли; 
	КонецЕсли;
	Если ТекущийДвижок = НовыйДвижок Тогда
		СтарыйGlobal = Неопределено;
		СтарыйIgnoreCase = Неопределено;
		СтарыйMultiline = Неопределено;
		СтарыйPattern = Неопределено;
		Вычислитель = Неопределено;
	КонецЕсли; 
	Возврат ТекущийДвижок = НовыйДвижок;
	
КонецФункции

Функция Вычислитель()
	Если Вычислитель = Неопределено Тогда
		Если ТекущийДвижок = "VBScript" Тогда
			Вычислитель = Новый COMОбъект("VBScript.RegExp");
		Иначе
			//мПлатформа = ирКэш.Получить();
			//#Если Сервер И Не Сервер Тогда
			//	мПлатформа = Обработки.ирПлатформа.Создать();
			//#КонецЕсли
			//Вычислитель = мПлатформа.ПолучитьОбъектВнешнейКомпонентыИзМакета("RegEx", "AddIn.ВычислительРегВыражений.RegEx", "ВычислительРегВыражений", ТипВнешнейКомпоненты.Native);
			
			// 27/01/23 Деградация до 8,3,15
			//Вычислитель = ОбщегоНазначения.ПодключитьКомпонентуИзМакета("RegEx", "ОбщийМакет.КомпонентаRegEx");
			ИмяМакетаВК = "ОбщийМакет.КомпонентаRegEx";
			ИмяОбъекта = "RegEx";
			ИмяКопмоненты = "ВычислительРегВыражений";
			ПолноеИмяОбъекта = "AddIn." + ИмяКопмоненты + "." + ИмяОбъекта;
			
			Если ПодключитьВнешнююКомпоненту(ИмяМакетаВК, ИмяКопмоненты, ТипВнешнейКомпоненты.Native) Тогда
				Вычислитель = Новый(ПолноеИмяОбъекта);
			Иначе
				ВызватьИсключение (ОписаниеОшибки());
			КонецЕсли;

			Вычислитель.ВызыватьИсключения = Истина;
			
		КонецЕсли; 
	КонецЕсли; 
	// Ускорение
	Если СтарыйGlobal <> Global Тогда
		Вычислитель.Global = Global;
		СтарыйGlobal = Global;
	КонецЕсли; 
	Если СтарыйIgnoreCase <> IgnoreCase Тогда 
		Вычислитель.IgnoreCase = IgnoreCase;
		СтарыйIgnoreCase = IgnoreCase;
	КонецЕсли; 
	Если СтарыйMultiline <> Multiline Тогда 
		Вычислитель.Multiline = Multiline;
		СтарыйMultiline = Multiline;
	КонецЕсли; 
	Если СтарыйPattern <> Pattern Тогда
		Вычислитель.Pattern = Pattern;
		СтарыйPattern = Pattern;
	КонецЕсли;
	Возврат Вычислитель;
КонецФункции

IgnoreCase = Истина;
Если ДоступенPCRE2() Тогда
	ТекущийДвижок = "PCRE2";
КонецЕсли; 
#Если Клиент Тогда
Если ДоступенVBScript() Тогда
	ТекущийДвижок = "VBScript";
КонецЕсли; 
#КонецЕсли 
