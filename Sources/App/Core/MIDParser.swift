//
//  File.swift
//  
//
//  Created by Сергей Лисенков on 31.03.2022.
//

import Foundation
import SwiftSoup
import Vapor

/// Parse data on Kyrgiz MID service.
final class MIDParses {
    
    // MARK: - Constants
    
    private struct Constants {
        static let captchaBaseURL = "https://bishkek.kdmid.ru/queue/"
        static let captchaID = "ctl00_MainContent_imgSecNum"
        static let calendarID = "ctl00_MainContent_Calendar"
    }
    
    // MARK: - Public
    
    /// Parse SwiftSoup.Document from Response.
    ///
    /// - Parameter response: Server response.
    /// - Returns: Parsed SwiftSoup.Document.
    public static func getDocument(from response: ClientResponse) throws -> Document {
        guard let byteBuffer = response.body else {
            throw Abort(.custom(code: 400, reasonPhrase: "Can't read biteBuffer"))
        }
        let responseData = Data(buffer: byteBuffer)
        return try MIDParses.getDocument(from: responseData)
    }
    
    
    static func getDocument(from data: Data) throws -> Document {
        guard let stringFromData = String(data: data, encoding: .utf8) else {
            throw Abort(.custom(code: 400, reasonPhrase: "Can't read captcha data"))
        }
        
        return try SwiftSoup.parse(stringFromData)
    }
    
    /// Parse html document with Captcha.
    /// Will throw if document doesn't have captcha element.
    ///
    /// - Parameter document: SwiftSoup.Document
    /// - Returns: Actual captchas image link.
    public static func parseCaptchaLink(from document: Document) throws -> String {
        let captchaElement = try document.select(id: Constants.captchaID)
        let href = try captchaElement.attr("src")
        return Constants.captchaBaseURL + href
    }
    
    /// Parse html document with Calendar.
    /// Will throw if document doesn't have Calendar element.
    ///
    /// - Parameter document: SwiftSoup.Document
    /// - Returns: Result of parsing. It will be success if calendar element doesn't have disabled attribute.
    public static func parseCalendarDocument(from document: Document) throws -> CheckResult {
        guard let calendar = try document.select(id: Constants.calendarID).first() else {
            throw Abort(.custom(code: 400, reasonPhrase: "Can't find calendar element on page"))
        }
        
        let attributeValue = (try? calendar.attr("disabled")) ?? ""
        let status: CheckResult.Status = attributeValue == "disabled" ? .notAvailable : .available
        return CheckResult(status: status)
    }
    
    /// Build encodable model for captchas checking request.
    ///
    /// - Parameters:
    ///   - document: Original document with captcha. It contains service information.
    ///   - userID: Client ID.
    ///   - secureCode: Client secure code.
    ///   - captcha: Solved captcha.
    /// - Returns: Encodable form model.
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
    
    /// Build encodable model for useless page.
    ///
    /// - Parameter document: Original useless page document. It contains service information.
    /// - Returns: Encodable form model.
    public static func uselessPageFormData(for document: Document) throws -> UselessPageFormModel {
        let selector = Selector<UselessPageFormModel.CodingKeys>(document: document)
        guard let viewState = try selector.first(.viewState),
              let viewStateGenerator = try selector.first(.viewStateGenerator),
              let eventValidator = try selector.first(.eventValidation) else {
                  throw Abort(.custom(code: 400, reasonPhrase: "Can't read useless form data"))
              }
        
        return UselessPageFormModel(viewState: viewState, viewStateGenerator: viewStateGenerator, eventValidation: eventValidator)
    }
}

private class Selector<T: CodingKey> {
    
    private let document: Document
    
    init(document: Document) {
        self.document = document
    }
    
    func first(_ key: T) throws -> String? {
        return try self.document.selectFirst(key)
    }
}

private extension Document {
    
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
