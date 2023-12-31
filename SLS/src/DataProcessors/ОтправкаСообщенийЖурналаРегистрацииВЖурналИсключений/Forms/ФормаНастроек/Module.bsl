&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ЗагрузитьНастройки();
КонецПроцедуры
	
&НаСервере 
Процедура ЗаполнитьТаблицуНастройкиСтруктурыСообщения(ИмяТаблицы, ИмяКолонки)	
	
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	СЗКолонокЖурналаРегистрации = ОбработкаОбъект.ПолучитьСписокКолонокЖурналаРегистрации();
	ЗначениеВРеквизитФормы(ОбработкаОбъект, "Объект");  
	
	Объект[ИмяТаблицы].Очистить();
	
	Для Каждого СтрокаСЗКолонокЖурналаРегистрации Из СЗКолонокЖурналаРегистрации Цикл
		
		НоваяСтрока = Объект[ИмяТаблицы].Добавить();
		НоваяСтрока[ИмяКолонки] = СтрокаСЗКолонокЖурналаРегистрации.Значение;
		НоваяСтрока.Имя 	  	= СтрокаСЗКолонокЖурналаРегистрации.Представление;
		
	КонецЦикла; 
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьНастройки()
	
	СтруктураНастроек = ЗагрузитьНастройкиНаСервере();
	
	Если СтруктураНастроек = Неопределено Тогда
		
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = НСтр("ru = 'Настроек не обнаружено. Необходимо заполнить настройки и сохранить!'");
		Сообщение.Сообщить();
		
		Возврат;
		
	КонецЕсли; 
	
	ЗагрузитьНастройкиПоСтруктураНастроек(СтруктураНастроек);
	
КонецПроцедуры

&НаСервере
Функция ЗагрузитьНастройкиНаСервере()
	Возврат ХранилищеОбщихНастроек.Загрузить("СтруктураНастроекВыгрузкиВSentry", "ОбщиеНастройки",, "AutoStart");
КонецФункции
 
 &НаСервере
Функция НайтиПользователяПоИмениНаСервере(ПользовательВыгрузки)
	Возврат Пользователи.НайтиПоИмени(ПользовательВыгрузки);	
КонецФункции

&НаСервере
Процедура ЗагрузитьНастройкиПоСтруктураНастроек(СтруктураНастроек)
	
	НастройкиПодключения = СтруктураНастроек.НастройкиПодключения;
	
	Попытка
		Для Каждого ЭлементНастроекПодключения Из НастройкиПодключения Цикл
			Объект[ЭлементНастроекПодключения.Ключ] = ЭлементНастроекПодключения.Значение;
		КонецЦикла; 
	Исключение
	КонецПопытки;
	
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	СтруктураДат = ОбработкаОбъект.ПолучитьВсеНеобходимыеДаты(Ложь, Неопределено);
	
	//ДатаНачала 								= СтруктураДат.ДатаНачала;
	//ДатаОкончания 							= СтруктураДат.ДатаОкончания;
	//ДатаНачалаОтправки 						= СтруктураДат.ДатаНачалаОтправки;
	//ДатаПервогоСообщения 					= СтруктураДат.ДатаПервогоСообщения;
	ДатаПоследнегоСообщения 				= СтруктураДат.ДатаПоследнегоСообщения;
	//ДатаЧтенияЖурналаРегистрацииНачало		= СтруктураДат.ДатаЧтенияЖурналаРегистрацииНачало;
	//ДатаЧтенияЖурналаРегистрацииОкончание	= СтруктураДат.ДатаЧтенияЖурналаРегистрацииОкончание;
	
КонецПроцедуры

&НаСервере
Процедура ПроверкаНастроек(ПроверкаНастроекПройдена)
		
	МассивПроверяемыхПолей = Новый Массив;
	МассивПроверяемыхПолей.Добавить("Host");
	МассивПроверяемыхПолей.Добавить("АдресРесурса");

	//МассивПроверяемыхПолей.Добавить("Port");
	//МассивПроверяемыхПолей.Добавить("TimeOut");

	МассивПроверяемыхПолей.Добавить("ID_project");
	МассивПроверяемыхПолей.Добавить("Level");
	МассивПроверяемыхПолей.Добавить("КоличествоЗаписейЗаРаз");
	
	ПровестиПроверкуЗаполненияОбязательныхПолей(МассивПроверяемыхПолей, ПроверкаНастроекПройдена);
	
КонецПроцедуры

&НаСервере
Процедура ПровестиПроверкуЗаполненияОбязательныхПолей(МассивПроверяемыхПолей, ПроверкаНастроекПройдена)
	
	ПроверкаНастроекПройдена = Истина;
	
	Обработка = ДанныеФормыВЗначение(Объект, ТипЗнч(РеквизитФормыВЗначение("Объект")));    
	
	УстановитьСоответствиеОбъектаИРеквизитаФормы(Обработка, "Объект");
	
	//Проверка полей из шапки
	Для Каждого ЭлементМассиваПроверяемыхПолей Из МассивПроверяемыхПолей Цикл
	
		Если НЕ ЗначениеЗаполнено(Объект[ЭлементМассиваПроверяемыхПолей]) Тогда
					             			
			Сообщение = Новый СообщениеПользователю();
		    Сообщение.Текст = НСтр("ru = 'Не заполнено обязательное поле:" + Элементы[ЭлементМассиваПроверяемыхПолей].Имя + "'");
		    Сообщение.Поле 	= ЭлементМассиваПроверяемыхПолей;
		    Сообщение.УстановитьДанные(Обработка);
		    Сообщение.Сообщить();

			ПроверкаНастроекПройдена = Ложь;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Если Модифицированность = Истина Тогда
		
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = НСтр("ru = 'Настройки были изменены! Необходимо их сохранить или загрузить заново!'");
		Сообщение.Сообщить();
		
		ПроверкаНастроекПройдена = Ложь;

	КонецЕсли; 
	
КонецПроцедуры

&НаСервере
Процедура СохранитьНастройки()
	
	ПроверкаНастроек(ПроверкаНастроекПройдена);
	
	//Если НЕ ПроверкаНастроекПройдена Тогда
	//	Возврат;
	//КонецЕсли; 
	
	//Отборы по отмеченным строкам
	СтруктураОтбора = Новый Структура;
	СтруктураОтбора.Вставить("Использовать", Истина);
	
	//Настройки из шапки
	НастройкиПодключения = Новый Структура;
	НастройкиПодключения.Вставить("Host"					, Объект.Host);
	НастройкиПодключения.Вставить("Port"					, Объект.Port);
	НастройкиПодключения.Вставить("TimeOut"					, Объект.TimeOut);
	НастройкиПодключения.Вставить("ID_project"				, Объект.ID_project);
	НастройкиПодключения.Вставить("Level"					, Объект.Level);
	НастройкиПодключения.Вставить("КоличествоЗаписейЗаРаз"	, Объект.КоличествоЗаписейЗаРаз);
	НастройкиПодключения.Вставить("АдресРесурса"	        , Объект.АдресРесурса);
	НастройкиПодключения.Вставить("Пользователь"	        , Объект.Пользователь);
	НастройкиПодключения.Вставить("Пароль"        	        , Объект.Пароль);
	
	
	//Все настройки	
	СтруктураНастроек = Новый Структура;
	СтруктураНастроек.Вставить("НастройкиПодключения", НастройкиПодключения);
	
	ХранилищеОбщихНастроек.Сохранить("СтруктураНастроекВыгрузкиВSentry", "ОбщиеНастройки", СтруктураНастроек,, "AutoStart");
	
 КонецПроцедуры

&НаСервере
Процедура СброситьДату()
	ХранилищеОбщихНастроек.Сохранить("СтруктураНастроекВыгрузкиВSentry", "ДатаПоследнегоСообщения", НачинатьСДаты,, "AutoStart");
КонецПроцедуры

&НаСервере
Функция ЗначениеВСтрокуXML(Значение)
	
	ЗаписьXML = Новый ЗаписьXML;
	ЗаписьXML.УстановитьСтроку();
	СериализаторXDTO.ЗаписатьXML(ЗаписьXML, Значение, НазначениеТипаXML.Явное);
	
	Возврат ЗаписьXML.Закрыть();
	
КонецФункции

&НаСервере
Функция ЗначениеИзСтрокиXML(СтрокаXML)
	
	ЧтениеXML = Новый ЧтениеXML;
	ЧтениеXML.УстановитьСтроку(СтрокаXML);
	
	Возврат СериализаторXDTO.ПрочитатьXML(ЧтениеXML);
	
КонецФункции

&НаСервере
Процедура ОтправитьСообщениеЧерезHTTPSНаСервере(ПроверкаНастроекПройдена)
	
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	ОбработкаОбъект.ОтправитьСообщенияЧерезHTTPSНаСервере(Истина, ПроверкаНастроекПройдена, НачинатьСДаты, Результат_ID);
	ЗначениеВРеквизитФормы(ОбработкаОбъект, "Объект");  
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаЗаполнитьТэги(Команда)
	
	ЗаполнитьТаблицуНастройкиСтруктурыСообщения("Тэги", "Тэг");
	Модифицированность = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаЗаполнитьЗаголовки(Команда)
	
	ЗаполнитьТаблицуНастройкиСтруктурыСообщения("ЗаголовкиСообщения", "Заголовок");	
	Модифицированность = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаЗаполнитьТело(Команда)
	
	ЗаполнитьТаблицуНастройкиСтруктурыСообщения("ТелоСообщения", "Тело");		
	Модифицированность = Истина;
	
КонецПроцедуры

&НаКлиенте	
Процедура КомандаОтправитьСообщениеЧерезHTTPSКлиент(Команда)
	
	ПроверкаНастроек(ПроверкаНастроекПройдена);
	ОтправитьСообщениеЧерезHTTPSНаСервере(ПроверкаНастроекПройдена);
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаПроверкаНастроек(Команда)
	
	ПроверкаНастроек(ПроверкаНастроекПройдена);
	
	Если ПроверкаНастроекПройдена Тогда
		
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = НСтр("ru = 'Проверка пройдена!'");
		Сообщение.Сообщить();
		
	КонецЕсли; 
	
КонецПроцедуры
	
&НаКлиенте
Процедура КомандаСохранитьНастройки(Команда)
	
	Модифицированность = Ложь;
	СохранитьНастройки();
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаЗагрузитьНастройки(Команда)
	
	ЗагрузитьНастройки();	
	Модифицированность = Ложь;
	
КонецПроцедуры
	
&НаКлиенте
Процедура ТелоСообщенияПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	Отказ = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ТэгиПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	Отказ = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ЗаголовкиСообщенияПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	Отказ = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ЗаголовкиСообщенияПередУдалением(Элемент, Отказ)
	Отказ = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ТэгиПередУдалением(Элемент, Отказ)
	Отказ = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ТелоСообщенияПередУдалением(Элемент, Отказ)
	Отказ = Истина;
КонецПроцедуры

&НаКлиенте
Процедура КомандаСброситьДату(Команда)
	
	СброситьДату();
	Модифицированность = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура НачинатьСДатыПриИзменении(Элемент)
	Модифицированность = Истина;
КонецПроцедуры

&НаКлиенте
Процедура HostПриИзменении(Элемент)
	Модифицированность = Истина;
КонецПроцедуры

&НаКлиенте
Процедура PortПриИзменении(Элемент)
	Модифицированность = Истина;
КонецПроцедуры

&НаКлиенте
Процедура TimeOutПриИзменении(Элемент)
	Модифицированность = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ЗаголовкиСообщенияПриИзменении(Элемент)
	Модифицированность = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ТэгиПриИзменении(Элемент)
	Модифицированность = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ТелоСообщенияПриИзменении(Элемент)
	Модифицированность = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ID_projectПриИзменении(Элемент)
	Модифицированность = Истина;
КонецПроцедуры

&НаКлиенте
Процедура LevelПриИзменении(Элемент)
	Модифицированность = Истина;
КонецПроцедуры

&НаКлиенте
Процедура КоличествоЗаписейЗаРазПриИзменении(Элемент)
	Модифицированность = Истина;
КонецПроцедуры

&НаКлиенте
Процедура КомандаВыгрузитьНастройкиВФайл(Команда)
	
	Режим = РежимДиалогаВыбораФайла.Сохранение; 
	
	ДиалогСохраненияФайла = Новый ДиалогВыбораФайла(Режим); 
	ДиалогСохраненияФайла.ПолноеИмяФайла = "Настройки_выгрузки_в_Sentry_" + Формат(ТекущаяДата(), "ДФ=M_yy"); 
	
	Фильтр = "XML(*.xml)|*.xml";                 
	
	ДиалогСохраненияФайла.Фильтр 				= Фильтр; 
	ДиалогСохраненияФайла.МножественныйВыбор 	= Ложь; 
	ДиалогСохраненияФайла.Заголовок 			= "Выберите файл"; 
	
	Если ДиалогСохраненияФайла.Выбрать() Тогда 
		
		ПутьКФайлуДляЗаписи = ДиалогСохраненияФайла.ПолноеИмяФайла; 
		СохранитьДанныеВФайлВФорматеXML(ПутьКФайлуДляЗаписи);
 
	КонецЕсли;   
	
КонецПроцедуры

&НаКлиенте
Процедура СохранитьДанныеВФайлВФорматеXML(ПутьКФайлуДляЗаписи)
	
	ПроверкаНастроек(ПроверкаНастроекПройдена);
	
	Если НЕ ПроверкаНастроекПройдена Тогда
		Возврат;
	КонецЕсли; 
	
	СтруктураНастроек = ЗагрузитьНастройкиНаСервере();

	Если СтруктураНастроек = Неопределено Тогда
		
		Сообщение = Новый СообщениеПользователю();
	    Сообщение.Текст = НСтр("ru = 'Настроек не обнаружено!'");
	    Сообщение.Сообщить();
		
		Возврат;
		
	КонецЕсли; 
	
	СтруктураНастроек.НастройкиПодключения.ПользовательВыгрузки = Строка(СтруктураНастроек.НастройкиПодключения.ПользовательВыгрузки);
	
	СтруктураНастроекXML = ЗначениеВСтрокуXML(СтруктураНастроек);
	
	Файл = Новый ЗаписьТекста(ПутьКФайлуДляЗаписи);
	Файл.ЗаписатьСтроку(СтруктураНастроекXML);
	Файл.Закрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаЗагрузитьНастройкиИзФайла(Команда)
	
	Режим = РежимДиалогаВыбораФайла.Открытие; 
	
	ДиалогЗагрузкиФайла = Новый ДиалогВыбораФайла(Режим); 
	
	Фильтр = "XML(*.xml)|*.xml";                 
	
	ДиалогЗагрузкиФайла.Фильтр 				= Фильтр; 
	ДиалогЗагрузкиФайла.МножественныйВыбор 	= Ложь; 
	ДиалогЗагрузкиФайла.Заголовок 			= "Выберите файл"; 
	
	Если ДиалогЗагрузкиФайла.Выбрать() Тогда 
		
		ПутьКФайлуДляЗагрузки = ДиалогЗагрузкиФайла.ПолноеИмяФайла; 
		ЗагрузитьДанныеИзФайлаВФорматеXML(ПутьКФайлуДляЗагрузки);
 
	КонецЕсли; 
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьДанныеИзФайлаВФорматеXML(ПутьКФайлуДляЗагрузки)
	
	Файл = Новый ЧтениеТекста(ПутьКФайлуДляЗагрузки);
	СтруктураНастроекXML = Файл.Прочитать();
	Файл.Закрыть();
	
	Если СтруктураНастроекXML = "" Тогда
		
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = НСтр("ru = 'Настроек не обнаружено!'");
		Сообщение.Сообщить();
		
		Возврат;
		
	Иначе
		
		СтруктураНастроек = ЗначениеИзСтрокиXML(СтруктураНастроекXML);
		
		Если ТипЗнч(СтруктураНастроек) = Тип("Структура") Тогда
			
			Попытка		
				
				СтруктураНастроек.НастройкиПодключения.ПользовательВыгрузки = НайтиПользователяПоИмениНаСервере(СтруктураНастроек.НастройкиПодключения.ПользовательВыгрузки);
				
				Если НЕ ЗначениеЗаполнено(СтруктураНастроек.НастройкиПодключения.ПользовательВыгрузки) Тогда
					
					Сообщение = Новый СообщениеПользователю();
					Сообщение.Текст = НСтр("ru = 'Неудалось заполнить пользователя выгрузки! Необходимое его заполнить вручную'");
					Сообщение.Сообщить();
					
				КонецЕсли; 
				
			Исключение
				
				Сообщение = Новый СообщениеПользователю();
				Сообщение.Текст = НСтр("ru = 'Неудалось заполнить пользователя выгрузки! Необходимое его заполнить вручную'");
				Сообщение.Сообщить();
				
			КонецПопытки;
			
			ЗагрузитьНастройкиПоСтруктураНастроек(СтруктураНастроек);
			
		КонецЕсли;
		
	КонецЕсли; 
	
КонецПроцедуры
