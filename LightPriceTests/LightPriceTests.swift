//
//  LightPriceTests.swift
//  LightPriceTests
//
//  Created by Michel Goñi on 9/1/22.
//

import XCTest

protocol HTTPClient {
    func get(from url: URL)
}

class RemoteLightsPriceLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load() {
        client.get(from: URL(string: "a-give-url.com")!)
    }
}

class HTTPCLientSpy: HTTPClient {
    var requestedUrl: URL?
    
    func get(from url: URL) {
        requestedUrl = url
    }
}

class RemoteLightsPriceLoaderTest: XCTestCase {

    func test_init_does_notRequestDataFromUrl() {
        let client = HTTPCLientSpy()
        _ = RemoteLightsPriceLoader(client: client)
        XCTAssertNil(client.requestedUrl)
        
    }
}
