//
//  EditWorkoutView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/5/24.
//

import SwiftUI

struct EditWorkoutView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var workoutManager: WorkoutManager
    
    let workoutId: UUID
    @State private var workoutTitle: String = ""
    @State private var workoutDetailsInput: [WorkoutDetailInput] = []
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var showingAddExerciseSheet = false
    
    init(workoutId: UUID) {
        self.workoutId = workoutId
    }
    
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Workout Title")) {
                    TextField("Enter Workout Title", text: $workoutTitle)
                }
                
                Section(header: Text("Workout Details")) {
                    ForEach($workoutDetailsInput.indices, id: \.self) { index in
                        WorkoutDetailView(detail: $workoutDetailsInput[index])
                    }
                    .onDelete(perform: deleteDetail)
                    
                    Button("Add Exercise") {
                        showingAddExerciseSheet = true
                    }
                    .actionSheet(isPresented: $showingAddExerciseSheet) {
                        ActionSheet(title: Text("Select Exercise Type"), buttons: [
                            .default(Text("Lifting")) { addExercise(isCardio: false) },
                            .default(Text("Cardio")) { addExercise(isCardio: true) },
                            .cancel()
                        ])
                    }
                }
            }
            .navigationTitle("Edit Workout")
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Save", action: saveWorkout)
            )
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear(perform: loadWorkoutDetails)
        }
    }
    
    private func loadWorkoutDetails() {
        guard let workout = workoutManager.fetchWorkoutById(for: workoutId) else {
            print("Could not find workout with ID \(workoutId)")
            return
        }
        
        self.workoutTitle = workout.name ?? ""
        
        if let detailsSet = workout.details as? Set<WorkoutDetail> {
            let details = detailsSet.sorted { $0.exerciseName! < $1.exerciseName! } // Sort if needed
            self.workoutDetailsInput = details.map { detail in
                WorkoutDetailInput(
                    id: detail.id,
                    exerciseId: detail.exerciseId,
                    exerciseName: detail.exerciseName!,
                    reps: detail.isCardio ? "" : String(detail.reps),
                    weight: detail.isCardio ? "" : String(detail.weight),
                    isCardio: detail.isCardio,
                    exerciseTime: detail.isCardio ? detail.exerciseTime! : ""
                )
            }
        }
    }
    
    
    private func addExercise(isCardio: Bool) {
        var newDetail = WorkoutDetailInput(isCardio: isCardio)
        newDetail.isCardio = isCardio
        workoutDetailsInput.append(newDetail)
    }
    
    private func saveWorkout() {
        if workoutTitle.isEmpty {
            errorMessage = "Please Enter a Workout Title"
            showAlert = true
        } else if workoutTitle != workoutTitle && workoutManager.titleExists(workoutTitle) {
            errorMessage = "Workout Title Already Exists"
            showAlert = true
        } else {
            // Filter out empty detail inputs before processing
            let filledDetails = workoutDetailsInput.filter { detail in
                if detail.isCardio {
                    return !detail.exerciseName.isEmpty && !detail.exerciseTime.isEmpty
                } else {
                    return !detail.exerciseName.isEmpty && (!detail.reps.isEmpty || !detail.weight.isEmpty)
                }
            }
            
            // Proceed only with filled details
            if filledDetails.isEmpty && workoutDetailsInput.isEmpty {
                // If user has not added any new details and all existing details are removed, decide on your logic here.
                // For now, do nothing or show an error message if needed.
                errorMessage = "Please add at least one exercise"
                showAlert = true
            } else {
                // Update the workout details with filled details only
                workoutManager.updateWorkoutDetails(workoutId: workoutId, workoutDetailsInput: filledDetails)
                workoutManager.updateWorkoutTitle(workoutId: workoutId, to: workoutTitle)
                
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private func deleteDetail(at offsets: IndexSet) {
        workoutDetailsInput.remove(atOffsets: offsets)
    }
    
}
