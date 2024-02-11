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
    @StateObject private var workoutManager = WorkoutManager() // Initialize without context first


    var body: some View {
        switch appViewModel.currentView {
        case .main:
            WorkoutTrackerMainView().environment(\.managedObjectContext, managedObjectContext)
                .environmentObject(workoutManager)
        case .workoutOverview(let workoutId):
            WorkoutOverviewView(workoutId: workoutId).navigationTitle("Overview")
                .environmentObject(workoutManager)
                .environmentObject(appViewModel)

        case .workoutActiveView(let workoutId):
            ActiveWorkoutView(workoutId: workoutId) 
                .environmentObject(workoutManager)
                .environmentObject(appViewModel)
        }
    }
}
