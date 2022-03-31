//
//  File.swift
//  
//
//  Created by Сергей Лисенков on 31.03.2022.
//

import Foundation
import Vapor

/// Server-side captcha model for posting a form.
struct CaptchaFormModel: Codable {
    
    let userID: String
    let secureCode: String
    let captcha: String
    let eventARGET: String?
    let eventARGUMENT: String?
    let viewState: String
    let viewStateGenerator: String
    let eventValidation: String
    let buttonText: String
    let clientID: Int = 0
    let orderID: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case userID = "ctl00$MainContent$txtID"
        case secureCode = "ctl00$MainContent$txtUniqueID"
        case captcha = "ctl00$MainContent$txtCode"
        case eventARGET = "__EVENTTARGET"
        case eventARGUMENT = "__EVENTARGUMENT"
        case viewState = "__VIEWSTATE"
        case viewStateGenerator = "__VIEWSTATEGENERATOR"
        case eventValidation = "__EVENTVALIDATION"
        case buttonText = "ctl00$MainContent$ButtonA"
        case clientID = "ctl00$MainContent$FeedbackClientID"
        case orderID = "ctl00$MainContent$FeedbackOrderID"
    }
}

extension CaptchaFormModel: Content {
    
    static var defaultContentType: HTTPMediaType {
        return .urlEncodedForm
    }
    
}
