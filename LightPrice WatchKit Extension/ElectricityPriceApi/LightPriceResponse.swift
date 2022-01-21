//
//  LightPriceResponse.swift
//  LightPrice WatchKit Extension
//
//  Created by Miguel Goñi on 20/1/22.
//

import Foundation

public struct LightPriceResponse: Codable, Equatable {
    public static func == (lhs: LightPriceResponse, rhs: LightPriceResponse) -> Bool {
        return lhs.indicator.name == rhs.indicator.name
    }
    
    let indicator: Indicator
}

// MARK: - Indicator
public struct Indicator: Codable {
    let name: String
    let valuesUpdatedAt: String
    let values: [Value]

    enum CodingKeys: String, CodingKey {
        case name
        case valuesUpdatedAt = "values_updated_at"
        case values
    }
}


// MARK: - Value
public struct Value: Codable, Equatable {
    let value: Double
    let datetime: String
    let geoID: Int
    let geoName: String

    enum CodingKeys: String, CodingKey {
        case value, datetime
        case geoID = "geo_id"
        case geoName = "geo_name"
    }
}
