//
//  RemoteLightsPriceLoader.swift
//  LightPrice WatchKit Extension
//
//  Created by Michel Goñi on 9/1/22.
//

import Foundation

public protocol HTTPClient {
  
    func data(request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: HTTPClient {
    public func data(request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request, delegate: nil)
    }
   
}

public final class RemoteLightsPriceLoader {
    
    public enum NetworkError: Error {
        case invalidData
        case connectivity
    }
    private let client: HTTPClient
    
    public init (client: HTTPClient = URLSession.shared) {
        self.client = client
    }
    
    public func performRequest(_ request: URLRequest) async throws -> Data {
        guard let (data, response) = try? await client.data(request: request) else {
            throw NetworkError.connectivity
        }
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.invalidData
        }
        return data
    }
}


