//
//  RemoteLightsPriceLoader.swift
//  LightPrice WatchKit Extension
//
//  Created by Michel Goñi on 9/1/22.
//

import Foundation

public protocol HTTPClient {
  
    func data(request: URLRequest) async throws -> (Data?, URLResponse)
}

extension URLSession: HTTPClient {
    public func data(request: URLRequest) async throws -> (Data?, URLResponse) {
        try await data(for: request, delegate: nil)
    }
   
}

public final class RemoteLightsPriceLoader {
    
    public enum Error: Swift.Error, Equatable {
        case invalidData
        case connectivity
    }
    private let client: HTTPClient
    
    public init (client: HTTPClient) {
        self.client = client
    }
    
    
    public func performRequest(_ request: URLRequest) async throws -> Result<[LightPriceElement]?, Error> {
        guard let (data, response) = try? await client.data(request: request) else {
            throw Error.connectivity
        }
        
        guard let response = response as? HTTPURLResponse,
              response.statusCode == 200,
                let data = data else {
                  throw Error.invalidData
              }
        do {
            let values = try FeedItemsMapper.map(data, from: response)
            return .success(values?.toModels())
        }catch {
            throw Error.invalidData
        }
    }
}
