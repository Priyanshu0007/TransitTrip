//
//  ContentView.swift
//  TransitTrip
//
//  Created by Priyanshu Gupta on 19/07/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var viewModel = TransitViewModel()
    
    var body: some View {
        NavigationStack {
            List(viewModel.upcomingTrips) { trip in
                let isTracking = viewModel.activeTripID == trip.id
                TransitRowView(trip: trip, now: viewModel.now, isTracking: isTracking)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            if isTracking {
                                viewModel.endLiveActivity()
                            } else {
                                viewModel.startLiveActivity(for: trip)
                            }
                        } label: {
                            Label(
                                isTracking ? "Stop" : "Track Live",
                                systemImage: isTracking ? "xmark.circle" : "timer"
                            )
                        }
                        .tint(isTracking ? .red : .blue)
                    }
            }
            .listStyle(.plain)
            .navigationTitle("City Transit")
            .sensoryFeedback(.selection, trigger: viewModel.activeTripID)
        }
    }
}


struct TransitRowView: View {
    let trip: TransitTrip
    let now: Date
    var isTracking: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            
            // Icon Indicator
            Image(systemName: trip.vehicleType.iconName)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(trip.vehicleType.badgeColor)
                .cornerRadius(12)
                .shadow(color: trip.vehicleType.badgeColor.opacity(0.3), radius: 4, x: 0, y: 2)
            
            // Route Details
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(trip.lineName)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    if isTracking {
                        Text("LIVE")
                            .font(.caption2.weight(.heavy))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.15))
                            .foregroundColor(.red)
                            .clipShape(Capsule())
                    }
                }
                
                Text("To \(trip.destination)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Time Badge
            VStack(alignment: .trailing) {
                Text("\(trip.minutesRemaining(relativeTo: now))")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(.primary)
                Text("mins")
                    .font(.caption)
                    .textCase(.uppercase)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(hue: 0.58, saturation: 0.7, brightness: 0.95, opacity: isTracking ? 0.8 : 0.45),
                            Color(hue: 0.75, saturation: 0.6, brightness: 0.9, opacity: isTracking ? 0.6 : 0.2),
                            Color(hue: 0.92, saturation: 0.7, brightness: 0.95, opacity: isTracking ? 0.75 : 0.35)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: isTracking ? 2 : 1.25
                )
        )
        .shadow(color: isTracking ? Color.blue.opacity(0.25) : Color.black.opacity(0.06), radius: isTracking ? 12 : 8, x: 0, y: 4)
    }
}

#Preview {
    ContentView()
}
