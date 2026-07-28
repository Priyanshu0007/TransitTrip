//
//  TransitWidgetLiveActivity.swift
//  TransitWidget
//
//  Created by Priyanshu Gupta on 26/07/26.
//

import WidgetKit
import SwiftUI
import ActivityKit

extension TransitActivityAttributes {
    var vehicleIconName: String {
        switch vehicleType.lowercased() {
        case "metro": return "tram.fill"
        case "bus": return "bus.fill"
        case "train": return "train.side.front.car"
        case "ferry": return "ferry.fill"
        case "cablecar", "cable_car": return "cablecar"
        default: return "tram.fill"
        }
    }
    
    var vehicleColor: Color {
        switch vehicleType.lowercased() {
        case "metro": return .blue
        case "bus": return .orange
        case "train": return .indigo
        case "ferry": return .teal
        case "cablecar", "cable_car": return .pink
        default: return .blue
        }
    }
}

struct TransitWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TransitActivityAttributes.self) { context in
            // Lock Screen & Notification Center Banner UI
            HStack(spacing: 12) {
                Image(systemName: context.attributes.vehicleIconName)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(context.attributes.vehicleColor)
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.attributes.lineName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("To \(context.attributes.destination)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(context.state.estimatedArrival, style: .timer)
                        .font(.title2)
                        .fontWeight(.black)
                        .monospacedDigit()
                        .foregroundColor(context.attributes.vehicleColor)
                    Text("ARRIVING")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .activityBackgroundTint(Color(.systemBackground))
            .activitySystemActionForegroundColor(Color.black)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Fixed: Clear leading alignment with specific color coding
                DynamicIslandExpandedRegion(.leading) {
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: context.attributes.vehicleIconName)
                            .font(.title2)
                            .foregroundColor(context.attributes.vehicleColor)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.attributes.lineName)
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.leading, 8)
                }
                
                // Fixed: The dynamic time countdown is aligned right
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.estimatedArrival, style: .timer)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .monospacedDigit()
                        .foregroundColor(context.attributes.vehicleColor)
                        .padding(.trailing, 8)
                }
                
                // Fixed: Corrected text color (white) and alignment
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text("Bound for \(context.attributes.destination)")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("Live Updates")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 12)
                }
                
            } compactLeading: {
                Image(systemName: context.attributes.vehicleIconName)
                    .foregroundColor(context.attributes.vehicleColor)
            } compactTrailing: {
                Text(context.state.estimatedArrival, style: .timer)
                    .monospacedDigit()
                    .frame(width: 40)
                    .font(.caption2)
            } minimal: {
                Image(systemName: context.attributes.vehicleIconName)
                    .foregroundColor(context.attributes.vehicleColor)
            }
        }
    }
}


#Preview("Live Activity Preview", as: .dynamicIsland(.expanded), using: TransitActivityAttributes(
    lineName: "Yellow Line Metro",
    destination: "Samaypur Badli",
    vehicleType: "metro"
)) {
   TransitWidgetLiveActivity()
} contentStates: {
    TransitActivityAttributes.ContentState(
        estimatedArrival: Date().addingTimeInterval(300) // 5 mins from now
    )
}
