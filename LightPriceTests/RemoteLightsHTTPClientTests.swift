//
//  RemoteLightsHTTPClientTests.swift
//  LightPriceTests
//
//  Created by Miguel Goñi on 13/3/22.
//

import XCTest

class RemoteLightsHTTPClientTests: XCTestCase {

    override  func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override  func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    private func makeSut(file: StaticString = #filePath, line: UInt = #line) {
        
    }

}

private class URLProtocolStub: URLProtocol {
    private struct Stub {
        let error: Error?
        let data: Data?
        let response: URLResponse?
    }
    
    private static var stub: Stub?
    private static var requestObserver: ((URLRequest) -> Void)?
    
    static func observeRequests(observer: @escaping(URLRequest) -> Void) {
        requestObserver = observer
    }
    
    
    static func startInterceptingRequests() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopInterceptingRequests() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        stub = nil
        requestObserver = nil
    
    
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        requestObserver?(request)
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        
        if let data = URLProtocolStub.stub?.data{
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = URLProtocolStub.stub?.response{
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = URLProtocolStub.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}
