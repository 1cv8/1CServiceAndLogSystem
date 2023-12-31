///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура УстановкаПараметровСеанса(ИменаПараметровСеанса)
	
	// СтандартныеПодсистемы
	СтандартныеПодсистемыСервер.УстановкаПараметровСеанса(ИменаПараметровСеанса);
	// Конец СтандартныеПодсистемы
	
	УстановитьСтильПриложения();
		
КонецПроцедуры

#КонецОбласти

// _НастройкиПользователей 25/11/22
Процедура УстановитьСтильПриложения()
	
	ИмяСтиля = _НастройкиПользователейВызовСервера.ИмяСтиляПриложенияПользователя();
	Если НЕ ЗначениеЗаполнено(ИмяСтиля)
		ИЛИ ИмяСтиля = "ПоУмолчанию" Тогда
		Возврат;
	КонецЕсли;
	
	СтильПользователя = Неопределено;
	Попытка
		СтильПользователя = БиблиотекаСтилей[ИмяСтиля];
	Исключение
		СтильПользователя = Неопределено;
	КонецПопытки;
	
	Если ТипЗнч(СтильПользователя) = Тип("Стиль")
		И ГлавныйСтиль <> СтильПользователя Тогда
		
		ГлавныйСтиль = СтильПользователя;
	КонецЕсли;
	
КонецПроцедуры

#КонецЕсли