import Vapor

func routes(_ app: Application) throws {
    
    app.get { req in
        return "It works!"
    }
    
    app.get("check") { req async throws -> CheckResult in
        return try await checkPassport(request: req)
    }
    
    app.get("telegram") { req async throws -> String in
        let message: String
        do {
            let result = try await checkPassport(request: req)
            message = result.message
        } catch(let error) {
            message = error.localizedDescription
        }
        
        try await TelegramBot(client: req.client).sendResult(message: message)
        return message
    }
    
    app.get("botTest") { req async throws -> String in
        guard let message = req.query[String.self, at: "message"] else {
            throw Abort(.custom(code: 400, reasonPhrase: "message is required"))
        }
        
        try await TelegramBot(client: req.client).sendResult(message: message)
        return message
    }
}

private func checkPassport(request: Request) async throws -> CheckResult {
    return try await CalendarChecker(userID: Int(Configuration.clientID.value) ?? 0, secCode: Configuration.secureID.value, client: request.client).check()
}
