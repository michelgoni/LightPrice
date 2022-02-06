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
        
       
        let (sut, session) = makeSut(result: .success(anyResponse1()))
        Task {
            _ = try await sut.performRequest(request)
            XCTAssertEqual(session.requests, [request])
        }
     
    }
    
    func test_performRequest_delivers_connectivity_error() async throws {
        let (sut, _) = makeSut(result: .failure(RemoteLightsPriceLoader.Error.connectivity))
        var capturedResults = [Result<Indicator, RemoteLightsPriceLoader.Error>]()
        do {
            let _ = try await sut.performRequest(anyRequest())
           
            XCTFail("Expected error: \(RemoteLightsPriceLoader.Error.connectivity)")
        }catch{
            let capturedError: Result<Indicator, RemoteLightsPriceLoader.Error> = .failure(error as! RemoteLightsPriceLoader.Error)
            capturedResults.append(capturedError)
            XCTAssertEqual(capturedResults, [.failure(.connectivity)])
        }
    }
    
    func test_performRequest_delivers_BadResponseCodeErrorOnNon200HTTPResponse() async throws {
        let errorCodes =   [199, 201, 300, 400, 401, 404, 500]
        errorCodes.forEach { code in
            Task {
                var capturedResults = [Result<Indicator, RemoteLightsPriceLoader.Error>]()
                let non200 = (Data(), httPresponse(code: code))
                let (sut, _) = makeSut(result: .success(non200))
                do {
                    let _ = try await sut.performRequest(anyRequest())
                    XCTFail("Expected error: \(RemoteLightsPriceLoader.Error.invalidData)")
                }catch {
                    let capturedError: Result<Indicator, RemoteLightsPriceLoader.Error> = .failure(error as! RemoteLightsPriceLoader.Error)
                    capturedResults.append(capturedError)
                    XCTAssertEqual(capturedResults, [.failure(.invalidData)])
                }
            }
        }
    }
    
    func test_load_deliversErrorOn200HttpResponseWithInvalidJSON() async throws  {
        
        let invalidJson = Data("invalid json".utf8)
        let validResponse = httPresponse(code: 200)
        
        Task {
            var capturedResults = [Result<LightPriceResponse, RemoteLightsPriceLoader.Error>]()
            
            let (sut, _) = makeSut(result: .success((invalidJson, validResponse)))
            do {
                let _ = try await sut.performRequest(anyRequest())
                XCTFail("Expected error: \(RemoteLightsPriceLoader.Error.invalidData)")
            }catch {
                let capturedError: Result<LightPriceResponse, RemoteLightsPriceLoader.Error> = .failure(error as! RemoteLightsPriceLoader.Error)
                capturedResults.append(capturedError)
                XCTAssertEqual(capturedResults, [.failure(.invalidData)])
            }
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPReponseWithEmptyJSONList() async throws {
       
        let validResponse = httPresponse(code: 200)
        let (sut, _) = makeSut(result: .success((validEmptyData().0, validResponse)))
        
        Task {
            var capturedResults = [Result<[LightPriceElement]?, RemoteLightsPriceLoader.Error>]()
            do {
                let receivedData = try await sut.performRequest(anyRequest())
                capturedResults.append(receivedData)
                
               
                XCTAssertEqual(capturedResults, [.success(validEmptyData().1.indicator?.values?.map{$0.lightpriceElement})])
            }catch {
                XCTFail("Expected success with and empty item: \(validEmptyData().1.indicator)")
            }
        }
    }

    
    func test_performRequest_delivers_DataOn200HTTPResponse() async throws {
       
        let validResponse = httPresponse(code: 200)
        let (sut, _) = makeSut(result: .success((validData().0, validResponse)))
        
        Task {
            var capturedResults = [Result<[LightPriceElement]?, RemoteLightsPriceLoader.Error>]()
            do {
                let receivedData = try await sut.performRequest(anyRequest())
                capturedResults.append(receivedData)
                XCTAssertEqual(capturedResults, [.success(validEmptyData().1.indicator?.values?.map{$0.lightpriceElement})])
            }catch {
                XCTFail("Expected success with some data: \(validData().1.indicator)")
            }
        }
    }
    
    //MARK: -- Helper
    private func makeSut(result: Result<(Data?, URLResponse), Error> = .success(anyResponse())) -> (sut: RemoteLightsPriceLoader, client: HTTPCLientSpy) {
        let client = HTTPCLientSpy(result: result)
        let sut =  RemoteLightsPriceLoader(client: client)
        return(sut, client)
        
    }
    
    private func validData() -> (Data, LightPriceResponse) {
        let lihtPriceReponse = try! JSONDecoder().decode(LightPriceResponse.self,
                                                   from: MockedData.LightPriceReponse.lightPriceResponse)
        let validData = try! JSONEncoder().encode(lihtPriceReponse)
        return (validData, lihtPriceReponse)
    }
    
    private func validEmptyData() -> (Data, LightPriceResponse) {
        let lihtPriceReponse = try! JSONDecoder().decode(LightPriceResponse.self,
                                                   from: MockedData.LightPriceReponse.emptyResponse)
        let validData = try! JSONEncoder().encode(lihtPriceReponse)
        return (validData, lihtPriceReponse)
    }
    
}

private struct AnyError: Error {}
private func anyError() -> Error {
    AnyError()
}
private func anyResponse() -> (Data, URLResponse){
    (Data(), httPresponse(code: 200))
}

private func anyResponse1() -> (Data, URLResponse){
    let lihtPriceReponse = try! JSONDecoder().decode(LightPriceResponse.self,
                                               from: MockedData.LightPriceReponse.lightPriceResponse)
    let validData = try! JSONEncoder().encode(lihtPriceReponse)
   return (validData, httPresponse(code: 200))
}

private func anyRequest() -> URLRequest {
    URLRequest(url: URL(string: "a-given-url.com")!)
}

private func httPresponse(url: URL = URL(string: "a-given-url.com")!, code: Int) -> HTTPURLResponse {
    HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil)!
}

private class HTTPCLientSpy: HTTPClient {
    
    private (set) var requests = [URLRequest]()
    let result: Result<(Data?, URLResponse), Error>
    init(result: Result<(Data?, URLResponse), Error>) {
        self.result = result
    }
    func data(request: URLRequest) async throws -> (Data?, URLResponse) {
        self.requests.append(request)
        return try result.get()
        
    }
}

