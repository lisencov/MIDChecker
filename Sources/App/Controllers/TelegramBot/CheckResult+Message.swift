//
//  File.swift
//  
//
//  Created by Сергей Лисенков on 12.04.2022.
//

import Foundation

extension CheckResult {
    
    func message(clienID: String, secCode: String) -> String {
        switch self.status {
        case .available:
            return "!!! ВОЗМОЖНО ПОЯВИЛАСЬ ЗАПИСЬ, БЕГОМ ТУДА !!! \n Ccылка: http://bishkek.kdmid.ru/queue/OrderInfo.aspx?id=\(clienID)&cd=\(secCode) \n Время проверки: \(Date.now)"
        case .notAvailable:
            return "Записи нет. \n Время проверки: \(Date.now)"
        }
    }
}
