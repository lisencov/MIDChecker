//
//  File.swift
//  
//
//  Created by Сергей Лисенков on 12.04.2022.
//

import Foundation
import Vapor

struct TelegramMessageModel: Content {
    let chatId: String
    let text: String
    let isSilent: Bool
    
    static var defaultContentType: HTTPMediaType {
        return .json
    }
    
    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case text = "text"
        case isSilent = "disable_notification"
    }
}
