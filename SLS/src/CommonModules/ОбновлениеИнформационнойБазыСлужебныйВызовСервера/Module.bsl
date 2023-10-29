///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

// См. описание этой же функции в модуле ОбновлениеИнформационнойБазыСлужебный.
Функция ВыполнитьОбновлениеИнформационнойБазы(ПриЗапускеКлиентскогоПриложения = Ложь, Перезапустить = Ложь, ВыполнятьОтложенныеОбработчики = Ложь) Экспорт
	
	ПараметрыОбновления = ОбновлениеИнформационнойБазыСлужебный.ПараметрыОбновления();
	ПараметрыОбновления.ПриЗапускеКлиентскогоПриложения = ПриЗапускеКлиентскогоПриложения;
	ПараметрыОбновления.Перезапустить = Перезапустить;
	ПараметрыОбновления.ВыполнятьОтложенныеОбработчики = ВыполнятьОтложенныеОбработчики;
	
	Попытка
		Результат = ОбновлениеИнформационнойБазыСлужебный.ВыполнитьОбновлениеИнформационнойБазы(ПараметрыОбновления);
	Исключение
		// Переход в режим открытия формы повторной синхронизации данных перед запуском
		// с двумя вариантами "Синхронизировать и продолжить" и "Продолжить".
		Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОбменДанными")
		   И ОбщегоНазначения.ЭтоПодчиненныйУзелРИБ() Тогда
			МодульОбменДаннымиСервер = ОбщегоНазначения.ОбщийМодуль("ОбменДаннымиСервер");
			МодульОбменДаннымиСервер.ВключитьПовторениеЗагрузкиСообщенияОбменаДаннымиПередЗапуском();
		КонецЕсли;
		ВызватьИсключение;
	КонецПопытки;
	
	Перезапустить = ПараметрыОбновления.Перезапустить;
	Возврат Результат;
	
КонецФункции

// Снимает блокировку информационной файловой базы.
Процедура СнятьБлокировкуФайловойБазы() Экспорт
	
	Если Не ОбщегоНазначения.ИнформационнаяБазаФайловая() Тогда
		Возврат;
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ЗавершениеРаботыПользователей") Тогда
		МодульСоединенияИБ = ОбщегоНазначения.ОбщийМодуль("СоединенияИБ");
		МодульСоединенияИБ.РазрешитьРаботуПользователей();
	КонецЕсли;
	
КонецПроцедуры

Функция ДанныеРасшифровкиОтчета(ДанныеРасшифровки, ИндексРасшифровки, Кеш = Неопределено, КешПриоритетов = Неопределено) Экспорт
	Если Не ЗначениеЗаполнено(ДанныеРасшифровки) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Данные = ПолучитьИзВременногоХранилища(ДанныеРасшифровки);
	Если ИндексРасшифровки = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	Расшифровка = Данные.Элементы[ИндексРасшифровки].ПолучитьПоля();
	Если Расшифровка.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	СведенияОбОбновлении = ОбновлениеИнформационнойБазыСлужебный.СведенияОбОбновленииИнформационнойБазы();
	НачалоОбновления = СведенияОбОбновлении.ВремяНачалаОтложенногоОбновления;
	
	ЗначениеРасшифровки = Расшифровка.Получить(0);
	Результат = Новый Структура;
	Результат.Вставить("ИмяПоля", ЗначениеРасшифровки.Поле);
	Результат.Вставить("Значение", ЗначениеРасшифровки.Значение);
	Результат.Вставить("НачалоОбновления", НачалоОбновления);
	Результат.Вставить("Кеш", Кеш);
	Результат.Вставить("КешПриоритетов", КешПриоритетов);
	
	Возврат Результат;
КонецФункции

Процедура РазблокироватьОбъектДляРедактирования(МассивОбъектов) Экспорт
	
	МетаданныеИОтборПоДанным = Неопределено;
	Для Каждого Объект Из МассивОбъектов Цикл
		МетаданныеИОтборПоДанным = ОбновлениеИнформационнойБазы.МетаданныеИОтборПоДанным(Объект);
	КонецЦикла;
	
	Если МетаданныеИОтборПоДанным = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Блокировка = Новый БлокировкаДанных;
	Блокировка.Добавить("Константа.СведенияОБлокируемыхОбъектах");
	НачатьТранзакцию();
	Попытка
		Блокировка.Заблокировать();
		
		СведенияОБлокируемыхОбъектах = ОбновлениеИнформационнойБазыСлужебный.СведенияОБлокируемыхОбъектах();
		РазблокированныеОбъекты = СведенияОБлокируемыхОбъектах.РазблокированныеОбъекты[МетаданныеИОтборПоДанным.ПолноеИмя]; // Массив.
		Если РазблокированныеОбъекты = Неопределено Тогда
			РазблокированныеОбъекты = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(МетаданныеИОтборПоДанным.Отбор);
		Иначе
			РазблокированныеОбъекты.Добавить(МетаданныеИОтборПоДанным.Отбор);
		КонецЕсли;
		
		СведенияОБлокируемыхОбъектах.РазблокированныеОбъекты[МетаданныеИОтборПоДанным.ПолноеИмя] = РазблокированныеОбъекты;
		ОбновлениеИнформационнойБазыСлужебный.ЗаписатьСведенияОБлокируемыхОбъектах(СведенияОБлокируемыхОбъектах);
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

#КонецОбласти
