//
//  TransitActivityAttributes.swift
//  TransitTrip
//
//  Created by Priyanshu Gupta on 26/07/26.
//

import Foundation
import ActivityKit

struct TransitActivityAttributes: ActivityAttributes{
    // Dynamic data that updates live on the Lock Screen
    public struct ContentState: Codable, Hashable {
        var estimatedArrival: Date
    }

    // Fixed values assigned when the Live Activity starts
    var lineName: String
    var destination: String
    var vehicleType: String
}
