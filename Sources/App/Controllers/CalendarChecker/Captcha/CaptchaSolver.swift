//
//  File.swift
//  
//
//  Created by Сергей Лисенков on 31.03.2022.
//

import Foundation
import Vapor

/// Client for AZ Captcha. Solves gotten image.
final class CaptchaSolver {
    
    // MARK: - Constants
    
    private struct Constants {
        static let solverCreateURI = URI(string: "http://azcaptcha.com/in.php")
        static let solverCheckURI = URI(string: "http://azcaptcha.com/res.php")
        static let apiKey = "kr2ppywr4gjdv78qgzxhffhvnqmbtzxd"
    }
    
    // MARK: - Public
    
    /// Solve captcha by image URL.
    ///
    /// - Parameters:
    ///   - url: Captcha image url.
    ///   - client: HTTP client.
    /// - Returns: String with answer.
    public func solveCaptcha(url: String, client: Client) async throws -> String {
        let base64Image = try await self.getBase64Image(url: URI(string: url), client: client)
        return try await self.solve(base64Image: base64Image, client: client)
    }
    
    // MARK: - Solve
    
    private func solve(base64Image: String, client: Client) async throws -> String {
        let taskID = try await self.createTask(base64Image: base64Image, client: client)
        return try await self.checkResult(taskID: taskID, client: client)
    }
    
    /// Create task at solving service.
    /// 
    /// - Parameters:
    ///   - base64Image: Encoded image.
    ///   - client: HTTP client.
    /// - Returns: TaskID
    private func createTask(base64Image: String, client: Client) async throws -> Int {
        let content = AnyCaptchaTaskModel(key: Constants.apiKey, body: base64Image)
        let response = try await client.post(Constants.solverCreateURI, content: content)
        
        guard let bufferBytes = response.body else {
            throw Abort(.custom(code: 400, reasonPhrase: "Unknown error while creating solving task"))
        }
        let result = try JSONDecoder().decode(AnyCaptchaCreatedTaskModel.self, from: bufferBytes)
        
        guard let taskID = result.request else {
            throw Abort(.custom(code: 400, reasonPhrase: result.errorDescription ?? "Unknown error while creating solving task"))
        }
        
        return taskID
    }
    
    private func checkResult(taskID: Int, client: Client) async throws -> String {
        try await Task.sleep(nanoseconds: 1000000000)
        let content = AnyCaptchaCheckModel(key: Constants.apiKey, id: taskID)
        let response = try await client.post(Constants.solverCheckURI, content: content)
        
        guard let biteBuffer = response.body else {
            throw Abort(.custom(code: 400, reasonPhrase: "Empty response body after cpatcha check"))
        }
        let result = AnyCaptchaResultModel.fromBiteBuffer(biteBuffer)
        switch result.status {
        case .processing:
            return try await self.checkResult(taskID: taskID, client: client)
        case .error(let descript):
            throw Abort(.custom(code: 400, reasonPhrase: descript))
        case .ready(let result):
            return result
        }
    }
    
    // MARK: - Fetch
    
    private func getBase64Image(url: URI, client: Client) async throws -> String {
        let response = try await client.get(url)
        
        guard let byteBuffer = response.body else {
            throw Abort(.custom(code: 400, reasonPhrase: "Can't read captcha image buffer"))
        }
        
        let data = Data(buffer: byteBuffer)
        return data.base64EncodedString()
    }
}
