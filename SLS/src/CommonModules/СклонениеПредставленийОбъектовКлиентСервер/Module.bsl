///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Конструктор параметров для методов склонения.
// 
// Возвращаемое значение:
//  Структура:
//  ЭтоФИО	- Булево - признак склонения ФИО.
//  Пол		- Число	 - пол физического лица (в случае склонения ФИО): 1 - мужской, 2 - женский.
//
Функция ПараметрыСклонения() Экспорт
	
	Параметры = Новый Структура(
		"ЭтоФИО,
		|Пол");
	
	Параметры.ЭтоФИО = Ложь;
	
	Возврат Параметры;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Возвращает пустую структуру склонения.
//
// Возвращаемое значение:
//   Структура:
//    *ИменительныйПадеж 	- Строка.
//    *РодительныйПадеж 	- Строка.
//    *ДательныйПадеж 	- Строка
//    *ВинительныйПадеж 	- Строка.
//    *ТворительныйПадеж 	- Строка.
//    *ПредложныйПадеж 	- Строка.
// 
Функция СтруктураСклонения() Экспорт
	
	СтруктураСклонения = Новый Структура(
		"Именительный, 
		|Родительный, 
		|Дательный, 
		|Винительный, 
		|Творительный, 
		|Предложный");
	
	Возврат СтруктураСклонения;
	
КонецФункции

#КонецОбласти