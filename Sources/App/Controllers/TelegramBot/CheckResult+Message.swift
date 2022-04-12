//
//  File.swift
//  
//
//  Created by Сергей Лисенков on 12.04.2022.
//

import Foundation

extension CheckResult {
    
    var message: String {
        switch self.status {
        case .available:
            return "!!! ВОЗМОЖНО ПОЯВИЛАСЬ ЗАПИСЬ, БЕГОМ ТУДА !!! \n Ccылка: http://bishkek.kdmid.ru/queue/OrderInfo.aspx?id=\(Configuration.clientID.value)&cd=\(Configuration.secureID.value) \n Время проверки: \(Date())"
        case .notAvailable:
            return "Записи нет. \n Время проверки: \(Date())"
        }
    }
}
