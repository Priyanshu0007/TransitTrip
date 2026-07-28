//
//  TransitTrip.swift
//  TransitTrip
//
//  Created by Priyanshu Gupta on 19/07/26.
//

import Foundation
import SwiftUI

struct TransitTrip: Identifiable, Codable {
    let id: UUID
    let lineName: String
    let destination: String
    let estimatedArrival: Date
    let vehicleType: VehicleType
    
    enum VehicleType: String, Codable, CaseIterable {
        case metro
        case bus
        case train
        case ferry
        case cableCar
        
        var iconName: String {
            switch self {
            case .metro: return "tram.fill"
            case .bus: return "bus.fill"
            case .train: return "train.side.front.car"
            case .ferry: return "ferry.fill"
            case .cableCar: return "cablecar"
            }
        }
        
        var badgeColor: Color {
            switch self {
            case .metro: return .blue
            case .bus: return .orange
            case .train: return .indigo
            case .ferry: return .teal
            case .cableCar: return .pink
            }
        }
        
        var displayName: String {
            switch self {
            case .metro: return "Metro"
            case .bus: return "Bus"
            case .train: return "Train"
            case .ferry: return "Ferry"
            case .cableCar: return "Cable Car"
            }
        }
    }
    
    func minutesRemaining(relativeTo date: Date = Date()) -> Int {
        let difference = estimatedArrival.timeIntervalSince(date)
        return max(0, Int(difference / 60))
    }
}

