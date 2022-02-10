//
//  RemoteLightPriceAPIEndToEndTests.swift
//  LightPriceTests
//
//  Created by Miguel Goñi on 10/2/22.
//

import XCTest
import LightPrice_WatchKit_Extension

class RemoteLightPriceAPIEndToEndTests: XCTestCase {
    
    func test_EndToEndServerGET_Feed_Result_matches_FixedTestAccountData() async throws {
    
        switch await getLightPriceItems() {
        case .success(let lightPriceElemnts):
            XCTAssertTrue(lightPriceElemnts?.count == 48)
        default: break
        }
    }


    private func getLightPriceItems() async -> RemoteLightsPriceLoader.LightPriceResult? {
        
        let client = URLSession(configuration: URLSessionConfiguration.ephemeral)
        
        let url = URLRequest(url: URL(string: "https://gist.githubusercontent.com/michelgoni/92c59189add94b93ccb43d817942cc37/raw/4707575e3f4f6d8cd8f87f99c00d2bd51ca03197/LightPrice.json")!)
       let loader = RemoteLightsPriceLoader(client: client)
        
        let data = try? await loader.performRequest(url)
        return data
        
    }

}
