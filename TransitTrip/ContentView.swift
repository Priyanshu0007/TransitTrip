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
                TransitRowView(trip: trip, now: viewModel.now)
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
        }
    }
}


struct TransitRowView: View {
    let trip: TransitTrip
    let now: Date
    
    var body: some View {
        HStack(spacing: 16) {
            
            // Icon Indicator
            Image(systemName: trip.vehicleType == .metro ? "tram.fill" : "bus.fill")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(trip.vehicleType == .metro ? Color.blue : Color.orange)
                .cornerRadius(12)
            
            // Route Details
            VStack(alignment: .leading, spacing: 4) {
                Text(trip.lineName)
                    .font(.headline)
                    .fontWeight(.bold)
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
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ContentView()
}
