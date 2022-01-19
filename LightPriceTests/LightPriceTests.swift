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
        let (sut, _) = makeSut(result: .failure(RemoteLightsPriceLoader.Error.connectivity))
        var capturedResults = [Result<Data, RemoteLightsPriceLoader.Error>]()
        do {
            let _ = try await sut.performRequest(anyRequest())
           
            XCTFail("Expected error: \(RemoteLightsPriceLoader.Error.connectivity)")
        }catch{
            let capturedError: Result<Data, RemoteLightsPriceLoader.Error> = .failure(error as! RemoteLightsPriceLoader.Error)
            capturedResults.append(capturedError)
            XCTAssertEqual(capturedResults, [.failure(.connectivity)])
        }
    }
    
    func test_performRequest_delivers_BadResponseCodeErrorOnNon200HTTPResponse() async throws {
        let errorCodes =   [199, 201, 300, 400, 401, 404, 500]
        errorCodes.forEach { code in
            Task {
                var capturedResults = [Result<Data, RemoteLightsPriceLoader.Error>]()
                let non200 = (Data(), httPresponse(code: code))
                let (sut, _) = makeSut(result: .success(non200))
                do {
                    let _ = try await sut.performRequest(anyRequest())
                    XCTFail("Expected error: \(RemoteLightsPriceLoader.Error.invalidData)")
                }catch {
                    let capturedError: Result<Data, RemoteLightsPriceLoader.Error> = .failure(error as! RemoteLightsPriceLoader.Error)
                    capturedResults.append(capturedError)
                    XCTAssertEqual(capturedResults, [.failure(.invalidData)])
                }
            }
        }
    }
    
    func test_performRequest_delivers_DataOn200HTTPResponse() async throws {
        let validData = Data("some data".utf8)
        let validResponse = httPresponse(code: 200)
        let (sut, _) = makeSut(result: .success((validData, validResponse)))
        var capturedResults = [Result<Data, RemoteLightsPriceLoader.Error>]()
        let receivedData = try await sut.performRequest(anyRequest())
        capturedResults.append(receivedData)
        XCTAssertEqual(capturedResults, [.success(Data("some data".utf8))])
    }
   
    func test_performRequest_delivers_ErrorOn200HTTPResponseWithInvalidJson() async throws {
        let invalidJsonData = Data("some data".utf8)
        let validResponse = httPresponse(code: 200)
        let (sut, _) = makeSut(result: .success((invalidJsonData, validResponse)))
        var capturedResults = [Result<Data, RemoteLightsPriceLoader.Error>]()
        let receivedData = try await sut.performRequest(anyRequest())
        capturedResults.append(receivedData)
        XCTAssertEqual(capturedResults, [.success(Data("some data".utf8))])
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

