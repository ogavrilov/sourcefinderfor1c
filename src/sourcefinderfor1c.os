#Использовать logos

Перем Лог;
Перем ОбщиеМетоды;

#Область Описание_параметров
// скрипт имеет 2 позиционных параметра:
// [0] - команда, может быть задана значениями main/find/source (соответственно основной скрипт/операция поиска по шаблону в файлах/операция выгрузки в файлы и поиска подходящих файлов)
// [1] - имя файла настроек

// Описание формата файла настроек для main (json)
// - КоллекцияСтрокПоиска - соответствие строк шаблонов регулярных выражений и их ключа, т.е. представления для последующего красивого вывода в результат
// - КоллекцияИсходников - массив структур, со следующими полями:
// - - ТипИсходника - строка описания типа со следующими значениями:
// - - - src - строка к файлу *.bsl, либо строка пути к каталогу, в котором будет выполнен поиск *.bsl-файлов
// - - - cf - имя файла конфигурации, который будет выгружен в файлы исходников в каталог, в котором будет выполнен поиск *.bsl-файлов
// - - - cfe - имя файла конфигурации, который будет выгружен в файлы исходников в каталог, в котором будет выполнен поиск *.bsl-файлов
// - - - repo - адрес подключения к хранилищу, из которого получим файл конфигурации, который будет выгружен в файлы исходников в каталог, в котором будет выполнен поиск *.bsl-файлов
// - - - git - адрес гит-репозитория, из которого будет загружен каталог файлов, в котором будет выполнен поиск *.bsl-файлов
// - - - ib - адрес подключения к ИБ, из которой будут выгружены все дополнительные обработки из справочника
// - - Source - строка описывающая исходник (выше в типах описано, что должно быть указано для какого типа)
// - - User - строка имени пользователя (актуальна для типов repo, git и ib)
// - - Pwd - строка пароля пользователя (актуальна для типов repo, git и ib)
// - ФайлРезультата - имя файла куда сохранить результат
// - ФорматРезультата - описание формата результата
// - ФорматыФайловДляАнализа - массив строк типа "*.bsl"
// - ФайлОбработкиВыгрузкиДопОбработок - путь к файлу обработки, которая при открытии выгрузит все доп. обработки ! обработка должна анализировать строку параметров запуска и получать из нее путь к временному каталогу, куда выгружать файлы обработок!

// Описание формата файла настроек для find (json)
// - КоллекцияСтрокПоиска - соответствие строк шаблонов регулярных выражений и их ключа, т.е. представления для последующего красивого вывода в результат
// - КоллекцияФайловДляАнализа - массив структур
// - - ВременныйКаталог - Строка - может быть пустой, если нет - будет удален после анализа
// - - ИмяФайлаДоВременногоКаталога - Строка - путь к файлу (полное имя файла получим склеиваем ВременныйКаталог + ИмяФайлаДоВременногоКаталога)

// Описание формата файла настроек для source
// - ОписаниеИсходника - структура, аналогичная структуре из КоллекцияИсходников для команды main
// - ФорматыФайловДляАнализа - массив строк типа "*.bsl"
// - ФайлОбработкиВыгрузкиДопОбработок - путь к файлу обработки, которая при открытии выгрузит все доп. обработки ! обработка должна анализировать строку параметров запуска и получать из нее путь к временному каталогу, куда выгружать файлы обработок!

#КонецОбласти

Процедура ОсновнойСкрипт(НастройкиВыполнения)
	ВременныйКаталог = ТекущийСценарий().Каталог + "/" + Лев(Строка(Новый УникальныйИдентификатор()), 8);
	СоздатьКаталог(ВременныйКаталог);

	// подключим объект управления процессами
	ПодключитьСценарий("processcontroller.os", "УправлениеПроцессамиТип");
	УправлениеПроцессами = Новый УправлениеПроцессамиТип(Новый Структура("Лог", Лог));
	УправлениеПроцессами.Инициализация();

	// готовим описание этапов
	ОписаниеЭтапов = УправлениеПроцессами.ПолучитьНовоеОписаниеЭтапов();
	СоответствиеЭтапов = Новый Соответствие;
	// 1-й этап - выгрузка в исходники
	ОписаниеЭтапа = УправлениеПроцессами.ПолучитьНовоеОписаниеЭтапа();
	ОписаниеЭтапа.Вставить("ИменаПараметровЭлемента", Новый Соответствие);
	ОписаниеЭтапа.ИменаПараметровЭлемента.Вставить("ОписаниеИсходника", Неопределено);
	ОписаниеЭтапа.Вставить("ИменаСтруктурыОкружения", "ФорматыФайловДляАнализа, ФайлОбработкиВыгрузкиДопОбработок, ВременныйКаталог");
	ОписаниеЭтапа.Вставить("ИменаПолейПредставления", "ТипИсходника, Source");
	ОписаниеЭтапа.Вставить("ИмяКоманды", "source");
	ОписаниеЭтапа.Вставить("ИмяКоллекцииЭлементов", "КоллекцияИсходников");
	ОписаниеЭтапа.Вставить("ИмяКоллекцииРезультатов", "КоллекцияФайловДляАнализа");
	ОписаниеЭтапа.Вставить("КомандаЗапуска", "oscript """ + ТекущийСценарий().Каталог + "/extractsource.os""");
	СоответствиеЭтапов.Вставть(1, ОписаниеЭтапа);
	// 2-й этап - поиск в исходниках
	ОписаниеЭтапа = УправлениеПроцессами.ПолучитьНовоеОписаниеЭтапа();
	ОписаниеЭтапа.Вставить("ИменаПараметровЭлемента", Новый Соответствие);
	ОписаниеЭтапа.ИменаПараметровЭлемента.Вставить("ОписаниеИсходника", Неопределено);
	ОписаниеЭтапа.Вставить("ИменаСтруктурыОкружения", "ФорматыФайловДляАнализа, ФайлОбработкиВыгрузкиДопОбработок");
	ОписаниеЭтапа.Вставить("ИменаПолейПредставления", "Представление");
	ОписаниеЭтапа.Вставить("ИмяКоманды", "find");
	ОписаниеЭтапа.Вставить("ИмяКоллекцииЭлементов", "КоллекцияФайловДляАнализа");
	ОписаниеЭтапа.Вставить("ИмяКоллекцииРезультатов", Неопределено);
	ОписаниеЭтапа.Вставить("КомандаЗапуска", "oscript """ + ТекущийСценарий().Каталог + "/findinsource.os""");
	СоответствиеЭтапов.Вставть(2, ОписаниеЭтапа);

	ОписаниеЭтапов.Вставить("Этапы", СоответствиеЭтапов);
	
	ЛимитПроцессов = НастройкиВыполнения.Получить("ЛимитПроцессов");
	Если ЛимитПроцессов = Неопределено Тогда
		ЛимитПроцессов = 1;
	КонецЕсли;
	ОжиданиеМс = НастройкиВыполнения.Получить("ОжиданиеМс");
	Если ОжиданиеМс = Неопределено Тогда
		ОжиданиеМс = 1000;
	КонецЕсли;

	СтруктураОкружения = Новый Структура;
	СтруктураОкружения.Вставить("КоллекцияИсходников", КопироватьКоллекцию(НастройкиВыполнения.Получить("КоллекцияИсходников")));
	СтруктураОкружения.Вставить("ВременныйКаталог", ВременныйКаталог);
	СтруктураОкружения.Вставить("КоллекцияСтрокПоиска", НастройкиВыполнения.Получить("КоллекцияСтрокПоиска"));
	СтруктураОкружения.Вставить("ФорматыФайловДляАнализа", НастройкиВыполнения.Получить("ФорматыФайловДляАнализа"));
	СтруктураОкружения.Вставить("ФайлОбработкиВыгрузкиДопОбработок", НастройкиВыполнения.Получить("ФайлОбработкиВыгрузкиДопОбработок"));
	
	УправлениеПроцессами.ВыполнитьОперациямиПроцессами(ОписаниеЭтапов, СтруктураОкружения, ЛимитПроцессов, ОжиданиеМс, ЭтотОбъект);

	Если НастройкиВыполнения.Получить("НеУдалятьВременныйКаталог") = Неопределено Тогда
		Попытка
			УдалитьФайлы(ВременныйКаталог + "/", "*");
			УдалитьФайлы(ВременныйКаталог);
		Исключение
			Лог.Ошибка("Не удалось удалить временный каталог");
		КонецПопытки;
	КонецЕсли;
КонецПроцедуры

ОбщиеМетоды = ЗагрузитьСценарий(ТекущийСценарий().Каталог + "/commonmethods.os");

Лог = Логирование.ПолучитьЛог("oscript.app.sourcefinderfor1c");
Лог.УстановитьРаскладку(ЭтотОбъект);

Если СтартовыйСценарий().Источник = ТекущийСценарий().Источник Тогда
	// Обработка полученных параметров
	Если АргументыКоманднойСтроки.Количество() > 0 Тогда
		ИмяФайлаНастроек = АргументыКоманднойСтроки[0];
	Иначе
		ИмяФайлаНастроек = СтрЗаменить(ТекущийСценарий().Источник, ".os", ".json");
	КонецЕсли;
	ТекстОшибки = "";
	Если НайтиФайлы(ИмяФайлаНастроек).Количество() = 0 Тогда
		ТекстОшибки = ТекстОшибки + ?(ЗначениеЗаполнено(ТекстОшибки), Символы.ПС, "");
		ТекстОшибки = ТекстОшибки + "Не найден файл настроек: " + ИмяФайлаНастроек;
	КонецЕсли;
	Если ЗначениеЗаполнено(ТекстОшибки) Тогда
		Лог.КритичнаяОшибка(ТекстОшибки);
		ЗавершитьРаботу(1);
	КонецЕсли;

	// читаем настройки из файла
	НастройкиВыполнения = ПрочитатьФайлJSON(ИмяФайлаНастроек);
	Если НастройкиВыполнения = Неопределено Тогда
		Лог.КритичнаяОшибка("Неопределенная ошибка при чтении файла настроек: " + ИмяФайлаНастроек);
		ЗавершитьРаботу(1);
	ИначеЕсли ТипЗнч(НастройкиВыполнения) = Тип("Строка") Тогда
		Лог.КритичнаяОшибка("Ошибка при чтении файла настроек: " + ИмяФайлаНастроек + Символы.ПС + НастройкиВыполнения);
		ЗавершитьРаботу(1);
	КонецЕсли;

	ОсновнойСкрипт(НастройкиВыполнения);
КонецЕсли;