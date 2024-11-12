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
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var workoutController: WorkoutTrackerController
    @State private var deletingWorkouts: Set<UUID> = [] // for dissolve animation
    @State private var duplicatingWorkouts: Set<UUID> = [] // for dissolve animation
    
    var body: some View {
        NavigationView {
            ScrollView {
                Divider()
                workoutGrid
            }
            .navigationTitle("Workout Tracker")
            .navigationBarItems(trailing: Button(action: {
                workoutController.presentAddWorkoutView()
            }) {
                Image(systemName: "plus")
                    .help("Create a new workout")
            })
            .navigationBarItems(trailing: Button(action: {
                workoutController.navigateToWorkoutHistory()
            }) {
                Image(systemName: "clock")
                    .help("View workout history")
            })
            
            .alert(isPresented: $workoutController.showAlert) {
                Alert(
                    title: Text("Active Session Detected"),
                    message: Text("You cannot delete an active workout, please end your workout first"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear(perform: workoutController.loadWorkouts)
        }
        .sheet(item: $workoutController.appViewModel.presentModal) { modal in
            switch modal {
            case .add:
                AddWorkoutView(workoutId: UUID(), navigationTitle: "Create Workout Plan", update: false)
                    .environmentObject(workoutController.workoutManager)
                    .environmentObject(workoutController.appViewModel)
            case .edit(let workoutId):
                AddWorkoutView(workoutId: workoutId, navigationTitle: "Edit Workout Plan", update: true)
                    .environmentObject(workoutController.workoutManager)
                    .environmentObject(workoutController.appViewModel)
            }
        }
    }
    
    private var workoutGrid: some View {
        VStack(spacing: 0) {
            
            if workoutController.hasActiveSession, let workoutId = workoutController.activeWorkoutId {
                Button(action: {
                    workoutController.navigateToWorkoutView(workoutId)
                }) {
                    Text("\(workoutController.activeWorkoutName ?? "Workout") in Progress: Tap Here To Resume")
                        .foregroundColor(.staticWhite)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .edgesIgnoringSafeArea(.horizontal)
                }
                Spacer()
            }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(workoutController.workouts) { workout in
                    if !deletingWorkouts.contains(workout.id) {
                        CardView(workoutId: workout.id, onDelete: {
                            deleteWorkouts(workout.id)
                        },
                        onDuplicate: {
                            duplicateWorkout(workout.id)
                        },
                        hasActiveSession: workoutController.activeWorkoutId == workout.id)
                        .transition(.asymmetric(insertion: .opacity.combined(with: .scale), removal: .opacity.combined(with: .scale)))
                        .environmentObject(workoutController.appViewModel)
                        .environmentObject(workoutController.workoutManager)
                    }
                }
            }
            .padding()
            .animation(.easeInOut, value: workoutController.workouts)
        }
    }
    
    private func deleteWorkouts(_ workoutId: UUID) {
        withAnimation {
            deletingWorkouts.insert(workoutId)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation {
                    workoutController.deleteWorkout(workoutId)
                    deletingWorkouts.remove(workoutId)
                }
            }
        }
    }
    
    private func duplicateWorkout(_ workoutId: UUID) {
        withAnimation {
            duplicatingWorkouts.insert(workoutId)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation {
                    workoutController.duplicateWorkout(workoutId)
                    duplicatingWorkouts.remove(workoutId)
                }
            }
        }
    }
}
