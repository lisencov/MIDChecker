import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    app.get("goodbyy") { req -> String in
        return "Goodby"
    }
    
    app.get("check") { req async throws -> CheckResult in
        return try await checkPassport(request: req)
    }
    
    app.get("telegram") { req async throws -> String in
        let params = try requestParams(request: req)
        let message: String
        do {
            let result = try await checkPassport(request: req)
            message = result.message(clienID: "\(params.clientID)", secCode: params.secCode)
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
    let params = try requestParams(request: request)
    return try await CalendarChecker(userID: params.clientID, secCode: params.secCode, client: request.client).check()
}

private func requestParams(request: Request) throws -> (clientID: Int, secCode: String) {
    guard let id = request.query[Int.self, at: "id"],
          let secureCode = request.query[String.self, at: "sec"] else {
        throw Abort(.custom(code: 400, reasonPhrase: "id and sec are required"))
    }
    return (id, secureCode)
}
