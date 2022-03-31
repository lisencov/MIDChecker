//
//  File.swift
//  
//
//  Created by Сергей Лисенков on 31.03.2022.
//

import Foundation
import Vapor

final class CaptchaSolver {
    
    private struct Constants {
        static let solverCreateURI = URI(string: "https://api.anycaptcha.com/createTask")
        static let solverCheckURI = URI(string: "https://api.anycaptcha.com/getTaskResult")
        static let apiKey = "3f71851a2e21414db551cdbd6dd57c54"
    }
    
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
    /// - Parameters:
    ///   - base64Image: Encoded image.
    ///   - client: HTTP client.
    /// - Returns: TaskID
    private func createTask(base64Image: String, client: Client) async throws -> Int {
        let content = AnyCaptchaTaskModel(clientKey: Constants.apiKey, base64Image: base64Image)
        let response = try await client.post(Constants.solverCreateURI, content: content)
        let result = try response.content.decode(AnyCaptchaCreatedTaskModel.self)
        
        guard let taskID = result.taskId else {
            throw Abort(.custom(code: 400, reasonPhrase: result.errorDescription ?? "Unknown error while creating solving task"))
        }
        
        return taskID
    }
    
    private func checkResult(taskID: Int, client: Client) async throws -> String {
        try await Task.sleep(nanoseconds: 2000000)
        let content = AnyCaptchaCheckModel(clientKey: Constants.apiKey, taskId: taskID)
        let response = try await client.post(Constants.solverCheckURI, content: content)
        let result = try response.content.decode(AnyCaptchaResultModel.self)
        
        guard let status = result.status else {
            throw Abort(.custom(code: 400, reasonPhrase: result.errorDescription ?? "Unknown error while processing solving task"))
        }
        
        switch status {
        case .processing:
            return try await self.checkResult(taskID: taskID, client: client)
        case .ready:
            return result.solution?.text ?? ""
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
