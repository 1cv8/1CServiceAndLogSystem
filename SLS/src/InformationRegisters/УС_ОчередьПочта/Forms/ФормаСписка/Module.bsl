
//&НаСервере
//Процедура ОтправитьСейчасНаСервере()
//	// Вставить содержимое обработчика.
//КонецПроцедуры

&НаСервере
Процедура ПолучитьСодержимое(Знач ВыделенСтр)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	УС_ОчередьПочта.Период КАК Период,
	|	УС_ОчередьПочта.Документ КАК Документ,
	|	УС_ОчередьПочта.УникальныйИдентификатор КАК УникальныйИдентификатор
	|ИЗ
	|	РегистрСведений.УС_ОчередьПочта КАК УС_ОчередьПочта
	|ГДЕ
	|	ЛОЖЬ";
	
	ВТ = Запрос.Выполнить().Выгрузить();
	ВТ.Очистить();

	Для каждого стр из ВыделенСтр Цикл
		НовСтр = ВТ.Добавить();
		НовСтр.Период = стр.Период;
		//НовСтр.Документ = стр.Документ;
		НовСтр.УникальныйИдентификатор = стр.УникальныйИдентификатор;
	КонецЦикла;	
	
	Запрос = Новый Запрос;
	// Романов 12/05/2022 dev-870 + ПутьКФайлу, ИмяСохраняемогоФайла, КоличествоПопытокОтправки, ДатаПопыткиОтправки
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВТ.Период КАК Период,
		|	ВТ.УникальныйИдентификатор КАК УникальныйИдентификатор
		|ПОМЕСТИТЬ ВТ
		|ИЗ
		|	&ВТ КАК ВТ
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	УС_ОчередьПочта.Период КАК Период,
		|	УС_ОчередьПочта.Документ КАК Документ,
		|	УС_ОчередьПочта.Отправитель КАК Отправитель,
		|	УС_ОчередьПочта.КогдаОтправить КАК КогдаОтправить,
		|	УС_ОчередьПочта.АдресатДоставки КАК АдресатДоставки,
		|	УС_ОчередьПочта.Копии КАК Копии,
		|	УС_ОчередьПочта.СкрытыеКопии КАК СкрытыеКопии,
		|	УС_ОчередьПочта.Тема КАК Тема,
		|	УС_ОчередьПочта.Текст КАК Текст,
		|	УС_ОчередьПочта.Вложения КАК Вложения,
		|	УС_ОчередьПочта.Отправлено КАК Отправлено,
		|	УС_ОчередьПочта.ВысокаяВажность КАК ВысокаяВажность,
		|	УС_ОчередьПочта.УникальныйИдентификатор КАК УникальныйИдентификатор,
		|	УС_ОчередьПочта.ПредставлениеОтправителя КАК ПредставлениеОтправителя,
		|	УС_ОчередьПочта.ПутьКФайлу КАК ПутьКФайлу,
		|	УС_ОчередьПочта.ИмяСохраняемогоФайла КАК ИмяСохраняемогоФайла,
		|	УС_ОчередьПочта.КоличествоПопытокОтправки КАК КоличествоПопытокОтправки,
		|	УС_ОчередьПочта.ДатаПопыткиОтправки КАК ДатаПопыткиОтправки,
		|	УС_ОчередьПочта.ОтправкаCDO КАК ОтправкаCDO,
		|	УС_ОчередьПочта.ОтветКому КАК ОтветКому,
		|	УС_ОчередьПочта.ИдентификаторСообщения КАК ИдентификаторСообщения,
		|	УС_ОчередьПочта.ИдентификаторыОснований КАК ИдентификаторыОснований
		|ИЗ
		|	ВТ КАК ВТ
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.УС_ОчередьПочта КАК УС_ОчередьПочта
		|		ПО ВТ.Период = УС_ОчередьПочта.Период
		|			И ВТ.УникальныйИдентификатор = УС_ОчередьПочта.УникальныйИдентификатор";
	Запрос.УстановитьПараметр("ВТ",ВТ);
	РезультатЗапроса = Запрос.Выполнить().Выгрузить();
	
	ОтправитьСейчасНаСервере(РезультатЗапроса);
	
КонецПроцедуры	

&НаСервере
Процедура ПолучитьСодержимоеДляУдаления(Знач ВыделенСтр)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	УС_ОчередьПочта.Период,
		|	УС_ОчередьПочта.Документ,
		|	УС_ОчередьПочта.УникальныйИдентификатор
		|ИЗ
		|	РегистрСведений.УС_ОчередьПочта КАК УС_ОчередьПочта";
	
	ВТ = Запрос.Выполнить().Выгрузить();
	
	ВТ.Очистить();

	Для каждого стр из ВыделенСтр Цикл
		НовСтр = ВТ.Добавить();
		НовСтр.Период = стр.Период;
		НовСтр.Документ = стр.Документ;
		НовСтр.УникальныйИдентификатор = стр.УникальныйИдентификатор;
	КонецЦикла;
	
	ЗначениеВРеквизитФормы(ВТ, "ТЗДляУдаления");
		
КонецПроцедуры	



&НаКлиенте
Процедура ОтправитьСейчас(Команда)
	
	ПолучитьСодержимое(Элементы.Список.ВыделенныеСтроки);

КонецПроцедуры

&НаСервере
Процедура ОтправитьСейчасНаСервере(Данные)
	
	РегистрыСведений.УС_ОчередьПочта.ОтправитьПисьма(Данные, Истина);
	
КонецПроцедуры	
&НаСервере
Функция ПолучитьХранилище(Струк)
	Результат = Неопределено;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	УС_ОчередьПочта.Вложения
		|ИЗ
		|	РегистрСведений.УС_ОчередьПочта КАК УС_ОчередьПочта
		|ГДЕ
		|	УС_ОчередьПочта.Период = &Период
		|	И УС_ОчередьПочта.Документ = &Документ";
	Запрос.УстановитьПараметр("Документ", Струк.Документ);
	Запрос.УстановитьПараметр("Период", Струк.Период);
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		Результат = Выборка.Вложения;
	КонецЕсли;
	
	Возврат Результат;	
	
	
КонецФункции

&НаКлиенте
Процедура ОтметитьВыбранноеКОтправке(Команда)
	//Элементы.Список.
	// Вставить содержимое обработчика.
КонецПроцедуры

&НаСервере
Процедура ОчиститьХранилищеВыбранныхПисемНаСервере(Струк)
	
	НаборЗаписей = РегистрыСведений.УС_ОчередьПочта.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Период.Установить(Струк.Период);
	НаборЗаписей.Отбор.Документ.Установить(Струк.Документ);
	НаборЗаписей.Отбор.УникальныйИдентификатор.Установить(Струк.УникальныйИдентификатор);
	НаборЗаписей.Прочитать();
	Для Каждого Строка Из НаборЗаписей Цикл
		Строка.Вложения = Новый ХранилищеЗначения(Неопределено); 	
	КонецЦикла;

	НаборЗаписей.Записать();	
	
КонецПроцедуры

&НаКлиенте
Процедура ОчиститьХранилищеВыбранныхПисем(Команда)
	
	ТЗДляУдаления.Очистить();
	
	ПолучитьСодержимоеДляУдаления(Элементы.Список.ВыделенныеСтроки);
	
	КолВо = ТЗДляУдаления.Количество();
	Сч = 0;
	
	Для Каждого ВыделенСтр Из ТЗДляУдаления Цикл
		Струк = Новый Структура;
		Струк.Вставить("Период", ВыделенСтр.Период); 
		Струк.Вставить("Документ", ВыделенСтр.Документ); 
		Струк.Вставить("УникальныйИдентификатор", ВыделенСтр.УникальныйИдентификатор); 
	
		ОчиститьХранилищеВыбранныхПисемНаСервере(Струк);
		
		Сч = Сч + 1;
		Состояние("Очищено: "+Строка(Сч)+" / "+ Строка(КолВо));
		
	КонецЦикла;	
	
КонецПроцедуры

&НаКлиенте
Процедура СписокПриАктивизацииСтроки(Элемент)
	
	ТекстовкаHTML = "";
	
	ТекущиеДанные = Элементы.Список.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ТекстовкаHTML = ТекстHTML(Элементы.Список.ТекущиеДанные.Текст);
	
КонецПроцедуры

&НаКлиенте
Функция ТекстHTML(Знач ТекстHTML)
	
	НРегТекстHTML = ТекстHTML;
	НРегТекстHTML = СтрЗаменить(НРегТекстHTML, " ", "");
	НРегТекстHTML = СтрЗаменить(НРегТекстHTML, Символы.Таб, "");
	НРегТекстHTML = СтрЗаменить(НРегТекстHTML, Символы.ВТаб, "");
	НРегТекстHTML = СтрЗаменить(НРегТекстHTML, Символы.НПП, "");
	НРегТекстHTML = СтрЗаменить(НРегТекстHTML, Символы.ПС, "");
	НРегТекстHTML = СтрЗаменить(НРегТекстHTML, Символы.ВК, "");
	НРегТекстHTML = СтрЗаменить(НРегТекстHTML, Символы.ПФ, "");
	
	Если СтрНайти(НРегТекстHTML, "<html") > 0
		ИЛИ СтрНайти(НРегТекстHTML, "</html") > 0 Тогда
		Возврат ТекстHTML;
	КонецЕсли;
	
	Если СтрНайти(НРегТекстHTML, "</p>") > 0 Тогда
		Возврат "<html>" + ТекстHTML + "</html>";
	КонецЕсли;

	Возврат "<html><p>" + ТекстHTML + "</p></html>";

КонецФункции