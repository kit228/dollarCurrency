//
//  CurrencyCoreData+CoreDataProperties.swift
//  dollarCurrency
//
//  Created by Вениамин Китченко on 10.08.2021.
//
//

import Foundation
import CoreData


extension CurrencyCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrencyCoreData> {
        return NSFetchRequest<CurrencyCoreData>(entityName: "CurrencyCoreData")
    }

    @NSManaged public var date: Date
    @NSManaged public var value: Double

}

extension CurrencyCoreData : Identifiable {

}
