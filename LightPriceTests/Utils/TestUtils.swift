//
//  TestUtils.swift
//  LightPriceTests
//
//  Created by Miguel Goñi on 2/2/22.
//

import Foundation

class TestsUtils {
    enum ParsingError: Error {
        case noFileFounded
    }
    
    func fetchJSON(fromFile fileName: String) -> Data {
        do {
            let bundle = Bundle(for: type(of: self))
            if let file = bundle.url(forResource: fileName, withExtension: "json") {
                let data = try Data(contentsOf: file)
                return data
            } else {
                throw ParsingError.noFileFounded
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return Data()
    }
}

struct MockedData {
    struct LightPriceReponse {
        static let lightPriceResponse = TestsUtils().fetchJSON(fromFile: "PricesResponse")
        static let emptyResponse = TestsUtils().fetchJSON(fromFile: "emptyJson")
    }
    
}
