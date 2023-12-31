
Функция ЭтоРабочаяБаза() Экспорт
	
	ЭтоРаб =
		СтрНайти(НРег(СтрокаСоединенияИнформационнойБазы()), "ref=""sdoplog"";") > 0
		И НЕ РегламентныеЗаданияСервер.РаботаСВнешнимиРесурсамиЗаблокирована();
	
	Возврат ЭтоРаб;
	
КонецФункции

Функция УдалитьНедопустимыеСимволы(ОбрабатываемаяСтрока) Экспорт
	
	Стр = ОбрабатываемаяСтрока;
	СтрокаЗамены = "<>/\*?:|«»"""+Символы.Таб+Символы.НПП;
	Для Ном=1 по СтрДлина(СтрокаЗамены) Цикл
		Стр = СтрЗаменить(Стр, Сред(СтрокаЗамены, Ном, 1), " ");	
	КонецЦикла;
	
	Возврат Стр;
	
КонецФункции


Процедура _ОтложеннаяОтправкаПисем() Экспорт

	ЗамерВеремни = ОценкаПроизводительности.НачатьЗамерВремени();
		
	ТекущаяДата = ТекущаяДата(); 	
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	УС_ОчередьПочта.Период КАК Период,
	|	УС_ОчередьПочта.Документ КАК Документ,
	|	УС_ОчередьПочта.УникальныйИдентификатор КАК УникальныйИдентификатор,
	|	УС_ОчередьПочта.Отправитель КАК Отправитель,
	|	УС_ОчередьПочта.КогдаОтправить КАК КогдаОтправить,
	|	УС_ОчередьПочта.АдресатДоставки КАК АдресатДоставки,
	|	УС_ОчередьПочта.Копии КАК Копии,
	|	УС_ОчередьПочта.СкрытыеКопии КАК СкрытыеКопии,
	|	УС_ОчередьПочта.Тема КАК Тема,
	|	УС_ОчередьПочта.Текст КАК Текст,
	|	УС_ОчередьПочта.ВысокаяВажность КАК ВысокаяВажность,
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
	|	РегистрСведений.УС_ОчередьПочта КАК УС_ОчередьПочта
	|ГДЕ
	|	НЕ УС_ОчередьПочта.Отправлено
	|	И НЕ УС_ОчередьПочта.ОшибкаОтправки
	|	И УС_ОчередьПочта.КогдаОтправить МЕЖДУ &ДатаНач И &ДатаКон
	|
	|УПОРЯДОЧИТЬ ПО
	|	КогдаОтправить";
	Запрос.УстановитьПараметр("ДатаНач", НачалоДня(ТекущаяДата()));	
	Запрос.УстановитьПараметр("ДатаКон", КонецДня(ТекущаяДата()));	
	
	РезультатЗапроса = Запрос.Выполнить().Выгрузить();
	
	ДанныеНаОтправку = РезультатЗапроса.Скопировать();
	ДанныеНаОтправку.Очистить();
	Для каждого Стр из  РезультатЗапроса Цикл
		Если НачалоДня(Стр.КогдаОтправить) = НачалоДня(ТекущаяДата) Тогда
			Если ТекущаяДата >= Стр.КогдаОтправить  Тогда
				
				НовСтр = ДанныеНаОтправку.Добавить();
				ЗаполнитьЗначенияСвойств(НовСтр,Стр);
				
			КонецЕсли;	
		КонецЕсли;	
	КонецЦикла;
	
	Если ДанныеНаОтправку.Количество() > 0 Тогда
		
		РегистрыСведений.УС_ОчередьПочта.ОтправитьПисьма(ДанныеНаОтправку);
		
		ОценкаПроизводительности.ЗакончитьЗамерВремени("Регламент._УС_ОтложеннаяОтправкаПисем", ЗамерВеремни, ДанныеНаОтправку.Количество());
		
	КонецЕсли;	
	
КонецПроцедуры	
