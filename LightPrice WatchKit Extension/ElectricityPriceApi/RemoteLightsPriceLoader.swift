//
//  RemoteLightsPriceLoader.swift
//  LightPrice WatchKit Extension
//
//  Created by Michel Goñi on 9/1/22.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL)
}


public final class RemoteLightsPriceLoader {
    let client: HTTPClient
    let url: URL
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load() {
        client.get(from: URL(string: "a-given-url.com")!)
    }
}
