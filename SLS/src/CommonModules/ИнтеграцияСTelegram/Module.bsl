
Функция ОтправитьСообщениеГруппе(ГруппаПолучателей, ТекстСообщения, Таймаут = 10, Отладка = Ложь) Экспорт
	
	Результат = Новый Структура("Успех, ОписанияОшибок", Ложь, Новый Массив);
	
	Если НЕ ИнтеграцияСTelegramВызовСервераПовтИсп.ВключенаИнтеграцияСTelegram() Тогда
		Возврат Результат;
	КонецЕсли;
	
	УчетнаяЗапись = УчетнаяЗаписьГруппыПолучателей(ГруппаПолучателей);
	
	ЗащищенноеСоединение = Новый ЗащищенноеСоединениеOpenSSL();
	TokenTelegramm = УчетнаяЗапись.Token;
	
	ШаблонАдресаРесурса = "bot" + TokenTelegramm + "/sendMessage?chat_id=%IDUser%&text= " + ТекстСообщения;
	
	Для Каждого IDUser Из ВсеIDГруппыПолучателей(ГруппаПолучателей) Цикл
		
		Если НЕ ЗначениеЗаполнено(IDUser) Тогда
			Продолжить;
		КонецЕсли;
		
		АдресРесурса = СтрЗаменить(ШаблонАдресаРесурса, "%IDUser%", IDUser);
		
		Соединение = Новый HTTPСоединение("api.telegram.org",443,,,,Таймаут,ЗащищенноеСоединение);
		
		Запрос = Новый HTTPЗапрос(АдресРесурса);
		ОтветHTTP = Соединение.Получить(Запрос);  
		Если ОтветHTTP.КодСостояния = 200 Тогда

			Результат.Успех = Истина;
			Если Отладка Тогда
				Сообщить("Успешно отправлено получателю: " + IDUser);
			КонецЕсли;
			
		 Иначе

			 ТекстСообщения = "Не удалось начать отправку файла на удаленный сервис" + СообщениеОбОшибкеИзОтветаHTTP(ОтветHTTP);
			 ЗаписьЖурналаРегистрации(
			 	"TGОшибкаОтправки",
			 	УровеньЖурналаРегистрации.Ошибка,,,
				ТекстСообщения
			 );
			 
			Если Отладка Тогда
				Сообщить("Ошпибка отправки получателю: " + IDUser + " " + ТекстСообщения);
			КонецЕсли;
			 
		КонецЕсли;	
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция УчетнаяЗаписьГруппыПолучателей(ГруппаПолучателей) Экспорт
	
	Если НЕ ИнтеграцияСTelegramВызовСервераПовтИсп.ВключенаИнтеграцияСTelegram() Тогда
		Возврат Справочники.УчетныеЗаписиTelegram.ПустаяСсылка();
	КонецЕсли;

	УчетнаяЗапись = ГруппаПолучателей.TelegramBot;
	Если НЕ ЗначениеЗаполнено(УчетнаяЗапись) Тогда
		УчетнаяЗапись = УчетнаяЗаписьПоУмолчанию();
	КонецЕсли;
	
	Возврат УчетнаяЗапись;
	
КонецФункции

Функция УчетнаяЗаписьПоУмолчанию() Экспорт
	
	Если НЕ ИнтеграцияСTelegramВызовСервераПовтИсп.ВключенаИнтеграцияСTelegram() Тогда
		Возврат Справочники.УчетныеЗаписиTelegram.ПустаяСсылка();
	КонецЕсли;

	Возврат Константы.УчетнаяЗаписьTelegramПоУмолчанию.Получить();
	
КонецФункции

Функция СообщениеОбОшибкеИзОтветаHTTP(ОтветHTTP)
	
	СообщениеОбОшибке = "";
	
	Попытка
		
		Тело = ОтветHTTP.ПолучитьТелоКакСтроку();
		Если ЗначениеЗаполнено(Тело) Тогда
			СообщениеОбОшибке = Тело;
			
			Если СтрДлина(СообщениеОбОшибке) > 4096 Тогда
				СообщениеОбОшибке = Лев(СообщениеОбОшибке, 4096);
			КонецЕсли;
			
		КонецЕсли;
		
	Исключение
	КонецПопытки;
	
	Возврат СообщениеОбОшибке;
	
КонецФункции

Функция ВсеIDГруппыПолучателей(ГруппаПолучателей)
	
	Если _МАА_Процедуры.ЭтоРабочаяБаза() Тогда
		СписокПолучателей = Справочники.ГруппыПолучателейРассылок.ВсеПолучателейГруппы(ГруппаПолучателей);
	Иначе
		СписокПолучателей = Новый Массив;
		СписокПолучателей.Добавить(Пользователи.АвторизованныйПользователь().ФизическоеЛицо);
	КонецЕсли;
	Если СписокПолучателей.Количество() > 0 Тогда
		IDПолучателей = УправлениеКонтактнойИнформацией.КонтактнаяИнформацияОбъектов(СписокПолучателей,, Справочники.ВидыКонтактнойИнформации.TelegramIDФизическиеЛица).ВыгрузитьКолонку("Представление");
	Иначе
		IDПолучателей = Новый Массив;
	КонецЕсли;
	
	Если _МАА_Процедуры.ЭтоРабочаяБаза() Тогда
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("Рассылка", ГруппаПолучателей);
		
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ГруппыПолучателейРассылокПолучатели.Получатель.TelegramID КАК TelegramID
		|ИЗ
		|	Справочник.ГруппыПолучателейРассылок.ГруппыПолучатели КАК ГруппыПолучателейРассылокПолучатели
		|ГДЕ
		|	ГруппыПолучателейРассылокПолучатели.Ссылка = &Рассылка
		|	И НЕ ГруппыПолучателейРассылокПолучатели.Отключить
		|	И ГруппыПолучателейРассылокПолучатели.Получатель <> ЗНАЧЕНИЕ(Справочник.ПочтовыеГруппыИЧаты.ПустаяСсылка)
		|
		|СГРУППИРОВАТЬ ПО
		|	ГруппыПолучателейРассылокПолучатели.Получатель,
		|	ГруппыПолучателейРассылокПолучатели.Получатель.TelegramID
		|
		|ОБЪЕДИНИТЬ
		|
		|ВЫБРАТЬ
		|	ГруппыПолучателейРассылокКопии.Получатель.TelegramID
		|ИЗ
		|	Справочник.ГруппыПолучателейРассылок.ГруппыКопии КАК ГруппыПолучателейРассылокКопии
		|ГДЕ
		|	ГруппыПолучателейРассылокКопии.Ссылка = &Рассылка
		|	И НЕ ГруппыПолучателейРассылокКопии.Отключить
		|	И ГруппыПолучателейРассылокКопии.Получатель <> ЗНАЧЕНИЕ(Справочник.ПочтовыеГруппыИЧаты.ПустаяСсылка)
		|
		|СГРУППИРОВАТЬ ПО
		|	ГруппыПолучателейРассылокКопии.Получатель,
		|	ГруппыПолучателейРассылокКопии.Получатель.TelegramID";

		IDЧатов = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("TelegramID");
		
		ОбщегоНазначенияКлиентСервер.ДополнитьМассив(IDПолучателей, IDЧатов, Истина);
		
	КонецЕсли;
	
	Возврат IDПолучателей;
	
КонецФункции
