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
        guard let id = req.query[Int.self, at: "id"],
              let secureCode = req.query[String.self, at: "sec"] else {
            throw Abort(.custom(code: 400, reasonPhrase: "id and sec are required"))
        }
        
        return try await CalendarChecker(userID: id, secCode: secureCode, client: req.client).check()
    }
}
