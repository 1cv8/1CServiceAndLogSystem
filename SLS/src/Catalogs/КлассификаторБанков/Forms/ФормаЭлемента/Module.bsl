///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Элементы.СтраницыДеятельностьПрекращена.Видимость = Объект.ДеятельностьПрекращена Или Пользователи.ЭтоПолноправныйПользователь();
	Элементы.СтраницыДеятельностьПрекращена.ТекущаяСтраница = ?(Пользователи.ЭтоПолноправныйПользователь(),
		Элементы.СтраницаФлажокДеятельностьПрекращена, Элементы.СтраницаНадписьДеятельностьПрекращена);
		
	Если Объект.ДеятельностьПрекращена Тогда
		КлючСохраненияПоложенияОкна = "ДеятельностьПрекращена";
		Элементы.НадписьДеятельностьБанкаПрекращена.Заголовок = РаботаСБанками.ПояснениеНедействительногоБанка(Объект.Ссылка);
	КонецЕсли;
	
	Если ОбщегоНазначения.ЭтоМобильныйКлиент() Тогда
		Элементы.ГруппаШапка.ВыравниваниеЭлементовИЗаголовков = ВариантВыравниванияЭлементовИЗаголовков.ЭлементыПравоЗаголовкиЛево;
		Элементы.ГруппаРеквизитыДляПлатежейВнутриСтраны.ВыравниваниеЭлементовИЗаголовков = ВариантВыравниванияЭлементовИЗаголовков.ЭлементыПравоЗаголовкиЛево;
		Элементы.ГруппаРеквизитыДляМеждународныхПлатежей.ВыравниваниеЭлементовИЗаголовков = ВариантВыравниванияЭлементовИЗаголовков.ЭлементыПравоЗаголовкиЛево;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.РаботаВМоделиСервиса.ОбменДаннымиВМоделиСервиса") Тогда
		
		МодульАвтономнаяРабота = ОбщегоНазначения.ОбщийМодуль("АвтономнаяРабота");
		МодульАвтономнаяРабота.ОбъектПриЧтенииНаСервере(ТекущийОбъект, ЭтотОбъект.ТолькоПросмотр);
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
