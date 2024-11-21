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
    @EnvironmentObject var workoutController: WorkoutTrackerController


    var body: some View {
        ZStack {
            // Decide which view to present based on the currentView state
            switch appViewModel.currentView {
            case .main:
                AnyView(WorkoutTrackerMainView()
                    .environment(\.managedObjectContext, managedObjectContext)
                    .environmentObject(workoutController))
                .transition(.slide)
                
            case .workoutOverview(let workoutId):
                AnyView(WorkoutOverviewView(workoutId: workoutId)
                    .environmentObject(workoutController)
                    .environmentObject(appViewModel))
                .transition(.slide)
                
            case .workoutActiveView(let workoutId):
                ActiveWorkoutView(workoutId: workoutId)
                    .id(workoutId)
                    .environmentObject(appViewModel)
                    .environmentObject(workoutController)
                .transition(.slide)
            case .workoutHistoryView:
                AnyView(WorkoutHistoryView()
                    .environmentObject(appViewModel))
                .transition(.slide)
            case .customizeCardView(let workoutId):
                AnyView(CustomizeCardView(workoutId: workoutId))
                    .environmentObject(appViewModel)
                    .environmentObject(workoutController)
                    .transition(.slide)

            }
        }
        .animation(.default, value: appViewModel.currentView)
    }
}
