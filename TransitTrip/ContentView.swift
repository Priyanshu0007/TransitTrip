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
        @Bindable var bindableViewModel = viewModel
        NavigationStack {
            VStack(spacing: 0) {
                // Horizontal filter chips bar
                VehicleFilterBar(selectedType: $bindableViewModel.selectedVehicleType)
                    .background(Color(.systemGroupedBackground).opacity(0.4))
                
                Divider()
                
                if viewModel.filteredTrips.isEmpty {
                    NoResultsView(
                        searchText: viewModel.searchText,
                        selectedType: viewModel.selectedVehicleType
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            viewModel.searchText = ""
                            viewModel.selectedVehicleType = nil
                        }
                    }
                } else {
                    List(viewModel.filteredTrips) { trip in
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
                }
            }
            .navigationTitle("City Transit")
            .searchable(text: $bindableViewModel.searchText, prompt: "Search routes or destinations")
            .sensoryFeedback(.selection, trigger: viewModel.activeTripID)
        }
    }
}


struct VehicleFilterBar: View {
    @Binding var selectedType: TransitTrip.VehicleType?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // "All" Chip
                FilterChip(
                    title: "All",
                    iconName: "square.grid.2x2.fill",
                    isSelected: selectedType == nil,
                    activeColor: .blue
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedType = nil
                    }
                }
                
                ForEach(TransitTrip.VehicleType.allCases, id: \.self) { type in
                    FilterChip(
                        title: type.displayName,
                        iconName: type.iconName,
                        isSelected: selectedType == type,
                        activeColor: type.badgeColor
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedType = type
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

struct FilterChip: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    let activeColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.subheadline)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background {
                if isSelected {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [activeColor, activeColor.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: activeColor.opacity(0.3), radius: 4, x: 0, y: 2)
                } else {
                    Capsule()
                        .fill(Color(.systemGray6).opacity(0.6))
                }
            }
            .overlay {
                if !isSelected {
                    Capsule()
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                }
            }
            .foregroundColor(isSelected ? .white : .primary.opacity(0.8))
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.03 : 1.0)
    }
}

struct NoResultsView: View {
    let searchText: String
    let selectedType: TransitTrip.VehicleType?
    let resetAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: selectedType?.iconName ?? "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.6))
                .frame(width: 90, height: 90)
                .background(
                    Circle()
                        .fill(Color(.systemGray6).opacity(0.5))
                )
                .shadow(color: Color.black.opacity(0.03), radius: 4)
            
            VStack(spacing: 6) {
                Text("No Trips Found")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: resetAction) {
                Text("Reset Filters")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: .blue.opacity(0.25), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 60)
    }
    
    private var message: String {
        if !searchText.isEmpty && selectedType != nil {
            return "No \(selectedType!.displayName) trips matching \"\(searchText)\" found in the schedule."
        } else if !searchText.isEmpty {
            return "We couldn't find any trips matching \"\(searchText)\" in the schedule."
        } else if let selectedType = selectedType {
            return "There are no \(selectedType.displayName) trips scheduled at the moment."
        } else {
            return "No trips match the selected criteria."
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
