//
//  TransitViewModel.swift
//  TransitTrip
//
//  Created by Priyanshu Gupta on 26/07/26.
//

import Foundation
import ActivityKit


@MainActor
@Observable
class TransitViewModel {
    var upcomingTrips: [TransitTrip] = []
    
    // 1. Declare the stored property so SwiftUI detects updates every second
    var now: Date = Date()
    
    var activeTripID: UUID?
    
    @ObservationIgnored nonisolated(unsafe) private var timer: Timer?
    
    private func loadMockData() {
        let current = Date()
        upcomingTrips = [
            TransitTrip(
                id: UUID(),
                lineName: "Yellow Line Metro",
                destination: "Samaypur Badli",
                estimatedArrival: current.addingTimeInterval(180), // 3 mins from now
                vehicleType: .metro
            ),
            TransitTrip(
                id: UUID(),
                lineName: "Route 544 Bus",
                destination: "R.K. Puram",
                estimatedArrival: current.addingTimeInterval(420), // 7 mins from now
                vehicleType: .bus
            ),
            TransitTrip(
                id: UUID(),
                lineName: "Rapid Metro",
                destination: "Cyber City",
                estimatedArrival: current.addingTimeInterval(900), // 15 mins from now
                vehicleType: .metro
            )
        ]
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.now = Date()
                
                if let activeTripID = self.activeTripID,
                   let activeTrip = self.upcomingTrips.first(where: { $0.id == activeTripID }) {
                    if activeTrip.estimatedArrival <= self.now {
                        self.endLiveActivity()
                    }
                }
            }
        }
    }
    
    func startLiveActivity(for trip: TransitTrip) {
        // End any currently running activity first
        endLiveActivity()
        
        // Check if Live Activities are supported/enabled on the device
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled.")
            return
        }
        
        let attributes = TransitActivityAttributes(
            lineName: trip.lineName,
            destination: trip.destination,
            vehicleType: trip.vehicleType.rawValue
        )
        
        let initialContentState = TransitActivityAttributes.ContentState(
            estimatedArrival: trip.estimatedArrival
        )
        
        do {
            let activity = try Activity<TransitActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: initialContentState, staleDate: nil)
            )
            activeTripID = trip.id
            print("Started Live Activity with ID: \(activity.id)")
        } catch {
            print("Error starting Live Activity: \(error.localizedDescription)")
        }
    }
    
    func updateLiveActivity(activityID: String, newArrivalTime: Date) {
        Task {
            let updatedState = TransitActivityAttributes.ContentState(
                estimatedArrival: newArrivalTime
            )
                
            for activity in Activity<TransitActivityAttributes>.activities {
                if activity.id == activityID {
                    await activity.update(
                        ActivityContent<TransitActivityAttributes.ContentState>(
                            state: updatedState,
                            staleDate: nil
                        )
                    )
                    print("Updated Activity: \(activityID)")
                }
            }
        }
    }
    
    func endLiveActivity() {
        activeTripID = nil
        Task {
            for activity in Activity<TransitActivityAttributes>.activities {
                // Create a final state content update for dismissal
                let finalContent = ActivityContent<TransitActivityAttributes.ContentState>(
                    state: activity.content.state,
                    staleDate: nil
                )
                            
                // Use the updated API: end(content:dismissalPolicy:)
                await activity.end(finalContent, dismissalPolicy: .immediate)
                print("Ended Activity: \(activity.id)")
            }
        }
    }

    
    init() {
        loadMockData()
        startTimer()
    }

    
    deinit {
        timer?.invalidate()
    }
}
