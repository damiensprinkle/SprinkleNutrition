//
//  WorkoutTrackerMainView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/3/24.
//

import SwiftUI
import SwiftData

struct WorkoutTrackerMainView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var workoutController: WorkoutTrackerController
    @State private var deletingWorkouts: Set<UUID> = [] // for dissolve animation
    @State private var duplicatingWorkouts: Set<UUID> = [] // for dissolve animation
    @State private var presentingModal: ModalType? = nil
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                Divider()
                workoutGrid
            }
            .navigationTitle("Workout Tracker")
            .navigationBarItems(trailing: Button(action: {
                presentingModal = .add
            }) {
                Image(systemName: "plus")
                    .help("Create a new workout")
            })
            .navigationBarItems(trailing: Button(action: {
                appViewModel.navigateTo(.workoutHistoryView)
            }) {
                Image(systemName: "clock")
                    .help("View workout history")
            })
            
            .onAppear(perform: workoutController.loadWorkouts)
        }
        .sheet(item: $presentingModal) { modal in
            switch modal {
            case .add:
                AddWorkoutView(workoutId: UUID(), navigationTitle: "Create Workout Plan", update: false)
                    .environmentObject(appViewModel)
                    .environmentObject(workoutController)
            case .edit(let workoutId):
                AddWorkoutView(workoutId: workoutId, navigationTitle: "Edit Workout Plan", update: true)
                    .environmentObject(appViewModel)
                    .environmentObject(workoutController)
            }
        }
    }
    
    private var workoutGrid: some View {
        VStack(spacing: 0) {
            if workoutController.hasActiveSession, let workoutId = workoutController.activeWorkoutId {
                Button(action: {
                    appViewModel.navigateTo(.workoutActiveView(workoutId))
                }) {
                    Text("\(workoutController.activeWorkoutName ?? "Workout") in Progress: Tap Here To Resume")
                        .foregroundColor(.staticWhite)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.myBlue)
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
                        })
                        .transition(.asymmetric(insertion: .opacity.combined(with: .scale), removal: .opacity.combined(with: .scale)))
                        .environmentObject(appViewModel)
                        .environmentObject(workoutController)
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
