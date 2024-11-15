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
    
    @State private var hasActiveSession = false // Track active session state
    @State private var activeWorkoutName: String? // Store the active workout name
    @State private var activeWorkoutId: UUID? // Store the active workout ID for navigation
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showAlert = false
    @State private var deletingWorkouts: Set<UUID> = [] // for dissolve animation
    @State private var duplicatingWorkouts: Set<UUID> = [] // for dissolve animation

    @State private var presentingModal: ModalType? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                Divider()
                VStack(spacing: 0) {
                    if hasActiveSession, let workoutId = activeWorkoutId {
                        Button(action: {
                            appViewModel.navigateTo(.workoutActiveView(workoutId))
                        }) {
                            Text("\(activeWorkoutName ?? "Workout") in Progress: Tap Here To Resume")
                                .foregroundColor(.staticWhite)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .edgesIgnoringSafeArea(.horizontal)
                        }
                        Spacer()
                    }
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach($workoutManager.workouts) { workout in
                            if !deletingWorkouts.contains(workout.id) {
                                CardView(workoutId: workout.id, onDelete: {
                                    deleteWorkouts(workout.id)
                                }, 
                                onDuplicate: {
                                    duplicateWorkout(workout.id)
                                },
                                hasActiveSession: activeWorkoutId == workout.id)
                                .transition(.asymmetric(insertion: .opacity.combined(with: .scale), removal: .opacity.combined(with: .scale)))
                                .environmentObject(appViewModel)
                                .environmentObject(workoutManager)
                            }
                        }
                    }
                    .padding()
                    .animation(.easeInOut, value: workoutManager.workouts)
                }
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
            
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Active Session Detected"),
                    message: Text("You cannot delete an active workout, please end your workout first"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear(perform: loadWorkouts)
        }
        .sheet(item: $presentingModal) { modal in
            switch modal {
            case .add:
                AddWorkoutView(workoutId: UUID(), navigationTitle: "Create Workout Plan", update: false)
                    .environmentObject(workoutManager)
                    .environmentObject(appViewModel)
            case .edit(let workoutId):
                AddWorkoutView(workoutId: workoutId, navigationTitle: "Edit Workout Plan", update: true)
                    .environmentObject(workoutManager)
                    .environmentObject(appViewModel)
                
            }
        }
    }
    
    private func deleteWorkouts(_ workoutId: UUID) {
        withAnimation {
            deletingWorkouts.insert(workoutId)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation {
                    self.workoutManager.deleteWorkout(for: workoutId)
                    self.workoutManager.loadWorkoutsWithId()
                    self.deletingWorkouts.remove(workoutId)
                }
            }
        }
    }
    
    private func duplicateWorkout(_ workoutId: UUID){
        withAnimation {
            duplicatingWorkouts.insert(workoutId)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation {
                    self.workoutManager.duplicateWorkout(originalWorkoutId: workoutId)
                    self.workoutManager.loadWorkoutsWithId()
                    self.duplicatingWorkouts.remove(workoutId)
                }
            }
        }
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

