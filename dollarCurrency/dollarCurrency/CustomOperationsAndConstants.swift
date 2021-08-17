//
//  CustomOperations.swift
//  dollarCurrency
//
//  Created by Вениамин Китченко on 11.08.2021.
//

import Foundation
import UIKit

class CustomOperationsAndConstants: NSObject { // NSObject для xml парсинга
    
    static let usDollarId = "R01235"
    var currentCharacters = String() // для xml-парсинга
    var dateFromXml = String() // для xml-парсинга
    var value = String() // для xml-парсинга
    var currencies: [Currency] = [] // для xml-парсинга
    
    
    
    
    // MARK: сохранение в UserDefaults (получение параметров при запуске приложения в AppDelegate в DidFinishLaunch)
    
    enum SaveOrGet { // для параметров в функциях изменения данных в UserDefaults
        case save, get
    }
    
    static func UDefaultsParameterMoreThanNeed(doubleValue: Double?, saveOrGet: SaveOrGet) {
        switch saveOrGet {
        case .save:
            UserDefaults.standard.setValue(doubleValue, forKey: "MoreThanNeed")
        case .get:
            if let value = UserDefaults.standard.object(forKey: "MoreThanNeed") as? Double {
                ParametersSettings.parameterMoreThanNeed = value
            }
        }
    }
    
    static func UDefaultsParameterLessThanNeed(doubleValue: Double?, saveOrGet: SaveOrGet) {
        switch saveOrGet {
        case .save:
            UserDefaults.standard.setValue(doubleValue, forKey: "LessThanNeed")
        case .get:
            if let value = UserDefaults.standard.object(forKey: "LessThanNeed") as? Double {
                ParametersSettings.parameterLessThanNeed = value
            }
        }
    }
    
    static func UDefaultsComparisonMoreThanNeedIsOn(bool: Bool?, saveOrGet: SaveOrGet) {
        switch saveOrGet {
        case .save:
            UserDefaults.standard.setValue(bool, forKey: "ComparisonMoreIsOn")
        case .get:
            if let value = UserDefaults.standard.object(forKey: "ComparisonMoreIsOn") as? Bool {
                ParametersSettings.comparisonMoreThanNeedIsOn = value
            }
        }
    }
    
    static func UDefaultsComparisonLessThanNeedIsOn(bool: Bool?, saveOrGet: SaveOrGet) {
        switch saveOrGet {
        case .save:
            UserDefaults.standard.setValue(bool, forKey: "ComparisonLessIsOn")
        case .get:
            if let value = UserDefaults.standard.object(forKey: "ComparisonLessIsOn") as? Bool {
                ParametersSettings.comparisonLessThanNeedIsOn = value
            }
        }
    }
    
    
    
    
    
    // преобразование даты в строку и обратно
    static func stringToDate(stringToDate: String) -> Date? { // перевод строки в дату
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let dateFromString = dateFormatter.date(from: stringToDate)
        return dateFromString
    }
    
    static func dateToString(date: Date) -> String { // перевод даты в строку
        var stringForReturn = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        stringForReturn = dateFormatter.string(from: date)
        
        return stringForReturn
    }
    
    
    
    static func getDates(howMuchDaysAgo: Int) -> (date30DaysAgoString: String, dateTodayString: String) { // получаем дату howMuchDaysAgo дней назад и текущую в формате строки
        var dateDaysAgoString = ""
        var dateTodayString = ""
        
        //let date = Date()
        
        let dateDaysAgo = Calendar.current.date(byAdding: .day, value: howMuchDaysAgo, to: Date())
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        guard let dateDaysAgo = dateDaysAgo else { // unwrapping date30DaysAgo
            print("Не получилось развернуть date30DaysAgo")
            return (dateDaysAgoString, dateTodayString)
        }
        dateDaysAgoString = dateFormatter.string(from: dateDaysAgo)
        dateTodayString = dateFormatter.string(from: Date())
        return (dateDaysAgoString, dateTodayString)
    }
    
    static func makeRequestString(howMuchDaysAgo: Int) -> String { // формируем строку запроса
        let dates = getDates(howMuchDaysAgo: howMuchDaysAgo)
        return "http://cbr.ru/scripts/XML_dynamic.asp?date_req1=" + dates.date30DaysAgoString + "&date_req2=" + dates.dateTodayString + "&VAL_NM_RQ=" + CustomOperationsAndConstants.usDollarId
    }
    
    
}


extension CustomOperationsAndConstants: XMLParserDelegate {
    
    // запрос валют в бэкграунде
    func requestCurrencyAndParseXml(completition: () -> Void, onFailure: @escaping () -> Void) { // запрос курсов валют и парсинг
        guard let url = URL(string: CustomOperationsAndConstants.makeRequestString(howMuchDaysAgo: -3)) else {return} // ставим -3, чтобы были даты с учетом выходных
        let task = URLSession.shared.dataTask(with: url) { (data, reponse, error) in // делаем URL-запрос
            guard let responsedData = data else {
                print("Не был получен ответ на запрос курсов валют, ошибка: ", error ?? "неизвестная ошибка")
                onFailure()
                return
            }
            let parser = XMLParser(data: responsedData)
            parser.delegate = self
            if parser.parse() {
                //print(self.currencies)
            }
        }
        .resume() // для URLDataTask
        completition() // помечаем, что функция выполнена
    }
    
    func parserDidStartDocument(_ parser: XMLParser) {
        currencies = [] // очищаем массив валют
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "Record" {
            //print("attributes: \(attributeDict)")
            dateFromXml = attributeDict["Date"] ?? "" // заполняем аттрибутом даты из словаря при парсинге xml
            
            
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        //print("строка - ", string)
        currentCharacters = string // записываем строку из парсера
        
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "Value" {
            value = currentCharacters.replacingOccurrences(of: ",", with: ".") // заменяем запятые на точки, чтобы потом строку перевести в Double
            //print("value = \(value)")
            if let doubleValue = Double(value) {
                let currency = Currency(stringDate: dateFromXml, value: doubleValue)
                currencies.append(currency)
            }
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) { // окончание парснига XML
        //print("курсы из бэкграунда: \(currencies)")
        
        guard let currencyLastValue = currencies.last?.value  else {return}
        if let currencyLastValue = currencies.last?.value {
            if ParametersSettings.comparisonMoreThanNeedIsOn && (currencyLastValue > ParametersSettings.parameterMoreThanNeed) { // проверяем рост валюты выше установленного значения
                let title = "Рост доллара"
                let body = "USD = " + String(currencyLastValue)
                print("Установление нотификации")
                LocalNotificationManager.createNotification(title: title, body: body) // создаем нотификацию
            } else if ParametersSettings.comparisonLessThanNeedIsOn && (currencyLastValue < ParametersSettings.parameterLessThanNeed) { // проверяем падение валюты ниже установленного зачения
                let title = "Падение доллара"
                let body = "USD = " + String(currencyLastValue)
                LocalNotificationManager.createNotification(title: title, body: body) // создаем нотификацию
            }
        }
    }
    
    
}
