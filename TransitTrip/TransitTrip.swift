//
//  TransitTrip.swift
//  TransitTrip
//
//  Created by Priyanshu Gupta on 19/07/26.
//

import Foundation

struct TransitTrip: Identifiable, Codable{
    let id: UUID
    let lineName: String
    let destination: String
    let estimatedArrival: Date
    let vehicleType: VehicleType
    
    enum VehicleType: String, Codable{
        case metro
        case bus
    }
    
    var minutesRemaining: Int{
        let difference = estimatedArrival.timeIntervalSince(Date())
        return max(0, Int(difference/60))
    }
}
