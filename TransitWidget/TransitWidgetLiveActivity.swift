//
//  TransitWidgetLiveActivity.swift
//  TransitWidget
//
//  Created by Priyanshu Gupta on 26/07/26.
//

import WidgetKit
import SwiftUI
import ActivityKit

struct TransitWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TransitActivityAttributes.self) { context in
            // Lock Screen & Notification Center Banner UI
            HStack {
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
                        .foregroundColor(.blue)
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
                        Image(systemName: context.attributes.vehicleType == "metro" ? "tram.fill" : "bus.fill")
                            .font(.title2)
                            .foregroundColor(context.attributes.vehicleType == "metro" ? Color.blue : Color.orange)
                        
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
                        .foregroundColor(.blue)
                        .padding(.trailing, 8)
                }
                
                // Fixed: Corrected text color (white) and alignment
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        // The text "Bound for..." is now white (.primary), not dark grey
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
                Image(systemName: "tram.fill")
                    .foregroundColor(.blue)
            } compactTrailing: {
                Text(context.state.estimatedArrival, style: .timer)
                    .monospacedDigit()
                    .frame(width: 40)
                    .font(.caption2)
            } minimal: {
                Image(systemName: "tram.fill")
                    .foregroundColor(.blue)
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
