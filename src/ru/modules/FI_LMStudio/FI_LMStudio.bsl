//FI_LMStudio

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

&НаСервере
Функция ПолучитьОтветМодели(Знач ИмяМодели="", 
	Знач АтмосфераСистемы="", 
	Знач ТекстЗапроса="",
	Знач stream=Ложь,
	Знач temperature="0.6",
	Знач max_tokens=1000) Экспорт
	
	
	СтруктуруЗапроса = СформироватьСтруктуруЗапроса(ИмяМодели,АтмосфераСистемы,ТекстЗапроса,stream,temperature,max_tokens);
	СтрокаДляТела 	 = OPI_Инструменты.JSONСтрокой(СтруктуруЗапроса);
	
	Результат = ОтправитьЗапросМодели(СтрокаДляТела);
	
	Если Результат.choices.Количество() > 0 тогда
		Возврат Результат.choices[0].message.content
	КонецЕсли;
	
	Возврат "";
	
КонецФункции

&НаСервере
Функция СформироватьСтруктуруЗапроса(Знач ИмяМодели="", 
	Знач АтмосфераСистемы="", 
	Знач ТекстЗапроса="",
	Знач stream=Ложь,
	Знач temperature="0.6",
	Знач max_tokens=1000) Экспорт
	
	model = ИмяМодели;
	
	stream 		= stream;
	temperature = temperature;
	max_tokens 	= max_tokens;
	
	messages = Новый Массив;
	
	СистемноеСообщение = Новый Структура;
	СистемноеСообщение.Вставить("role", "system");
	СистемноеСообщение.Вставить("content", АтмосфераСистемы);
	
	ПользовательскоеСообщение = Новый Структура;
	ПользовательскоеСообщение.Вставить("role", "user");
	ПользовательскоеСообщение.Вставить("content", ТекстЗапроса);
	
	messages.Добавить(СистемноеСообщение);
	messages.Добавить(ПользовательскоеСообщение);
	
	СтруктуруЗапроса = Новый Структура("model, messages, temperature, max_tokens, stream", model, messages, temperature, max_tokens, stream);
	
	Возврат СтруктуруЗапроса;
	
КонецФункции

&НаСервере
Функция ОтправитьЗапросМодели(Знач СтрокаДляТела)

	HTTP = OPI_Инструменты.СоздатьСоединение("localhost",ложь,,,8080);
	
	ЗаголовокЗапросаHTTP = Новый Соответствие();
	ЗаголовокЗапросаHTTP.Вставить("Content-Type", "application/json");
	
	ЗапросHTTP = Новый HTTPЗапрос("/v1/chat/completions", ЗаголовокЗапросаHTTP);
	ЗапросHTTP.УстановитьТелоИзСтроки(СтрокаДляТела);
	
	ОтветHTTP 	= HTTP.ОтправитьДляОбработки(ЗапросHTTP);
	JSON 		= ОтветHTTP.ПолучитьТелоКакСтроку();

	Результат = OPI_Инструменты.JsonВСтруктуру(JSON, Ложь);
	Возврат Результат;

КонецФункции
