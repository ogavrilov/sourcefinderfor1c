// необходима библиотека 1testrunner
#Использовать asserts

Перем юТест;
Перем ВременныйКаталог;
Перем НастройкиВыполнения;
Перем КоллекцияРезультатаОбразец;

Функция ПолучитьСписокТестов(Тестирование) Экспорт
	юТест = Тестирование;
	
	ВсеТесты = Новый Массив;
	
	ВсеТесты.Добавить("ТестДолжен_ПроверитьРаботуПоискаОбъектом");
	//ВсеТесты.Добавить("ТестДолжен_ПроверитьРаботуПоискаКомандойСистемы");
	
	Возврат ВсеТесты;
КонецФункции

Процедура ПередЗапускомТеста() Экспорт
	// подготовка временного каталога
	Если Не ЗначениеЗаполнено(ВременныйКаталог) Тогда
		ВременныйКаталог = ТекущийСценарий().Каталог + "/temp_tests";
		СоздатьКаталог(ВременныйКаталог);
	КонецЕсли;

	// подготовка тестовых данных
	КопироватьФайл(ТекущийСценарий().Каталог + "/fixtures/findsource_testfile1.bsl", ВременныйКаталог + "/testfile1.bsl");
	
	ЧтениеJSONФайла = Новый ЧтениеJSON;
	ЧтениеJSONФайла.ОткрытьФайл(ТекущийСценарий().Каталог + "/fixtures/findsource_options.json", КодировкаТекста.UTF8);
	КоллекцияСтрокПоиска = ПрочитатьJSON(ЧтениеJSONФайла, Истина);
	ЧтениеJSONФайла.Закрыть();
	ЧтениеJSONФайла = Неопределено;

	ЧтениеJSONФайла = Новый ЧтениеJSON;
	ЧтениеJSONФайла.ОткрытьФайл(ТекущийСценарий().Каталог + "/fixtures/findsource_result.json", КодировкаТекста.UTF8);
	КоллекцияРезультатаОбразец = ПрочитатьJSON(ЧтениеJSONФайла, Истина);
	ЧтениеJSONФайла.Закрыть();
	ЧтениеJSONФайла = Неопределено;

	// подготовка файла настроек
	НастройкиВыполнения = Новый Соответствие;
	НастройкиВыполнения.Вставить("ВременныйКаталог", ВременныйКаталог);
	НастройкиВыполнения.Вставить("КоллекцияСтрокПоиска", КоллекцияСтрокПоиска);
	КоллекцияФайловДляАнализа = Новый Массив;
	СоответствиеОписанияФайла = Новый Соответствие;
	СоответствиеОписанияФайла.Вставить("ВременныйКаталог", ВременныйКаталог);
	СоответствиеОписанияФайла.Вставить("ИмяФайлаДоВременногоКаталога", "testfile1.bsl");
	КоллекцияФайловДляАнализа.Добавить(СоответствиеОписанияФайла);
	НастройкиВыполнения.Вставить("КоллекцияФайловДляАнализа", КоллекцияФайловДляАнализа);
	НастройкиВыполнения.Вставить("ФайлРезультатаПроцесса", ВременныйКаталог + "/test_result.json");
КонецПроцедуры

Процедура ПослеЗапускаТеста() Экспорт
	Если ЗначениеЗаполнено(ВременныйКаталог) Тогда
		Утверждения.ПроверитьИстину(НайтиФайлы(ВременныйКаталог, "*").Количество() > 0, "Во временном каталоге " + ВременныйКаталог + " не должно остаться файлов");
		Попытка
			УдалитьФайлы(ВременныйКаталог + "/", "*");
			УдалитьФайлы(ВременныйКаталог);
		Исключение
		КонецПопытки;
		НайденныеФайлы = НайтиФайлы(ВременныйКаталог);
		Утверждения.ПроверитьИстину(НайденныеФайлы.Количество() = 0, "Временный каталог должен быть удален");
		ВременныйКаталог = "";
	КонецЕсли;
	НастройкиВыполнения = Неопределено;
КонецПроцедуры

Функция КопироватьКоллекцию(ИсходнаяКоллекция) Экспорт
	Если ТипЗнч(ИсходнаяКоллекция) = Тип("Массив") Тогда
		Результат = Новый Массив;
		ТипМассив = Истина;
	ИначеЕсли ТипЗнч(ИсходнаяКоллекция) = Тип("Структура") Тогда
		Результат = Новый Структура;
		ТипМассив = Ложь;
	ИначеЕсли ТипЗнч(ИсходнаяКоллекция) = Тип("Соответствие") Тогда
		Результат = Новый Соответствие;
		ТипМассив = Ложь;
	Иначе
		Возврат ИсходнаяКоллекция;
	КонецЕсли;
	Для Каждого ЭлементКоллекции Из ИсходнаяКоллекция Цикл
		Если ТипМассив Тогда
			Результат.Добавить(КопироватьКоллекцию(ЭлементКоллекции));
		Иначе
			Результат.Вставить(ЭлементКоллекции.Ключ, КопироватьКоллекцию(ЭлементКоллекции.Значение));
		КонецЕсли;
	КонецЦикла;
	Возврат Результат;
КонецФункции

// предполагается, что коллекции будут массивами или соответствиями
Функция КоллекцииСовпадают(Коллекция1, Коллекция2)
	ТипЗнчСоответствия = ТипЗнч(Коллекция1);
	Если ТипЗнчСоответствия <> ТипЗнч(Коллекция2) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Если Коллекция1.Количество() <> Коллекция2.Количество() Тогда
		Возврат Ложь;
	КонецЕсли;

	Если ТипЗнчСоответствия = Тип("Соответствие") Тогда
		Для Каждого ЭлементКоллекции1 Из Коллекция1 Цикл
			Если ТипЗнч(ЭлементКоллекции1.Значение) = Тип("Соответствие") ИЛИ ТипЗнч(ЭлементКоллекции1.Значение) = Тип("Массив") Тогда
				Если Не КоллекцииСовпадают(ЭлементКоллекции1.Значение, Коллекция2.Получить(ЭлементКоллекции1.Ключ)) Тогда
					Возврат Ложь;
				КонецЕсли;
				Продолжить;
			КонецЕсли;

			Значение2 = Коллекция2.Получить(ЭлементКоллекции1.Ключ);
			Если ЭлементКоллекции1.Значение <> Значение2 Тогда
				Возврат Ложь;
			КонецЕсли;
		КонецЦикла;
	
	Иначе
		Коллекция11 = КопироватьКоллекцию(Коллекция1);
		Коллекция22 = КопироватьКоллекцию(Коллекция2);
		Пока Коллекция11.Количество() > 0 Цикл
			// ищем такой же элемент во второй коллекции
			ЭлементКоллекции11 = Коллекция11.Получить(0);
			Если ТипЗнч(ЭлементКоллекции11) = Тип("Соответствие") ИЛИ ТипЗнч(ЭлементКоллекции11) = Тип("Массив") Тогда 
				НайденныйИндексКоллекции22 = Неопределено;
				ИндексКоллекции22 = 0;
				Пока ИндексКоллекции22 < Коллекция22.Количество() Цикл
					ЭлементыСовпадают = КоллекцииСовпадают(ЭлементКоллекции11, Коллекция22.Получить(ИндексКоллекции22));
					Если ЭлементыСовпадают Тогда
						НайденныйИндексКоллекции22 = ИндексКоллекции22;
						Прервать;
					Иначе
						ИндексКоллекции22 = ИндексКоллекции22 + 1;
					КонецЕсли;
				КонецЦикла;
			Иначе
				НайденныйИндексКоллекции22 = Коллекция22.Найти(ЭлементКоллекции11);
			КонецЕсли;
			Если НайденныйИндексКоллекции22 = Неопределено Тогда
				Возврат Ложь;
			Иначе
				Коллекция22.Удалить(НайденныйИндексКоллекции22);
				Коллекция11.Удалить(0);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;

	Возврат Истина;
КонецФункции

Процедура ТестДолжен_ПроверитьРаботуПоискаОбъектом() Экспорт

	ТекстОшибки = "";
	Попытка
		// подключим объект
		ПодключитьСценарий("./src/findinsource.os", "ТипПоиска");
		ОбъектПоиска = Новый ТипПоиска(НастройкиВыполнения);
		ОбъектПоиска.Инициализация();

		// выполним поиск
		Результат = ОбъектПоиска.ПоискВФайлахПоШаблону();
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		ВременныйКаталог = Неопределено;
	КонецПопытки;

	Если ЗначениеЗаполнено(ТекстОшибки) Тогда
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

	Если Не КоллекцииСовпадают(КоллекцияРезультатаОбразец, Результат) Тогда
		ТекстОшибки = "Коллекция результата отлична от образца (временный каталог: " + ВременныйКаталог + ")";
		ВременныйКаталог = Неопределено;
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
	
КонецПроцедуры

Процедура ТестДолжен_ПроверитьРаботуПоискаКомандойСистемы() Экспорт

	ТекстОшибки = "";
	Попытка
		// запишем настройки в файл
		ИмяФайлаНастроек = ВременныйКаталог + "/test_options.json";
		ЗаписьJSONФайла = Новый ЗаписьJSON;
		ЗаписьJSONФайла.ОткрытьФайл(ИмяФайлаНастроек);
		ЗаписатьJSON(ЗаписьJSONФайла, НастройкиВыполнения);
		ЗаписьJSONФайла.Закрыть();
		ЗаписьJSONФайла = Неопределено;

		// подключим объект
		СтрокаКоманды = "oscript src/findinsource.os """ + ИмяФайлаНастроек + """";
		ПроцессТеста = СоздатьПроцесс(СтрокаКоманды, ".", Истина);
		ПроцессТеста.Запустить();
		ТекстВывода = "";
		Пока НЕ ПроцессТеста.Завершен ИЛИ ПроцессТеста.ПотокВывода.ЕстьДанные ИЛИ ПроцессТеста.ПотокОшибок.ЕстьДанные Цикл
			Приостановить(500);
			
			ОчереднаяСтрокаВывода = ПроцессТеста.ПотокВывода.Прочитать();
			ОчереднаяСтрокаОшибок = ПроцессТеста.ПотокОшибок.Прочитать();
			Если Не ПустаяСтрока(ОчереднаяСтрокаВывода) Тогда
				ТекстВывода = ТекстВывода + Символы.ПС + ОчереднаяСтрокаВывода;
			КонецЕсли;
			
			Если Не ПустаяСтрока(ОчереднаяСтрокаОшибок) Тогда
				ТекстВывода = ТекстВывода + Символы.ПС + ОчереднаяСтрокаОшибок;
			КонецЕсли;
		КонецЦикла;

		// выполним поиск
		ЧтениеJSONФайла = Новый ЧтениеJSON;
		ЧтениеJSONФайла.ОткрытьФайл(НастройкиВыполнения.Получить("ФайлРезультатаПроцесса"), КодировкаТекста.UTF8);
		Результат = ПрочитатьJSON(ЧтениеJSONФайла, Истина);
		ЧтениеJSONФайла.Закрыть();
		ЧтениеJSONФайла = Неопределено;
	Исключение
		ТекстОшибки = ТекстВывода + Символы.ПС + ОписаниеОшибки();
		ВременныйКаталог = Неопределено;
	КонецПопытки;

	Если ЗначениеЗаполнено(ТекстОшибки) Тогда
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

	Если Не КоллекцииСовпадают(КоллекцияРезультатаОбразец, Результат) Тогда
		ТекстОшибки = "Коллекция результата отлична от образца (временный каталог: " + ВременныйКаталог + ")";
		ВременныйКаталог = Неопределено;
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
	
КонецПроцедуры
