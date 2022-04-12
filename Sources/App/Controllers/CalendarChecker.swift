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
    
    // MARK: - Constants
    
    private struct Constants {
        static func captchaLink(userID: Int, secCode: String) -> URI {
            return URI(string: "https://bishkek.kdmid.ru/queue/OrderInfo.aspx?id=\(userID)&cd=\(secCode)")
        }
    }
    
    // MARK: - Private
    
    private let client: MIDProxyClient
    private let userID: Int
    private let secCode: String
    private lazy var captchaSolver = CaptchaSolver()
    
    // MARK: - Initialize
    
    /// Initialize.
    ///
    /// - Parameters:
    ///   - userID: Client ID.
    ///   - secCode: Client secure code.
    ///   - client: HTTP client.
    init(userID: Int, secCode: String, client: Client) {
        self.client = MIDProxyClient(clien: client)
        self.userID = userID
        self.secCode = secCode
    }
    
    // MARK: - Public
    
    /// Check booking availability.
    ///
    /// - Returns: Encodable result model.
    func check() async throws -> CheckResult {
        // 1. Pass captcha step. Get useless page as result.
        let uselessDocument = try await self.passCaptcha(userID: self.userID, secCode: self.secCode)
        
        // 2. Wait to look like a human.
        try await Task.sleep(nanoseconds: 1500000000)
        
        // 3. Pass useless page. Get calendar page as result.
        let calendarDocument = try await self.passUselessDocument(uselessDocument)
        
        // 4. Parse calendar page and get result.
        return try self.checkCalendarDocument(calendarDocument)
    }
    
    // MARK: - Captcha Step
    
    /// Returns next page if captcha passes success.
    private func passCaptcha(userID: Int, secCode: String) async throws -> Document {
        let captchaDocument = try await self.requestCaptchaPage(userID: userID, secCode: secCode)
        let captchaLink = try MIDParses.parseCaptchaLink(from: captchaDocument)
        let solvedCaptcha = try await self.captchaSolver.solveCaptcha(url: captchaLink, client: self.client)
        let captchaForm = try MIDParses.capthchaFormData(for: captchaDocument, userID: "\(userID)", secureCode: secCode, captcha: solvedCaptcha)
        let uselessPageDocument = try await self.sendCaptchaForm(captchaForm)
        return uselessPageDocument
    }
    
    private func requestCaptchaPage(userID: Int, secCode: String) async throws -> Document {
        let response = try await self.client.get(Constants.captchaLink(userID: userID, secCode: secCode))
        return try MIDParses.getDocument(from: response)
    }
    
    private func sendCaptchaForm(_ captchaForm: CaptchaFormModel) async throws -> Document {
        let uri = Constants.captchaLink(userID: self.userID, secCode: self.secCode)
        let response = try await self.client.post(uri,
                                                  headers: [:],
                                                  content: captchaForm)
        return try MIDParses.getDocument(from: response)
    }
    
    // MARK: - Useless Document Step
    
    private func passUselessDocument(_ document: Document) async throws -> Document {
        let uselessForm = try MIDParses.uselessPageFormData(for: document)
        let response = try await self.client.post(Constants.captchaLink(userID: userID, secCode: secCode),
                                                  headers: [:],
                                                  content: uselessForm)
        return try MIDParses.getDocument(from: response)
    }
    
    // MARK: - Calendar Document Step
    
    private func checkCalendarDocument(_ document: Document) throws -> CheckResult {
        return try MIDParses.parseCalendarDocument(from: document)
    }
}
