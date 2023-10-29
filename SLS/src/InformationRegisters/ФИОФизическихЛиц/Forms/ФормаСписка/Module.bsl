
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийТаблицыФормыСписок

&НаКлиенте
Процедура СписокПередУдалением(Элемент, Отказ)
	
	СписокФизическихЛиц.Очистить();
	
	Если Элементы.Список.ВыделенныеСтроки.Количество() > 0 Тогда
		
		Для Каждого ТекСтр Из Элементы.Список.ВыделенныеСтроки Цикл
			Если СписокФизическихЛиц.НайтиПоЗначению(ТекСтр.ФизическоеЛицо) = Неопределено Тогда
				СписокФизическихЛиц.Добавить(ТекСтр.ФизическоеЛицо);
			КонецЕсли;
		КонецЦикла;
		
	ИначеЕсли Элементы.Список.ТекущиеДанные <> Неопределено Тогда
		
		СписокФизическихЛиц.Добавить(Элементы.Список.ТекущиеДанные.ФизическоеЛицо);
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СписокПослеУдаления(Элемент)
	
	ПараметрОповещения = Новый Структура("ИмяРегистра", "ФИОФизическихЛиц");
	
	Для Каждого ТекСтр Из СписокФизическихЛиц Цикл
		Оповестить("ИзмененыЛичныеДанные", ПараметрОповещения, ТекСтр.Значение);
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти
