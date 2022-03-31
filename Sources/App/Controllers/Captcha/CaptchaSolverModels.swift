//
//  File.swift
//  
//
//  Created by Сергей Лисенков on 31.03.2022.
//

import Foundation
import Vapor

struct AnyCaptchaTaskModel: Content {
    
    struct Task: Codable {
        let type = "ImageToTextTask"
        let body: String
    }
    
    let clientKey: String
    let task: Task
    
    init(clientKey: String, base64Image: String) {
        self.clientKey = clientKey
        self.task = Task(body: base64Image)
    }
    
}

struct AnyCaptchaCreatedTaskModel: Decodable {
    let taskId: Int?
    let errorDescription: String?
}

struct AnyCaptchaCheckModel: Content {
    let clientKey: String
    let taskId: Int
    
}

struct AnyCaptchaResultModel: Decodable {
    
    struct Solution: Decodable {
        let text: String
    }
    
    enum Status: String, Decodable {
        case ready
        case processing
    }
    
    let status: Status?
    let solution: Solution?
    let errorDescription: String?
}
