//
//  File.swift
//  
//
//  Created by Сергей Лисенков on 31.03.2022.
//

import Foundation
import Vapor

struct AnyCaptchaTaskModel: Content {
    
    let key: String
    let method: String
    let body: String
    let json: Int
    
    static var defaultContentType: HTTPMediaType {
        return .formData
    }
    
    init(key: String, body: String) {
        self.key = key
        self.body = body
        self.method = "base64"
        self.json = 1
    }
}

struct AnyCaptchaCreatedTaskModel: Decodable {
    let request: Int?
    let errorDescription: String?
}

struct AnyCaptchaCheckModel: Content {
    let key: String
    let id: Int
    var action = "get"
    var json = 1
    
    static var defaultContentType: HTTPMediaType {
        return .formData
    }
}

struct AnyCaptchaResultModel {
    
    private struct Success: Decodable {
        let status: Int
        let request: String
    }
    
    enum Status {
        case ready(result: String)
        case processing
        case error(descript: String)
    }
    
    let status: Status
    
    static func fromBiteBuffer(_ biteBuffer: ByteBuffer) -> AnyCaptchaResultModel {
        do {
            let result = try JSONDecoder().decode(Success.self, from: biteBuffer)
            if result.status == 1 {
                return AnyCaptchaResultModel(status: .ready(result: result.request))
            } else {
                return AnyCaptchaResultModel(status: .processing)
            }
        } catch {
            let plainText = String(buffer: biteBuffer)
            if plainText == "CAPCHA_NOT_READY" {
                return AnyCaptchaResultModel(status: .processing)
            } else {
                return AnyCaptchaResultModel(status: .error(descript: plainText))
            }
        }
    }
}
