//
//  WorkoutTrackerContentView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/10/24.
//

import SwiftUI

struct WorkoutContentMainView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.managedObjectContext) var managedObjectContext
    @StateObject private var workoutManager = WorkoutManager()
    
    var body: some View {
        ZStack {
            // Decide which view to present based on the currentView state
            switch appViewModel.currentView {
            case .main:
                AnyView(WorkoutTrackerMainView()
                    .environment(\.managedObjectContext, managedObjectContext)
                    .environmentObject(workoutManager))
                .transition(.slide)
                
            case .workoutOverview(let workoutId):
                AnyView(WorkoutOverviewView(workoutId: workoutId)
                    .environmentObject(workoutManager)
                    .environmentObject(appViewModel))
                .transition(.slide)
                
            case .workoutActiveView(let workoutId):
                ActiveWorkoutView(workoutId: workoutId)
                    .id(workoutId) // Assuming workoutId is unique for each workout
                    .environmentObject(workoutManager)
                    .environmentObject(appViewModel)
                .transition(.slide)
            case .workoutHistoryView:
                AnyView(WorkoutHistoryView()
                    .environmentObject(workoutManager)
                    .environmentObject(appViewModel))
                .transition(.slide)
            }
        }
        .animation(.default, value: appViewModel.currentView)
    }
}
