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
    
    func test_performRequest_delivers_connectivity_error() async throws {
        let (sut, _) = makeSut(result: .failure(anyError()))
        var capturedErrors = [RemoteLightsPriceLoader.NetworkError]()
        do {
            _ = try await sut.performRequest(anyRequest())
            XCTFail("Expected error: \(RemoteLightsPriceLoader.NetworkError.connectivity)")
        }catch let error {
          
            capturedErrors.append(error as! RemoteLightsPriceLoader.NetworkError)
            XCTAssertEqual(capturedErrors, [RemoteLightsPriceLoader.NetworkError.connectivity])
        }
    }
    
    func test_performRequest_delivers_BadResponseCodeErrorOnNon200HTTPResponse() async throws {
        let errorCodes =   [199, 201, 300, 400, 401, 404, 500]
        errorCodes.forEach { code in
            Task {
                var capturedErrors = [RemoteLightsPriceLoader.NetworkError]()
                let non200 = (Data(), httPresponse(code: code))
                let (sut, _) = makeSut(result: .success(non200))
                do {
                    _ = try await sut.performRequest(anyRequest())
                    XCTFail("Expected error: \(RemoteLightsPriceLoader.NetworkError.invalidData)")
                }catch {
                  
                    capturedErrors.append(error as! RemoteLightsPriceLoader.NetworkError)
                    XCTAssertEqual(capturedErrors, [.invalidData])
                }
            }
        }
    }
    
    func test_performRequest_delivers_DataOn200HTTPResponse() async throws {
        let validData = Data("some data".utf8)
        let validResponse = httPresponse(code: 200)
        let (sut, _) = makeSut(result: .success((validData, validResponse)))
        let receivedData = try await sut.performRequest(anyRequest())
        XCTAssertEqual(receivedData, validData)
    }
    
    func test_performRequest_delivers_ErrorOn200HTTPResponseWithInvalidJson() async throws {
        let invalidJsonData = Data("invalid json".utf8)
        let validResponse = httPresponse(code: 200)
        let (sut, _) = makeSut(result: .success((invalidJsonData, validResponse)))
        let receivedData = try await sut.performRequest(anyRequest())
        XCTAssertEqual(receivedData, invalidJsonData)
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

