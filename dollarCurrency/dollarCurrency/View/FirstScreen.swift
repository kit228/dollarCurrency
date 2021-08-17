//
//  FirstScreen.swift
//  dollarCurrency
//
//  Created by Вениамин Китченко on 10.07.2021.
//

import UIKit
import CoreData // для сортировки при запросе к CoreData

class FirstScreen: UITableViewController, UpdateDelegate { // первый экран (tableViewController), UpdateDelegate - для обновления tableView из другого экрана
    
    
    let segueId = "toParameters"
    
    let refreshControlForTableView = UIRefreshControl() // объявляем Refresh Control
    
    var dateFromXml = String() // для xml-парсинга
    var value = String() // для xml-парсинга
    
    var currentCharacters = String() // для xml-парсинга
    
    
    var currencies: [Currency] = []
    
    
    // CoreData
    var coreDataCurrencies: [CurrencyCoreData] = []
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.applicationIconBadgeNumber = 0 // убираем бэйджи с иконки
    }
    
    func getCutencyFromCoreData() { // получаем данные из coreData
        //получаем данные с CoreData вместе с сортировкой
        let request = CurrencyCoreData.fetchRequest() as NSFetchRequest<CurrencyCoreData> // для сортировки
        let sort = NSSortDescriptor(keyPath: \CurrencyCoreData.date, ascending: false) // сортировка по убыванию
        request.sortDescriptors = [sort]
        do {
            //coreDataCurrencies = try context.fetch(CurrencyCoreData.fetchRequest()) // пытаемся получить данные из coreData
            coreDataCurrencies = try context.fetch(request) // пытаемся получить данные из coreData, сортированные по убыванию
            
            //print("Валюты из coreData", coreDataCurrencies.last?.date)
            if !coreDataCurrencies.isEmpty {
                for element in coreDataCurrencies {
                    //print("Дата валюты из CoreData = \(CustomOperations.dateToString(date: element.date))")
                    currencies.append(Currency(stringDate: CustomOperationsAndConstants.dateToString(date: element.date), value: element.value))
                }
                reloadTableView()
                coreDataCurrencies = [] // очищаем массив валют, полученный из CoreData
            }
        } catch let error as NSError {
            print("Не получается получить данные с CoreData \(error), \(error.userInfo)")
        }
    }
    
    func addCurrencyToCoreData(currency: Currency) { // сохраняем валюту в coreData
        let coredataCurrency = CurrencyCoreData(entity: CurrencyCoreData.entity(), insertInto: context) // новая валюта для CoreData
        let currencyDateOptional = CustomOperationsAndConstants.stringToDate(stringToDate: currency.stringDate)
        if let currencyDate = currencyDateOptional {
            coredataCurrency.date = currencyDate
            coredataCurrency.value = currency.value
            appDelegate.saveContext()
            coreDataCurrencies.append(coredataCurrency)
            //print("Валюты в coreDataCurrencies: \(coreDataCurrencies)")
        }
    }
    
    func deleteCurrenctiesFromCoreData() { // удаляем валюты из CoreData
        // 1 вариант (не проверял)
        
//        do {
//            let resultsFromCoreData = try context.fetch(CurrencyCoreData.fetchRequest()) // пытаемся получить данные из coreData
//            for element in resultsFromCoreData {
//                context.delete(element as! NSManagedObject)
//            }
//        } catch let error as NSError {
//            print("Не получилось взять данные из CoreData для удаления курсов валют, error: \(error)")
//        }
        
        // 2 вариант
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrencyCoreData")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch let error as NSError {
            print("Не получается удалить данные из CoreData, ошибка: \(error)")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControlForTableView.addTarget(self, action: #selector(refresh), for: .valueChanged) // действие, которое нужно выполнить при запуске refresh control
        self.tableView.addSubview(refreshControlForTableView)
        
        self.view.backgroundColor = .systemBackground // устанавливаем цвет фона согласно установленной теме ОС
        requestCurrencyAndParseXml() { // запрашиваем курсы валют и парсим XML
            do {
                //return
                print("Выполнен запрос курсов валют")
            }
        } onFailure: {
            self.getCutencyFromCoreData()
        }
        
    }
    
    @objc func refresh() { // действие при запуске Refresh control
        requestCurrencyAndParseXml() { // запрашиваем курсы валют и парсим XML
            completition: do {
                print("Выполнен запрос курсов валют")
                refreshControlForTableView.endRefreshing()
            }
        } onFailure: {
            
        }
    }
    
    func didUpdate(sender: ParametersScreen) { // действие делегата
        reloadTableView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) { // действие при изменение темы
        reloadTableView() // обновляем tableView, чтобы применились нужные цвета текста
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currencies.count // возвращаем количество строк в tavleView
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cellId")
        cell.selectionStyle = .none // чтобы не подсвечивалось
        cell.backgroundColor = .systemBackground // устанавливаем цвет фона ячейки согласно установленной теме ОС
        cell.textLabel?.textColor = .label // устанавливаем цвет текста (чтобы работал корректно в зависимости от цветовой темы ОС)
        //cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        cell.textLabel?.text = String(currencies[indexPath.row].value) // записываем информацию о валюте
        cell.detailTextLabel?.text = currencies[indexPath.row].stringDate // записываем дату
        
        switch traitCollection.userInterfaceStyle { // меняем цвет текста, в зависимости от темы
        case .light, .unspecified:
            cell.detailTextLabel?.textColor = .black
        case .dark:
            cell.detailTextLabel?.textColor = .white
        }
        
        if ParametersSettings.comparisonMoreThanNeedIsOn {
            if currencies[indexPath.row].value > ParametersSettings.parameterMoreThanNeed {
                cell.backgroundColor = .systemGreen
                cell.detailTextLabel?.textColor = .white
            }
        }
        if ParametersSettings.comparisonLessThanNeedIsOn {
            if currencies[indexPath.row].value < ParametersSettings.parameterLessThanNeed {
                cell.backgroundColor = .systemRed
                cell.textLabel?.textColor = .black
                cell.detailTextLabel?.textColor = .black
            }
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // действие по нажатию на ячейку
        //tableView.isUserInteractionEnabled = false
        //tableView.deselectRow(at: indexPath, animated: true) // снимаем подсвечивание выбранной ячейки
        toParametersScreen()
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData() // обновляем tableView в основном треде
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // в подготовге сегвея записываем делегат на себя
        let toParamScreen = segue.destination as? ParametersScreen
        toParamScreen?.delegate = self // записываем делегат
    }
    
    
    func toParametersScreen() {
        performSegue(withIdentifier: segueId, sender: nil)
    }
    
}




extension FirstScreen: XMLParserDelegate {
    
    func requestCurrencyAndParseXml(completition: () -> Void, onFailure: @escaping () -> Void) { // запрос курсов валют и парсинг
        guard let url = URL(string: CustomOperationsAndConstants.makeRequestString(howMuchDaysAgo: -30)) else {return}
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
        reloadTableView()
        deleteCurrenctiesFromCoreData() // удаляем валюты из CoreData
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
        //print(currencies)
        currencies.reverse() // разворачиваем массив, чтобы свежие валюты были сверху
        
        for element in currencies { // добавляем по одной валюты из coreData
            addCurrencyToCoreData(currency: element)
        }
        reloadTableView()
    }
    
    
}
