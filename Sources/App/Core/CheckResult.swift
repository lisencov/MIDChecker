//
//  File.swift
//  
//
//  Created by Сергей Лисенков on 01.04.2022.
//

import Foundation
import Vapor

/// Result of checking booking availability.
struct CheckResult: Encodable {
    
    enum Status: String, Encodable {
        case available
        case notAvailable
    }
    
    let status: Status
}


extension CheckResult: AsyncResponseEncodable {
    
    func encodeResponse(for request: Request) async throws -> Response {
        let data = try JSONEncoder().encode(self)
        let response = Response(headers: self.headers, body: .init(data: data))
        return response
    }
    
    private var headers: HTTPHeaders {
        return ["content-type": "application/json; charset=utf-8"]
    }
}
