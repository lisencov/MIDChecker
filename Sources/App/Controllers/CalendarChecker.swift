//
//  File.swift
//  
//
//  Created by Сергей Лисенков on 31.03.2022.
//

import Foundation
import Vapor
import SwiftSoup

final class CalendarChecker {
    
    private let client: Client
    private let userID: Int
    private let secCode: String
    private lazy var captchaSolver = CaptchaSolver()
    
    init(userID: Int, secCode: String, client: Client) {
        self.client = client
        self.userID = userID
        self.secCode = secCode
    }
    
    private struct Constants {
        static func captchaLink(userID: Int, secCode: String) -> URI {
            return URI(string: "https://bishkek.kdmid.ru/queue/OrderInfo.aspx?id=\(userID)&cd=\(secCode)")
        }
    }
    
    func check() async throws -> String {
        let nexDocument = try await self.passCaptcha(userID: self.userID, secCode: self.secCode)
        return "OK"
    }
    
    // MARK: - Captcha Step
    
    /// Returns next page if captcha passes success.
    private func passCaptcha(userID: Int, secCode: String) async throws -> Document {
        let captchaDocument = try await self.requestCaptchaPage(userID: userID, secCode: secCode)
        let captchaLink = try MIDParses.parseCaptchaLink(from: captchaDocument)
        let captcha = try await self.captchaSolver.solveCaptcha(url: captchaLink, client: self.client)
        let captchaForm = try MIDParses.capthchaFormData(for: captchaDocument, userID: "\(userID)", secureCode: secCode, captcha: captcha)
        let uselessPageDocument = try await self.sendCaptchaForm(captchaForm)
        return uselessPageDocument
    }
    
    private func requestCaptchaPage(userID: Int, secCode: String) async throws -> Document {
        let response = try await self.client.get(Constants.captchaLink(userID: userID, secCode: secCode))
        return try MIDParses.getDocument(from: response)
    }
    
    private func sendCaptchaForm(_ captchaForm: CaptchaFormModel) async throws -> Document {
        let response = try await self.client.post(Constants.captchaLink(userID: self.userID, secCode: self.secCode),
                                                  headers: .init([]),
                                                  content: captchaForm)
        return try MIDParses.getDocument(from: response)
    }
}
