//
//  File.swift
//  
//
//  Created by Сергей Лисенков on 12.04.2022.
//

import Foundation
import Vapor

final class TelegramBot {
    
    // MARK: - Private
    
    private struct Constants {
        static let baseURI = "https://api.telegram.org/"
        static let chatID = "-795285272"
        static let botToken = "bot5254003890:AAGxGkdT3pxm0FFc4rDkNYbJFBMej9nqXm4"
        static let messageAction = "/sendMessage"
    }
    
    private let client: Client
    
    // MARK: - Initialize
    
    init(client: Client) {
        self.client = MIDProxyClient(clien: client)
    }
    
    // MARK: - Public
    
    func sendResult(message: String) async throws {
        let uri = Constants.baseURI + Constants.botToken + Constants.messageAction
        let messageModel = TelegramMessageModel(chatId: Constants.chatID, text: message)
        let result = try await client.post(URI(string: uri), content: messageModel)
        
    }
    
}
