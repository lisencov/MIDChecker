//
//  File.swift
//  
//
//  Created by Сергей Лисенков on 01.04.2022.
//

import Foundation
import Vapor

/// Proxy HTTP Client that saves cookies during one parsing session.
final class MIDProxyClient: Client {
    
    // MARK: - Private
    
    private let client: Client
    private var cookie: HTTPCookies = [:]
    
    var eventLoop: EventLoop {
        return client.eventLoop
    }
    
    // MARK: - Init
    
    /// Initialize.
    ///
    /// - Parameter clien: Original client.
    init(clien: Client) {
        self.client = clien
    }
    
    // MARK: - Client
    
    func delegating(to eventLoop: EventLoop) -> Client {
        return self.client.delegating(to: eventLoop)
    }
    
    func send(_ request: ClientRequest) -> EventLoopFuture<ClientResponse> {
        var request = request
        request.headers.cookie = self.cookie
        let response = self.client.send(request)
        response.whenSuccess { [weak self] response in
            guard let self = self else { return }
            self.cookie = self.mergeCookies(old: self.cookie, new: response.headers.setCookie)
        }
        return response
    }
    
    // MARK: - Private
    
    private func mergeCookies(old: HTTPCookies, new: HTTPCookies?) -> HTTPCookies {
        guard let new = new, !new.all.isEmpty else {
            return old
        }
        
        var result = old
        result.all.merge(new.all) { oldValue, newValue in
            return newValue
        }
        return result
    }
}
