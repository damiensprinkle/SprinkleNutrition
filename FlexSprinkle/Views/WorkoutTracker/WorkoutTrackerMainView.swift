//
//  WorkoutTrackerMainView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/3/24.
//

import SwiftUI
import SwiftData

struct WorkoutTrackerMainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var navigationPath = NavigationPath()
    
    @State private var hasActiveSession = false // Track active session state
    @State private var activeWorkoutName: String? // Store the active workout name
    @State private var activeWorkoutId: UUID? // Store the active workout ID for navigation
    @EnvironmentObject var appViewModel: AppViewModel
    
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if hasActiveSession, let workoutId = activeWorkoutId {
                    Button(action: {
                        appViewModel.navigateTo(.workoutActiveView(workoutId))
                    }) {
                        Text("\(activeWorkoutName ?? "Workout") in Progress: Tap Here To Resume")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .edgesIgnoringSafeArea(.horizontal)
                    }
                    Spacer()
                }
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    CardView(workoutId: UUID(), isDefault: true, hasActiveSession: false)
                        .environmentObject(appViewModel)
                    
                    ForEach($workoutManager.workouts) { workout in
                        CardView(workoutId: workout.id, isDefault: false, onDelete: {
                            workoutManager.deleteWorkout(for: workout.id)
                            workoutManager.loadWorkoutsWithId()
                        }, hasActiveSession: activeWorkoutId == workout.id)
                            .environmentObject(appViewModel)
                            .onTapGesture {
                                appViewModel.navigateTo(.workoutActiveView(workout.id))
                            }
                            .environmentObject(workoutManager)

                    }
                }
                .padding()
            }
        }
        .environmentObject(workoutManager)
        .onAppear(perform: loadWorkouts)
    }
    
    
    private func loadWorkouts() {
        if workoutManager.context == nil {
            workoutManager.context = viewContext
        }
        workoutManager.loadWorkoutsWithId()
        
        // Directly check and update active session state
        DispatchQueue.main.async {
            let activeSession = workoutManager.getSessions().first { $0.isActive }
            hasActiveSession = activeSession != nil
            activeWorkoutId = activeSession?.workoutsR?.id
            activeWorkoutName = activeSession?.workoutsR?.name
        }
    }
}

