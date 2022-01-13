//
//  LightPriceTests.swift
//  LightPriceTests
//
//  Created by Michel Goñi on 9/1/22.
//

import XCTest
import LightPrice_WatchKit_Extension


class RemoteLightsPriceLoaderTest: XCTestCase {

    func test_init_does_notRequestData() {
       
        let (_, session) = makeSut()
        XCTAssertEqual(session.requests, [])
    }
    
    func test_perfomRequest_starts_networkRequest() async throws {
       
        let request = anyRequest()
        let (sut, session) = makeSut(result: .success(anyResponse()))
        _ = try await sut.performRequest(request)
        XCTAssertEqual(session.requests, [request])
    }
    
    func test_perfromrequest_delivers_connectivity_error() async throws {
        let (sut, _) = makeSut(result: .failure(anyError()))
        
        do {
            _ = try await sut.performRequest(anyRequest())
            XCTFail("Expected error: \(NetworkError.connectivity)")
        }catch {
            XCTAssertEqual(error as? NetworkError, NetworkError.connectivity)
        }
    }
    
    
    //MARK: -- Helper
    private func makeSut(result: Result<(Data, URLResponse), Error> = .success(anyResponse())) -> (sut: RemoteLightsPriceLoader, client: HTTPCLientSpy) {
        let client = HTTPCLientSpy(result: result)
        let sut =  RemoteLightsPriceLoader(client: client)
        return(sut, client)
        
    }
}

private struct AnyError: Error {}
private func anyError() -> Error {
    AnyError()
}
private func anyResponse() -> (Data, URLResponse){
    (Data(), httPresponse(code: 200))
}

private func anyRequest() -> URLRequest {
    URLRequest(url: URL(string: "a-given-url.com")!)
}

private func httPresponse(url: URL = URL(string: "a-given-url.com")!, code: Int) -> HTTPURLResponse {
    HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil)!
}

private class HTTPCLientSpy: HTTPClient {
    
    private (set) var requests = [URLRequest]()
    let result: Result<(Data, URLResponse), Error>
    init(result: Result<(Data, URLResponse), Error>) {
        self.result = result
    }
    func data(request: URLRequest) async throws -> (Data, URLResponse) {
        self.requests.append(request)
        return try result.get()
        
    }
}

