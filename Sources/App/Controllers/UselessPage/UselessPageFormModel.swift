//
//  File.swift
//  
//
//  Created by Сергей Лисенков on 01.04.2022.
//

import Foundation
import Vapor

struct UselessPageFormModel: Content {
        
    let viewState: String
    let viewStateGenerator: String
    let eventValidation: String
    let buttonX: Int
    let buttonY: Int
    let feedbackClientID: Int
    let feedbackOrderID: Int

    init(viewState: String, viewStateGenerator: String, eventValidation: String) {
        self.viewState = viewState
        self.viewStateGenerator = viewStateGenerator
        self.eventValidation = eventValidation
        self.buttonX = 155
        self.buttonY = 28
        self.feedbackOrderID = 0
        self.feedbackClientID = 0
    }
    
    enum CodingKeys: String, CodingKey {
        case buttonX = "ctl00$MainContent$ButtonB.x"
        case buttonY = "ctl00$MainContent$ButtonB.y"
        case viewState = "__VIEWSTATE"
        case viewStateGenerator = "__VIEWSTATEGENERATOR"
        case eventValidation = "__EVENTVALIDATION"
        case feedbackClientID = "ctl00$MainContent$FeedbackClientID"
        case feedbackOrderID = "ctl00$MainContent$FeedbackOrderID"
    }
    
    static var defaultContentType: HTTPMediaType {
        return .urlEncodedForm
    }
}
