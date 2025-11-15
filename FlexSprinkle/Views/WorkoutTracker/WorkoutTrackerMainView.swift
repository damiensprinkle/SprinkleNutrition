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
    @State private var deletingWorkouts: Set<UUID> = []
    @State private var duplicatingWorkouts: Set<UUID> = []
    @State private var presentingModal: ModalType? = nil
    @State private var showDocumentPicker = false
    @State private var importedWorkout: ShareableWorkout?
    @State private var showImportPreview = false
    @State private var isLoadingImport = false
    
    
    var body: some View {
        ScrollView {
            Divider()
            workoutGrid
        }
        .navigationBarItems(trailing: HStack(spacing: 20) {
            Button(action: {
                // Clear any previous import data
                importedWorkout = nil
                showImportPreview = false
                isLoadingImport = false
                showDocumentPicker = true
            }) {
                Image(systemName: "square.and.arrow.down")
                    .help("Import workout")
            }
            Button(action: {
                appViewModel.navigateTo(.workoutHistoryView)
            }) {
                Image(systemName: "clock")
                    .help("View workout history")
            }
            Button(action: {
                presentingModal = .add
            }) {
                Image(systemName: "plus")
                    .help("Create a new workout")
            }
        })
        .onAppear(perform: workoutController.loadWorkouts)
        .background(Color.myWhite.ignoresSafeArea())
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
        .sheet(isPresented: $showDocumentPicker, onDismiss: {
            // When document picker dismisses, wait longer to ensure file is fully read
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let _ = importedWorkout, !showImportPreview {
                    showImportPreview = true
                } else if importedWorkout == nil {
                    // If still no workout after delay, file reading may have failed
                    print("No workout loaded after document picker dismissed")
                }
            }
        }) {
            DocumentPicker(importedWorkout: $importedWorkout, showImportPreview: .constant(false))
        }
        .sheet(isPresented: $showImportPreview, onDismiss: {
            // Clean up after import preview is dismissed
            importedWorkout = nil
        }) {
            ImportWorkoutPreviewContent(
                importedWorkout: $importedWorkout,
                showImportPreview: $showImportPreview
            )
            .environmentObject(workoutController)
        }
    }
    
    private var workoutGrid: some View {
        VStack(spacing: 0) {
            if workoutController.hasActiveSession, let workoutId = workoutController.activeWorkoutId {
                Button(action: {
                    appViewModel.navigateTo(.workoutActiveView(workoutId))
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "figure.run.circle.fill")
                            .font(.title2)
                            .foregroundColor(.staticWhite)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(workoutController.activeWorkoutName ?? "Workout")
                                .font(.headline)
                                .foregroundColor(.staticWhite)
                            Text("Tap to Resume")
                                .font(.subheadline)
                                .foregroundColor(.staticWhite.opacity(0.9))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.body)
                            .foregroundColor(.staticWhite.opacity(0.7))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.myBlue, Color.myBlue.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: Color.myBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
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
        _ = withAnimation {
            deletingWorkouts.insert(workoutId)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            workoutController.deleteWorkout(workoutId)

            // Wait for workouts array to update, then check if workout is gone
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                // Only remove from deletingWorkouts if the workout is actually gone
                if !workoutController.workouts.contains(where: { $0.id == workoutId }) {
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

// Helper view that reacts to changes in importedWorkout
struct ImportWorkoutPreviewContent: View {
    @Binding var importedWorkout: ShareableWorkout?
    @Binding var showImportPreview: Bool
    @EnvironmentObject var workoutController: WorkoutTrackerController

    var body: some View {
        Group {
            if let workout = importedWorkout {
                ImportWorkoutPreviewView(shareableWorkout: workout, isPresented: $showImportPreview)
                    .environmentObject(workoutController)
            } else {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading workout...")
                        .font(.headline)
                }
                .padding()
                .onAppear {
                    // Dismiss if workout doesn't load within 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        if importedWorkout == nil {
                            showImportPreview = false
                        }
                    }
                }
            }
        }
    }
}
