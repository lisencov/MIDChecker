//
//  File.swift
//  
//
//  Created by Сергей Лисенков on 31.03.2022.
//

import Foundation
import SwiftSoup
import Vapor

final class MIDParses {
    
    private struct Constants {
        static let captchaBaseURL = "https://bishkek.kdmid.ru/queue/"
        static let captchaID = "#ctl00_MainContent_imgSecNum"
    }
    
    public static func getDocument(from response: ClientResponse) throws -> Document {
        guard let byteBuffer = response.body else {
            throw Abort(.custom(code: 400, reasonPhrase: "Can't read biteBuffer"))
        }
        let responseData = Data(buffer: byteBuffer)
        return try MIDParses.getDocument(from: responseData)
    }
    
    public static func getDocument(from data: Data) throws -> Document {
        guard let stringFromData = String(data: data, encoding: .utf8) else {
            throw Abort(.custom(code: 400, reasonPhrase: "Can't read captcha data"))
        }
        
        return try SwiftSoup.parse(stringFromData)
    }
    
    public static func parseCaptchaLink(from document: Document) throws -> String {
        let captchaElement = try document.select(Constants.captchaID)
        let href = try captchaElement.attr("src")
        return Constants.captchaBaseURL + href
    }
    
    public static func capthchaFormData(for document: Document,
                                        userID: String,
                                        secureCode: String,
                                        captcha: String) throws -> CaptchaFormModel {
        guard let viewState = try document.selectFirst(CaptchaFormModel.CodingKeys.viewState),
              let viewStateGenerator = try document.selectFirst(CaptchaFormModel.CodingKeys.viewStateGenerator),
              let eventValidation = try document.selectFirst(CaptchaFormModel.CodingKeys.eventValidation)
        else {
            throw Abort(.custom(code: 400, reasonPhrase: "Can't read captcha form data"))
        }
         
        return CaptchaFormModel(userID: userID,
                                secureCode: secureCode,
                                captcha: captcha,
                                eventARGET: nil,
                                eventARGUMENT: nil,
                                viewState: viewState,
                                viewStateGenerator: viewStateGenerator,
                                eventValidation: eventValidation,
                                buttonText: "Далее")
    }
}

extension Document {
    
    func selectFirst(_ codingKey: CodingKey) throws -> String? {
        return try self.select(codingKey).first()?.attr("value")
    }
    
    func select(_ codingKey: CodingKey) throws -> Elements {
        return try self.select("#\(codingKey.stringValue)")
    }
    
    func select(id: String) throws -> Elements {
        return try self.select("#\(id)")
    }
    
}
