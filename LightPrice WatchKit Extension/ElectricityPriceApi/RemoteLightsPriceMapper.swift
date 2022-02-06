//
//  RemoteLightsPriceMapper.swift
//  LightPrice WatchKit Extension
//
//  Created by Miguel Goñi on 6/2/22.
//

import Foundation

struct Root: Codable {
   let indicator: Indicator?
}

internal final class FeedItemsMapper {
   
 
    private static var OK_200: Int { 200}

    
    internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [Value]? {
        guard response.statusCode == OK_200,
            let root = try? JSONDecoder().decode(Root.self, from: data) else {
                throw RemoteLightsPriceLoader.Error.invalidData
        }

        return root.indicator?.values
    }
}

 extension Array where Element == Value {
    
    func toModels() -> [LightPriceElement] {
        return map{LightPriceElement(value: $0.value, datetime: $0.datetime, geoID: $0.geoID, geoName: $0.geoName)}
    }
}

