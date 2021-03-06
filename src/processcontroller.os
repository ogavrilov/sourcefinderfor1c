#Использовать logos

Перем Лог;
Перем ДанныеКорректны;
Перем ОбщиеМетоды;

Процедура ПриСозданииОбъекта(НастройкиВыполнения = Неопределено)
	// обработка настроек
	Если НастройкиВыполнения = Неопределено Тогда
		Если АргументыКоманднойСтроки.Количество() > 0 Тогда
			ФайлНастроекВыполнения = АргументыКоманднойСтроки[0];
		Иначе
			ФайлНастроекВыполнения = СтрЗаменить(ТекущийСценарий().Источник, ".os", ".json");
		КонецЕсли;
		Если НайтиФайлы(ФайлНастроекВыполнения).Количество() > 0 Тогда
			НастройкиВыполнения = ОбщиеМетоды.ПрочитатьФайлJSON(ФайлНастроекВыполнения);
		КонецЕсли;
	КонецЕсли;

	УстановитьНастройкиВыполнения(НастройкиВыполнения);
КонецПроцедуры

Процедура УстановитьНастройкиВыполнения(НастройкиВыполнения, ИменаНастроек = Неопределено) Экспорт
	Если ИменаНастроек = Неопределено Тогда
		ИменаНастроек = "Лог";
	КонецЕсли;
	СтруктураИменНастроек = Новый Структура(ИменаНастроек);
	СтруктураНастроек = Новый Структура;
	Для Каждого ЭлементСтруктурыИменНастроек Из СтруктураИменНастроек Цикл
		Выполнить(ЭлементСтруктурыИменНастроек.Ключ + " = НастройкиВыполнения.Получить(ЭлементСтруктурыИменНастроек.Ключ);");
	КонецЦикла;
КонецПроцедуры

Процедура Инициализация() Экспорт
	// Лог
	Если Лог = Неопределено Тогда
		Лог = Логирование.ПолучитьЛог("oscript.app.processcontroller");
		Лог.УстановитьРаскладку(ОбщиеМетоды);
	КонецЕсли;
	
	// проверка параметров
	ДанныеКорректны = Истина;

	Если Не ДанныеКорректны Тогда
		Лог.КритичнаяОшибка("Операции завершены.");
	КонецЕсли;
КонецПроцедуры

Функция ПолучитьНовоеОписаниеЭтапа() Экспорт
	ОписаниеЭтапа = Новый Соответствие;
	ОписаниеЭтапа.Вставить("ИменаПараметровЭлемента", Новый Соответствие);
	ОписаниеЭтапа.ИменаПараметровЭлемента.Вставить("ОписаниеИсходника", Неопределено);
	ОписаниеЭтапа.Вставить("ИменаСтруктурыОкружения", "");
	ОписаниеЭтапа.Вставить("ИменаПолейПредставления", "");
	ОписаниеЭтапа.Вставить("ИмяКоллекцииЭлементов", "");
	ОписаниеЭтапа.Вставить("ИмяКоллекцииРезультатов", "");
	ОписаниеЭтапа.Вставить("ИмяЭтапа", "");
	ОписаниеЭтапа.Вставить("КомандаЗапуска", "");

	Возврат ОписаниеЭтапа;
КонецФункции

Функция ПолучитьНовоеОписаниеЭтапов() Экспорт
	Результат = Новый Соответствие;
	
	Результат.Вставить("МаксимальныйПорядок", 2);
	Результат.Вставить("Этапы", Новый Соответствие);

	Возврат Результат;
КонецФункции

Процедура ЗапуститьПроцесс(АктивныеПроцессы, СтруктураОкружения, ОписаниеЭтапа)
	УникальныйИдентификаторПроцесса = Лев(Строка(Новый УникальныйИдентификатор()), 8);

	ФайлНастроекПроцесса = СтруктураОкружения.ВременныйКаталог + "/process_options_" + УникальныйИдентификаторПроцесса + ".json";
	ФайлВыводаПроцесса = СтруктураОкружения.ВременныйКаталог + "/process_out_" + УникальныйИдентификаторПроцесса + ".log";
	ФайлРезультатовПроцесса = СтруктураОкружения.ВременныйКаталог + "/process_result_" + УникальныйИдентификаторПроцесса + ".json";

	//
	ИмяКоллекцииЭлементов = ОписаниеЭтапа.Получить("ИмяКоллекцииЭлементов");
	ИменаПолейПредставления = ОписаниеЭтапа.Получить("ИменаПолейПредставления");
	ИменаПараметровЭлемента = ОписаниеЭтапа.Получить("ИменаПараметровЭлемента");
	ИменаСтруктурыОкружения = ОписаниеЭтапа.Получить("ИменаСтруктурыОкружения");
	ИмяКоллекцииРезультатов = ОписаниеЭтапа.Получить("ИмяКоллекцииРезультатов");
	ИмяЭтапа = ОписаниеЭтапа.Получить("ИмяЭтапа");
	КомандаЗапуска = ОписаниеЭтапа.Получить("КомандаЗапуска");
	
	// получаем очередной элемент для обработки
	КоллекцияЭлементов = СтруктураОкружения[ИмяКоллекцииЭлементов];
	ЭлементДляОбработки = КоллекцияЭлементов.Получить(0);
	КоллекцияЭлементов.Удалить(0);

	// формируем представление
	СтруктураПолейПредставления = Новый Структура(ИменаПолейПредставления);
	ПредставлениеПроцесса = "";
	Для Каждого ЭлементСтруктурыПредставления Из СтруктураПолейПредставления Цикл
		ПредставлениеПроцесса = ПредставлениеПроцесса + ?(ЗначениеЗаполнено(ПредставлениеПроцесса), "|", "");
		ЗначениеПоля = ЭлементДляОбработки.Получить(ЭлементСтруктурыПредставления.Ключ);
		// уберем из поля значения имени команды
		ИмяПредыдущегоЭтапа = ЭлементДляОбработки.Получить("ИмяПредыдущегоЭтапа");
		Если ЗначениеЗаполнено(ИмяПредыдущегоЭтапа) Тогда
			ЗначениеПоля = СтрЗаменить(ЗначениеПоля, ИмяПредыдущегоЭтапа + "|", "");
		КонецЕсли;
		ПредставлениеПроцесса = ПредставлениеПроцесса + ЗначениеПоля;
	КонецЦикла;
	ПредставлениеПроцесса = ИмяЭтапа + "|" + ПредставлениеПроцесса;

	// формируем настройки процесса
	НастройкиПроцесса = Новый Структура;
	НастройкиПроцесса.Вставить("ИдентификаторПроцесса", УникальныйИдентификаторПроцесса);
	НастройкиПроцесса.Вставить("ФайлРезультатаПроцесса", ФайлРезультатовПроцесса);
	НастройкиПроцесса.Вставить("ИмяПредыдущегоЭтапа", ИмяЭтапа);
	Для Каждого ОписаниеПоляЭлемента Из ИменаПараметровЭлемента Цикл
		Если ОписаниеПоляЭлемента.Значение = Неопределено Тогда
			НастройкиПроцесса.Вставить(ОписаниеПоляЭлемента.Ключ, ЭлементДляОбработки);
		Иначе
			НастройкиПроцесса.Вставить(ОписаниеПоляЭлемента.Ключ, ОписаниеПоляЭлемента.Значение);
		КонецЕсли;
	КонецЦикла;
	СтруктураИменСтруктурыОкружения = Новый Структура(ИменаСтруктурыОкружения);
	Для Каждого ЭлементСтруктурыОкружения Из СтруктураИменСтруктурыОкружения Цикл
		НастройкиПроцесса.Вставить(ЭлементСтруктурыОкружения.Ключ, СтруктураОкружения[ЭлементСтруктурыОкружения.Ключ]);
	КонецЦикла;
	ОбщиеМетоды.ЗаписатьФайлJSON(ФайлНастроекПроцесса, НастройкиПроцесса);

	// готовим соответствие описания процесса
	ОписаниеПроцесса = Новый Соответствие;
	ОписаниеПроцесса.Вставить("ФайлНастроек", ФайлНастроекПроцесса);
	ОписаниеПроцесса.Вставить("ФайлВывода", ФайлНастроекПроцесса);
	ОписаниеПроцесса.Вставить("ФайлРезультатов", ФайлНастроекПроцесса);
	ОписаниеПроцесса.Вставить("Представление", ПредставлениеПроцесса);
	ОписаниеПроцесса.Вставить("УИД", УникальныйИдентификаторПроцесса);
	ОписаниеПроцесса.Вставить("ИмяКоллекцииРезультатов", ИмяКоллекцииРезультатов);
	ОписаниеПроцесса.Вставить("ИмяЭтапа", ИмяЭтапа);

	КомандаПроцесса = КомандаЗапуска + " """ + ФайлНастроекПроцесса + """ &>""" + ФайлВыводаПроцесса + """";

	НовыйПроцесс = СоздатьПроцесс(КомандаПроцесса, СтруктураОкружения.ВременныйКаталог);
	НовыйПроцесс.Запустить();
	АктивныеПроцессы.Вставить(НовыйПроцесс.Идентификатор, ОписаниеПроцесса);
КонецПроцедуры

Процедура ПроверкаЗавершенияПроцессов(АктивныеПроцессы, НеобработанныеРезультаты, СтруктураОкружения)
	УдалитьИдентификаторыПроцессов = Новый Массив;
	Для каждого ЭлементСоответствия Из АктивныеПроцессы Цикл
		ТекущийПроцесс = НайтиПроцессПоИдентификатору(ЭлементСоответствия.Ключ);
		ПроцессЗавершен = Ложь;
		Если ТекущийПроцесс = Неопределено Тогда
			// процесс завершен
			ПроцессЗавершен = Истина;
		Иначе
			ПроцессЗавершен = ТекущийПроцесс.Завершен;
		КонецЕсли;
		Если ПроцессЗавершен Тогда
			УИД = ЭлементСоответствия.Значение.Получить("УИД");
			Представление = ЭлементСоответствия.Значение.Получить("Представление");
			ФайлНастроек = ЭлементСоответствия.Значение.Получить("ФайлНастроек");
			ФайлВывода = ЭлементСоответствия.Значение.Получить("ФайлВывода");
			ФайлРезультатов = ЭлементСоответствия.Значение.Получить("ФайлРезультатов");
			ИмяКоллекцииРезультатов = ЭлементСоответствия.Значение.Получить("ИмяКоллекцииРезультатов");

			Лог.Отладка("Завершен процесс pid#" + ЭлементСоответствия.Ключ + " (uid:" + УИД + ")");
			УдалитьИдентификаторыПроцессов.Добавить(ЭлементСоответствия.Ключ);
			ДанныеВывода = ОбщиеМетоды.ПрочитатьТекстовыйФайл(ФайлВывода);
			Если ЗначениеЗаполнено(ДанныеВывода) Тогда
				Лог.Отладка("$NOFORMAT$" + ДанныеВывода);
			КонецЕсли;
			ДанныеРезультата = ПрочитатьФайлJSON(ФайлРезультатов);
			СоответствиеРезультата = Новый Структура;
			СоответствиеРезультата.Вставить("ДанныеВывода", ДанныеВывода);
			СоответствиеРезультата.Вставить("ДанныеРезультата", ДанныеРезультата);
			СоответствиеРезультата.Вставить("Представление", Представление);

			Если ИмяКоллекцииРезультатов = Неопределено Тогда
				КоллекцияРезультатов = НеобработанныеРезультаты;
			Иначе
				КоллекцияРезультатов = СтруктураОкружения[ИмяКоллекцииРезультатов];
			КонецЕсли;
			КоллекцияРезультатов.Вставить(УИД, СоответствиеРезультата);

			Попытка
				УдалитьФайлы(ФайлНастроек);
				УдалитьФайлы(ФайлВывода);
				УдалитьФайлы(ФайлРезультатов);
			Исключение
				Лог.Ошибка("Не удалось удалить временные файлы процесса pid#" + ЭлементСоответствия.Ключ + " (uid:" + УИД +")");
			КонецПопытки;
		КонецЕсли;
	КонецЦикла;
	Для Каждого УдаляемыйИдентификатор Из УдалитьИдентификаторыПроцессов Цикл
		АктивныеПроцессы.Удалить(УдаляемыйИдентификатор);
	КонецЦикла;
КонецПроцедуры

Функция ПолучитьНаличиеИсходныхДанных(ОписаниеЭтапов, СтруктураОкружения)
	Результат = Ложь;
	Этапы = ОписаниеЭтапов.Получить("Этапы");
	Для Каждого ОписаниеЭтапа Из Этапы Цикл
		ИмяКоллекцииЭлементов = ОписаниеЭтапа.Получить("ИмяКоллекцииЭлементов");
		Если СтруктураОкружения[ИмяКоллекцииЭлементов].Количество() > 0 Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	Возврат Результат;
КонецФункции

// выполняет операции, разделив их на процессы для параллельного запуска (естетственно, только данный скрипт)
// Параметры:
// - СтруктураОкружения - Структура с параметрами процесса и необходимыми коллекциями
// - ЛимитПроцессов - Число - пока активно указанное количество процессов - новые запускаться не будут, будем ждать
// - ОжиданиеМс - Число - сколько милисекунд будем ждать окончания процессов, если "уперлись" в лимит
// - ОбъектОбработкиРезультатов - скрипт/объект, в котором поищем экспортный метод "ОбработкаКонечныхРезультатовПроцессов",
//		если он есть - будем выполнять его вызов с очередным необработанным результатом, вместо ожидания завершения процессов
//		также будем его использовать для обработки всех результатов по окончании запуска и выполнения всех процессов
Процедура ВыполнитьОперациямиПроцессами(ОписаниеЭтапов, СтруктураОкружения, ЛимитПроцессов = 1, ОжиданиеМс = 1000, ОбъектОбработкиРезультатов = Неопределено) Экспорт
	АктивныеПроцессы = Новый Соответствие;
	НеобработанныеРезультаты = Новый Соответствие;
	ДанныеРезультата = Новый Массив;
	ИсходныеДанныеИмеются = ПолучитьНаличиеИсходныхДанных(ОписаниеЭтапов, СтруктураОкружения);
	МаксимальныйПорядок = ОписаниеЭтапов.Получить("МаксимальныйПорядок");

	// подготовим "промежуточные" коллекции
	Для Каждого ОписаниеЭтапа Из ОписаниеЭтапов Цикл
		ИмяКоллекцииЭлементов = ОписаниеЭтапа.Получить("ИмяКоллекцииЭлементов");
		Если Не СтруктураОкружения.Свойство(ИмяКоллекцииЭлементов) Тогда
			СтруктураОкружения.Вставить(ИмяКоллекцииЭлементов, Новый Массив);
		КонецЕсли;
	КонецЦикла;
	
	Пока Истина Цикл
		// проверяем текущее состояние процессов и обрабатываем результаты
		ПроверкаЗавершенияПроцессов(АктивныеПроцессы, НеобработанныеРезультаты, СтруктураОкружения);

		// запускаем новые процессы
		ИсходныеДанныеИмеются = ПолучитьНаличиеИсходныхДанных(ОписаниеЭтапов, СтруктураОкружения);
		ЗапустилиПроцессы = Ложь;
		Пока АктивныеПроцессы.Количество() < ЛимитПроцессов И ИсходныеДанныеИмеются Цикл
			Для ПорядокЭтапа = 1 По МаксимальныйПорядок Цикл
				ОписаниеЭтапа = ОписаниеЭтапов.Получить(ПорядокЭтапа);
				ИмяКоллекцииЭлементов = ОписаниеЭтапа.Получить("ИмяКоллекцииЭлементов");
				Если СтруктураОкружения[ИмяКоллекцииЭлементов].Количество() > 0 Тогда
					ЗапуститьПроцесс(АктивныеПроцессы, СтруктураОкружения, ОписаниеЭтапа);
					ЗапустилиПроцессы = Истина;
					Прервать;	// если что-то запустили, то возвратимся на цикл выше и вновь проверим необходимость запуска
				КонецЕсли;
			КонецЦикла;
			ИсходныеДанныеИмеются = ПолучитьНаличиеИсходныхДанных(ОписаниеЭтапов, СтруктураОкружения);
		КонецЦикла;

		// условие завершения
		Если Не ЗапустилиПроцессы И АктивныеПроцессы.Количество() = 0 И Не ИсходныеДанныеИмеются Тогда
			Прервать;
		КонецЕсли;

		// просто подождем или обработаем результат (вероятно это также может занять время)
		Если ОбъектОбработкиРезультатов <> Неопределено И НеобработанныеРезультаты.Количество() > 0 Тогда
			// обработка результата
			ОбъектОбработкиРезультатов.ОбработкаКонечныхРезультатовПроцессов(НеобработанныеРезультаты, 1);
		Иначе
			// ожидаем
			Приостановить(ОжиданиеМс);
		КонецЕсли;
	КонецЦикла;

	// обработаем все оставшиеся необработанные результаты
	Если ОбъектОбработкиРезультатов <> Неопределено И НеобработанныеРезультаты.Количество() > 0 Тогда
		ОбъектОбработкиРезультатов.ОбработкаКонечныхРезультатовПроцессов(НеобработанныеРезультаты);
	КонецЕсли;
КонецПроцедуры

ОбщиеМетоды = ЗагрузитьСценарий(ТекущийСценарий().Каталог + "/commonmethods.os");

Если СтартовыйСценарий().Источник = ТекущийСценарий().Источник Тогда
	//Инициализация();
	//Если Не ДанныеКорректны Тогда
	//	ЗавершитьРаботу(1);
	//КонецЕсли;
	//
	Сообщить("Использование из командной строки не реализовано");
	ЗавершитьРаботу(1);
КонецЕсли;
