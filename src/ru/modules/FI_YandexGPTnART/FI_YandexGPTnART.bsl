//FI_YandexGPTnART

// MIT License

// Copyright (c) 2025 zzeroilia

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// https://github.com/zzeroilia/FullIntegration1C

// BSLLS:Typo-off
// BSLLS:LatinAndCyrillicSymbolInWord-off
// BSLLS:IncorrectLineBreak-off
// BSLLS:UnusedLocalVariable-off
// BSLLS:UsingServiceTag-off
// BSLLS:NumberOfOptionalParams-off

//@skip-check module-unused-local-variable
//@skip-check method-too-many-params
//@skip-check module-structure-top-region
//@skip-check module-structure-method-in-regions
//@skip-check wrong-string-literal-content
//@skip-check use-non-recommended-method     


//Код powershell для получения токена:
//
//Получить oathtoken по ссылке https://oauth.yandex.ru/verification_code
//
//$yandexPassportOauthToken = "ваш oathtoken" 
//$Body = @{ yandexPassportOauthToken = "$yandexPassportOauthToken" } | ConvertTo-Json -Compress 
//Invoke-RestMethod -Method 'POST' -Uri 'https://iam.api.cloud.yandex.net/iam/v1/tokens' -Body $Body -ContentType 'Application/json' | Select-Object -ExpandProperty iamToken
//

//Параметры:
//-ИспользуемаяМодель(строкой):
//"yandexgpt"
//ИЛИ
//"yandex-art"
Функция ПолучитьОтветОтЯндекса(Знач ИспользуемаяМодель="yandexgpt",
	Знач КодОтЯндексКлауд,
	Знач Токен,
	Знач АтмосфераСистемы="", 
	Знач ТекстЗапроса="") Экспорт
	
	Возврат ПолучитьОписание(ИспользуемаяМодель,КодОтЯндексКлауд,Токен,ТекстЗапроса,АтмосфераСистемы);
	
КонецФункции

Функция ПолучитьКартинкуПоID(Знач Токен,
	Знач ID) Экспорт	
	
	HTTP = OPI_Инструменты.СоздатьСоединение("llm.api.cloud.yandex.net",Истина,,,443);
	
	ЗаголовокЗапросаHTTP = Новый Соответствие();
	ЗаголовокЗапросаHTTP.Вставить("Authorization", "Bearer " + Токен);
	ЗаголовокЗапросаHTTP.Вставить("Content-Type", "application/json");
	
	ЗапросHTTP = Новый HTTPЗапрос("/operations/"+ID, ЗаголовокЗапросаHTTP);	
	
	ОтветHTTP 	= HTTP.Получить(ЗапросHTTP);
	
	Если ОтветHTTP.КодСостояния = 200 тогда
		JSONimage = ДесериализоватьJSONКартинки(ОтветHTTP.ПолучитьТелоКакСтроку());
		
		Если JSONimage <> Неопределено тогда
			Возврат JSONimage;
		КонецЕсли;
	КонецЕсли;
	
КонецФункции

//////////////////////////////////////////

Функция ПолучитьОписание(ИспользуемаяМодель,КодОтЯндексКлауд,Токен,ТекстЗапроса,АтмосфераСистемы)
	
	СтруктуруЗапроса = СформироватьСтруктуруЗапроса(ИспользуемаяМодель,КодОтЯндексКлауд,ТекстЗапроса,АтмосфераСистемы);
	СтрокаДляТела = OPI_Инструменты.JSONСтрокой(СтруктуруЗапроса);
	
	Результат = ОтправитьЗапросКЯндексКлауд(ИспользуемаяМодель,СтрокаДляТела,Токен);
	Если ИспользуемаяМодель="yandexgpt" тогда
		Если Результат.result.alternatives.Количество() > 0 Тогда
			Возврат Результат.result.alternatives[0].message.text;
		КонецЕсли;
	ИначеЕсли ИспользуемаяМодель="yandex-art" Тогда
		Если НЕ Результат.Свойство("error") тогда
			Возврат Результат.id;
		КонецЕсли;
	КонецЕсли;
	
	Возврат "";
	
КонецФункции

Функция ОтправитьЗапросКЯндексКлауд(ИспользуемаяМодель,СтрокаДляТела, Токен)
	
	HTTP = OPI_Инструменты.СоздатьСоединение("llm.api.cloud.yandex.net",Истина,,,);
	
	ЗаголовокЗапросаHTTP = Новый Соответствие();
	ЗаголовокЗапросаHTTP.Вставить("Authorization", "Bearer " + Токен);
	ЗаголовокЗапросаHTTP.Вставить("Content-Type", "application/json");
	
	Если ИспользуемаяМодель="yandexgpt" тогда
		ЗапросHTTP = Новый HTTPЗапрос("foundationModels/v1/completion", ЗаголовокЗапросаHTTP);
	ИначеЕсли ИспользуемаяМодель="yandex-art" Тогда
		ЗапросHTTP = Новый HTTPЗапрос("foundationModels/v1/imageGenerationAsync", ЗаголовокЗапросаHTTP);
	КонецЕсли;
	
	ЗапросHTTP.УстановитьТелоИзСтроки(СтрокаДляТела);
	
	ОтветHTTP 	= HTTP.ОтправитьДляОбработки(ЗапросHTTP);
	JSON 		= ОтветHTTP.ПолучитьТелоКакСтроку();
	
	Результат = OPI_Инструменты.JsonВСтруктуру(JSON, Ложь);
	Возврат Результат;
	
КонецФункции

Функция СформироватьСтруктуруЗапроса(ИспользуемаяМодель,КодОтЯндексКлауд,ТекстЗапроса,АтмосфераСистемы)
		
	Если ИспользуемаяМодель="yandexgpt" тогда
		model = "gpt";
		
		completionOptions = Новый Структура();
		completionOptions.Вставить("stream", Ложь);
		completionOptions.Вставить("temperature", 0.6);
		completionOptions.Вставить("maxTokens", 5000);
		
		messages = Новый Массив;
		
		System = Новый Структура;
		System.Вставить("role", "system");
		System.Вставить("text", АтмосфераСистемы);
		
		User = Новый Структура;
		User.Вставить("role", "user");
		User.Вставить("text", ТекстЗапроса);
		
		messages.Добавить(System);
		messages.Добавить(User);
				
	ИначеЕсли ИспользуемаяМодель="yandex-art" Тогда
		model = "art";
		
		aspectRatio = новый Структура();
		aspectRatio.Вставить("heightRatio", "4");
		aspectRatio.Вставить("widthRatio",  "3");
		
		completionOptions = Новый Структура();
		completionOptions.Вставить("seed", "0");
		completionOptions.Вставить("aspectRatio", aspectRatio); 
		
		
		messages = Новый Массив;
		
		User = Новый Структура;
		User.Вставить("weight", "1");
		User.Вставить("text", ТекстЗапроса);
		
		messages.Добавить(User);
				
	КонецЕсли;
	
	modelUri = model+"://"+КодОтЯндексКлауд+"/"+ИспользуемаяМодель+"/latest";
	СтруктуруЗапроса = Новый Структура("modelUri, completionOptions, messages", modelUri, completionOptions, messages);
	
	Возврат СтруктуруЗапроса;
	
КонецФункции

Функция ДесериализоватьJSONКартинки(JSON)
	
	ЧтениеJSON = Новый ЧтениеJSON();
	ЧтениеJSON.УстановитьСтроку(JSON);
	JSON = ПрочитатьJSON(ЧтениеJSON,ИСТИНА);
	ЧтениеJSON.Закрыть();
	
	Для каждого строка из JSON цикл
		
		Если ТипЗнч(Строка.Значение) = Тип("Соответствие") и Строка.Ключ = "response" тогда
			Для каждого СтрокаФото из Строка.значение цикл
				
				Если СтрокаФото.ключ = "image" И ЗначениеЗаполнено(СтрокаФото.Значение) тогда
					Возврат СтрокаФото.Значение;
				КонецЕсли;
				
			КонецЦикла;
		КонецЕсли;
		
		Возврат Неопределено;	
	КонецЦикла;
КонецФункции
