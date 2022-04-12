import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // register routes
    var configuration = app.http.client.configuration.tlsConfiguration ?? .clientDefault
    configuration.certificateVerification = .none
    app.http.client.configuration.tlsConfiguration = configuration
    try routes(app)
}
