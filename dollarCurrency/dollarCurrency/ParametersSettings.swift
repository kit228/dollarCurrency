//
//  ParametersSettings.swift
//  dollarCurrency
//
//  Created by Вениамин Китченко on 06.08.2021.
//

import Foundation

class ParametersSettings {
    
    ///static let parametersSettingsSingletone = ParametersSettings
    
    static var comparisonMoreThanNeedIsOn: Bool = false
    static var comparisonLessThanNeedIsOn: Bool = false
    
    static var parameterMoreThanNeed: Double = 0.00
    static var parameterLessThanNeed: Double = 0.00
    
    static let timeToBackgroundFetch: Double = 43200 // временной интервал обновления в бэкграунде (в секундах)
}
