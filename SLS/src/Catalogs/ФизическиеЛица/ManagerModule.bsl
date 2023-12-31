#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

// Определяет настройки объекта для подсистемы ВерсионированиеОбъектов.
//
// Параметры:
//  Настройки - Структура - настройки подсистемы.
Процедура ПриОпределенииНастроекВерсионированияОбъектов(Настройки) Экспорт

КонецПроцедуры

// Конец СтандартныеПодсистемы.ВерсионированиеОбъектов

#Область ДляВызоваИзДругихПодсистем

//// СтандартныеПодсистемы.УправлениеДоступом
//
//// См. УправлениеДоступомПереопределяемый.ПриЗаполненииСписковСОграничениемДоступа.
//Процедура ПриЗаполненииОграниченияДоступа(Ограничение) Экспорт
//	Ограничение.Текст =
//	"ПрисоединитьДополнительныеТаблицы
//	|ЭтотСписок КАК Т
//	|
//	|ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Пользователи КАК Т1
//	|	ПО Т1.ФизическоеЛицо = Т.Ссылка
//	|;
//	|РазрешитьЧтениеИзменение
//	|ГДЕ
//	|	ЭтоГруппа
//	|	ИЛИ ЗначениеРазрешено(Т.Ссылка)
//	|	ИЛИ ЭтоАвторизованныйПользователь(Т1.Ссылка)";
//КонецПроцедуры
//
//// Конец СтандартныеПодсистемы.УправлениеДоступом

#КонецОбласти

// Функция определяет реквизиты физического лица.
//
// Параметры:
//  ФизЛицо - СправочникСсылка.ФизическиеЛица - Ссылка на элемент справочника
//
// Возвращаемое значение:
//	Выборка - Реквизиты выбранного физического лица
//
Функция ПолучитьРеквизитыФизическогоЛица(ФизЛицо) Экспорт
	
		
	Запрос = Новый Запрос("
	|ВЫБРАТЬ
	|	ФизическиеЛица.ИНН КАК ИНН
	|ИЗ
	|	Справочник.ФизическиеЛица КАК ФизическиеЛица
	|ГДЕ
	|	ФизическиеЛица.Ссылка = &ФизЛицо
	|");
	
	Запрос.УстановитьПараметр("ФизЛицо", ФизЛицо);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка;
	Иначе
		Возврат Неопределено;
	КонецЕсли;

КонецФункции

#КонецОбласти

#КонецЕсли

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
#Область СлужебныеПроцедурыИФункции

#Область Печать

// Заполняет список команд печати.
// 
// Параметры:
//   КомандыПечати – ТаблицаЗначений – состав полей см. в функции УправлениеПечатью.СоздатьКоллекциюКомандПечати
//
Процедура ДобавитьКомандыПечати(КомандыПечати) Экспорт
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти

#КонецЕсли
