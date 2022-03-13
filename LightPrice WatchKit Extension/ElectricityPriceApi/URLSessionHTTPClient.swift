//
//  URLSessionHTTPClient.swift
//  LightPrice WatchKit Extension
//
//  Created by Miguel Goñi on 13/3/22.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    public func data(request: URLRequest) async throws -> (Data?, URLResponse) {
        try await session.data(for: request, delegate: nil)
    }
    

}
