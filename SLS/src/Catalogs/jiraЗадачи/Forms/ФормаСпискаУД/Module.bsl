
&НаКлиенте
Процедура СписокПриАктивизацииСтроки(Элемент)
	РаботыВЗадаче.Очистить();
	Если Элементы.Список.ТекущаяСтрока <> Неопределено Тогда
		ДанныеТекущейСтроки = Элементы.Список.ДанныеСтроки(Элементы.Список.ТекущаяСтрока);
		ЗаполнитьРаботыВЗадаче(ДанныеТекущейСтроки.Ссылка);
	КонецЕсли;
КонецПроцедуры 

&НаСервере
Процедура ЗаполнитьРаботыВЗадаче(ЗадачаСсылка)
	ТекстЗапроса = "ВЫБРАТЬ
	               |	jiraСписанноеВремяПоЗадаче.Задача КАК Задача,
	               |	jiraСписанноеВремяПоЗадаче.id КАК id,
	               |	jiraСписанноеВремяПоЗадаче.ДатаСоздания КАК ДатаСоздания,
	               |	jiraСписанноеВремяПоЗадаче.ДатаСтарта КАК ДатаСтарта,
	               |	jiraСписанноеВремяПоЗадаче.ДатаОбновления КАК ДатаОбновления,
	               |	jiraСписанноеВремяПоЗадаче.АвторОбновления КАК АвторОбновления,
	               |	jiraСписанноеВремяПоЗадаче.ВремяВСекундах КАК ВремяВСекундах,
	               |	jiraСписанноеВремяПоЗадаче.Комментарий КАК Комментарий
	               |ИЗ
	               |	РегистрСведений.jiraСписанноеВремяПоЗадаче КАК jiraСписанноеВремяПоЗадаче
	               |ГДЕ
	               |	jiraСписанноеВремяПоЗадаче.Задача = &ЗадачаСсылка";
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("ЗадачаСсылка", ЗадачаСсылка);
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		НоваяСтрока = РаботыВЗадаче.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Выборка);
	КонецЦикла;
КонецПроцедуры
