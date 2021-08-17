//
//  LocalNotificationManager.swift
//  dollarCurrency
//
//  Created by Вениамин Китченко on 17.08.2021.
//

import Foundation
import UserNotifications
import UIKit

struct LocalNotificationManager {
    
    
    static func askPermissionForUserNotifications() { // спрашиваем разрешение выполнять отображать локальные нотифиакции
        // спрашиваем разрешение
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in // проверяем, дал ли пользователь разрешение (алерт, бэйдж и звук)
            if granted == true {
                print("Разрешение для локальных нотификаций получено")
            } else if let error = error {
                print("Разрешение для локальных нотификаций не получено: \(error)")
            }
        }
        
        // создаем notificationContent
//        let content = UNMutableNotificationContent()
//        content.title = "KEK"
//        content.body = "Makaki"
        
        // создаем Notification Trigger
        
        //let trigger = trigger§
    }
    
    
    static func createNotification(title: String, body: String) { //  создать нотификацию
        let content = UNMutableNotificationContent() // создаем notificationConten
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1) // ставим бэйджик
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(1), repeats: false) // создаем триггер по времени (ставим 1, чтобы выполнилось почти сразу)
        
        // создаем request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        // регистрируем request
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests() // удаляем ожидаемые нотификации
        print("Создаем нотификацию")
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Не удалось зарегистрировать нотификацию")
            }
        }
        
    }
}
