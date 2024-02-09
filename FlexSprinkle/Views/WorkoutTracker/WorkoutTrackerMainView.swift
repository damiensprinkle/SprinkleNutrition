//
//  WorkoutTrackerMainView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/3/24.
//

import SwiftUI
import SwiftData

struct WorkoutTrackerMainView: View {
    @State private var selectedDate = Date()
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var workoutManager = WorkoutManager() // Initialize without context first
    @State private var navigationPath = NavigationPath()
    
    @State private var hasActiveSession = false // Track active session state
    @State private var activeWorkoutName: String? // Store the active workout name
    @State private var activeWorkoutId: UUID? // Store the active workout ID for navigation

    @State private var workouts: [WorkoutInfo] = [] // WorkoutInfo is a hypothetical struct holding both name and ID


    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: 0) {
                    if hasActiveSession, let activeWorkoutId = activeWorkoutId {
                                            Button(action: {
                                                navigationPath.append(activeWorkoutId)
                                            }) {
                                                Text("Workout in Progress: Tap Here To Resume")
                                                    .foregroundColor(.white)
                                                    .frame(maxWidth: .infinity)
                                                    .padding()
                                                    .background(Color.blue)
                                                    .edgesIgnoringSafeArea(.horizontal)
                                            }
                                            Spacer()
                                        }
                    
                    // Content below the banner
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                        CardView(
                            title: "Add",
                            workoutId: UUID(), //throw away id
                            isDefault: true,
                            navigationPath: $navigationPath
                        )
                        ForEach(workoutManager.workouts) { workout in
                            CardView(
                                title: workout.name,
                                workoutId: workout.id,
                                isDefault: false,
                                onDelete: {
                                    workoutManager.deleteWorkout(for: workout.id)
                                    workoutManager.loadWorkoutsWithId()
                                },
                                navigationPath: $navigationPath
                            )
                        }
                    }
                    .padding(.horizontal) // Apply padding here to only affect grid content
                }
            }
            .navigationDestination(for: UUID.self) { workoutId in
                            // Ensure ActiveWorkoutView accepts a workoutId in its initializer
                            ActiveWorkoutView(workoutId: workoutId)
                                .environmentObject(workoutManager)
                        }
            .onAppear {
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
        .environmentObject(workoutManager)
    }
}




struct WorkoutTrackerMainView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
        WorkoutTrackerMainView()
    }
}


struct WorkoutInfo: Identifiable {
    var id: UUID // Assuming each workout has a unique UUID
    var name: String
}
