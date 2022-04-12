//
//  Configuration.swift
//  
//
//  Created by Сергей Лисенков on 12.04.2022.
//

import Foundation
import Vapor

enum Configuration {
    
    case solverAPIKey
    case telegramAPIKey
    case telegramChatID
    case clientID
    case secureID
    
    var value: String {
        switch self {
        case .solverAPIKey:
            return Environment.get("SOLVER_KEY") ?? ""
        case .telegramAPIKey:
            return Environment.get("TELEGRAM_KEY") ?? ""
        case .clientID:
            return Environment.get("CLIENT_ID") ?? ""
        case .secureID:
            return Environment.get("SECURE_ID") ?? ""
        case .telegramChatID:
            return Environment.get("CHAT_ID") ?? ""
        }
    }
}
