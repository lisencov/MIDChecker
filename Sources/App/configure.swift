import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // register routes
    app.http.client.configuration.proxy = .server(host: "192.168.0.103", port: 8888)
    try routes(app)
}
