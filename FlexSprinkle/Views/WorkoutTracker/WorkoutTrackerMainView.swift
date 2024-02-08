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


    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: 0) {
                                    if hasActiveSession, let activeWorkoutName = activeWorkoutName {
                                        Button(action: {
                                            navigationPath.append(activeWorkoutName)
                                            
                                        }) 
                                        {
                                            Text("Session in Progress: '\(activeWorkoutName)'")
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color("MyBlue"))
                                                .edgesIgnoringSafeArea(.horizontal)
                                        }
                                        Spacer()
                                    }
                    
                    // Content below the banner
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                        CardView(
                            title: "Add",
                            isDefault: true,
                            navigationPath: $navigationPath
                        )
                        ForEach(workoutManager.workouts, id: \.self) { workout in
                            CardView(
                                title: workout,
                                isDefault: false,
                                onDelete: {
                                    workoutManager.deleteWorkoutDetails(for: workout)
                                },
                                navigationPath: $navigationPath
                            )
                        }
                    }
                    .padding(.horizontal) // Apply padding here to only affect grid content
                }
            }
            .navigationDestination(for: WorkoutDetail.self) { detail in
                ActiveWorkoutView(workoutName: detail.name)
                    .environmentObject(workoutManager)
            }
            .navigationDestination(for: String.self) { workoutName in
                          ActiveWorkoutView(workoutName: workoutName)
                              .environmentObject(workoutManager)
                      }
            .onAppear {
                if workoutManager.context == nil {
                    workoutManager.context = viewContext
                    workoutManager.loadWorkouts()
                }
                // Check for active sessions
                let activeSession = workoutManager.getSessions()
                hasActiveSession = !activeSession.isEmpty
                if(hasActiveSession){
                    activeWorkoutName = workoutManager.getWorkoutNameOfActiveSession()
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


