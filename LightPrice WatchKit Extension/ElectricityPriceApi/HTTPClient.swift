//
//  HTTPClient.swift
//  LightPrice WatchKit Extension
//
//  Created by Miguel Goñi on 13/3/22.
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


