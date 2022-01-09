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
    let url: URL
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load() {
        client.get(from: URL(string: "a-given-url.com")!)
    }
}

private class HTTPCLientSpy: HTTPClient {
    var requestedUrl: URL?
    
    func get(from url: URL) {
        requestedUrl = url
    }
}

class RemoteLightsPriceLoaderTest: XCTestCase {

    func test_init_does_notRequestDataFromUrl() {
       
        let (_, client) = makeSut()
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_requestDataFromurl() {
      
        let url = URL(string: "a-given-url.com")!
        let (sut, client) = makeSut(url: url)
        sut.load()
        XCTAssertEqual(client.requestedUrl, url)
    }
    
    
    //MARK: -- Helper
    private func makeSut(url: URL = URL(string: "a-given-url.com")!) -> (sut: RemoteLightsPriceLoader, client: HTTPCLientSpy) {
        let client = HTTPCLientSpy()
        let sut =  RemoteLightsPriceLoader(url: url, client: client)
        return(sut, client)
        
    }
 
}
