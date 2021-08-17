//
//  AppDelegate.swift
//  dollarCurrency
//
//  Created by Вениамин Китченко on 10.07.2021.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    lazy var persistentContainer: NSPersistentContainer = { // для CoreData persistentContainer
        let container = NSPersistentContainer(name: "DollarCurrencyCoreDataModel")
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            print(storeDescription)
            if let error = error as NSError? {
                fatalError("Ошибка coreData в persistentContainer in AppDelegate \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // to save managedObject CoreData
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges { // если есть какие-то изменения, то сохраняем
            do {
                try context.save()
            } catch {
                let err = error as NSError
                fatalError("Ошибка coreData в saveContext in AppDelegate \(err), \(err.userInfo)")
            }
        }
    }
    
    func getAllPatametersFromUserDefaults() { // получение всех параметров из UserDefaults
        CustomOperationsAndConstants.UDefaultsComparisonMoreThanNeedIsOn(bool: nil, saveOrGet: .get)
        CustomOperationsAndConstants.UDefaultsComparisonLessThanNeedIsOn(bool: nil, saveOrGet: .get)
        
        CustomOperationsAndConstants.UDefaultsParameterMoreThanNeed(doubleValue: nil, saveOrGet: .get)
        CustomOperationsAndConstants.UDefaultsParameterLessThanNeed(doubleValue: nil, saveOrGet: .get)
    }

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool { // внутри вызывается после того, как приложение закончило грузиться
        // Override point for customization after application launch.
        getAllPatametersFromUserDefaults() // получение всех параметров из UserDefaults
        UIApplication.shared.setMinimumBackgroundFetchInterval(ParametersSettings.timeToBackgroundFetch) // установление параметра запуска из background
        return true
    }
    
    
    //MARK: Работа с бэкграундом fetch
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) { // действие при запуске процесса из background
        let customOperations = CustomOperationsAndConstants()
        customOperations.requestCurrencyAndParseXml() { // запрашиваем курсы валют и парсим XML
            completition: do {
                print("Выполнен запрос курсов валют в бэкграунде")
                completionHandler(.newData)
            }
        } onFailure: {
            print("Запрос курсов валют в бэкграунде не выполнен")
            completionHandler(.failed)
        }
    }
    
//    func applicationDidBecomeActive(_ application: UIApplication) {
//        UIApplication.shared.applicationIconBadgeNumber = 0 // убираем бэйджи с иконки
//    }
    
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

