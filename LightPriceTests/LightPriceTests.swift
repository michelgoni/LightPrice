//
//  LightPriceTests.swift
//  LightPriceTests
//
//  Created by Michel Goñi on 9/1/22.
//

import XCTest
import LightPrice_WatchKit_Extension



class RemoteLightsPriceLoaderTest: XCTestCase {

    func test_init_does_notRequestDataFromUrl() {
       
        let (_, client) = makeSut()
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_requestsºDataFromUrl() {
      
        let url = URL(string: "a-given-url.com")!
        let (sut, client) = makeSut(url: url)
        sut.load()
        XCTAssertEqual(client.requestedUrls, [url])
    }
    
    
    //MARK: -- Helper
    private func makeSut(url: URL = URL(string: "a-given-url.com")!) -> (sut: RemoteLightsPriceLoader, client: HTTPCLientSpy) {
        let client = HTTPCLientSpy()
        let sut =  RemoteLightsPriceLoader(url: url, client: client)
        return(sut, client)
        
    }
}

private class HTTPCLientSpy: HTTPClient {
    var requestedUrl: URL?
    var requestedUrls = [URL]()
    
    func get(from url: URL) {
        requestedUrl = url
        requestedUrls.append(url)
    }
}

