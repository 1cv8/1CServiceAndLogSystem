
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	ПротестироватьСоединениеНаСервере(ПараметрКоманды);
КонецПроцедуры

&НаСервере
Процедура ПротестироватьСоединениеНаСервере(СервреSQL)
	
	Соединение = Неопределено;
	Попытка
		
		Соединение = РаботаСSQLСервером.СоединениеССерверомSQL(СервреSQL,, 30);
		
		Если Соединение = Неопределено Тогда
			ТекстСообщения = "Не удалось установить соединение с сервенром SQL";
			ОбщегоНазначения.СообщитьПользователю(ТекстСообщения);
		Иначе
			ТекстСообщения = "Соединение с сервенром SQL успешно установлено";
			ОбщегоНазначения.СообщитьПользователю(ТекстСообщения);
		КонецЕсли;
		
	Исключение
		
		ТекстСообщения = "Ошибка соединения: " + КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
		ОбщегоНазначения.СообщитьПользователю(ТекстСообщения);
		
		РаботаСSQLСервером.ЗакрытьСоединение(Соединение);
		Соединение = Неопределено;
		
	КонецПопытки;
	
	Если Соединение <> Неопределено Тогда
		РаботаСSQLСервером.ЗакрытьСоединение(Соединение);
	КонецЕсли;
	
КонецПроцедуры
