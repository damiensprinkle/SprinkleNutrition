//
//  NewWorkoutView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/4/24.
//

import SwiftUI

import SwiftUI

import SwiftUI

struct AddWorkoutView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var workoutManager: WorkoutManager

    @State private var workoutTitle: String = ""
    @State private var workoutDetails: [WorkoutDetailInput] = []
    @State private var showingAddExerciseSheet = false
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    private let colorManager = ColorManager()



    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Workout Title")) {
                    TextField("Enter Workout Title", text: $workoutTitle)
                }

                Section(header: Text("Workout Details")) {
                    ForEach($workoutDetails.indices, id: \.self) { index in
                        WorkoutDetailView(detail: $workoutDetails[index])
                    }
                    .onDelete { indexSet in
                        workoutDetails.remove(atOffsets: indexSet)
                    }

                    Button("Add Exercise") {
                        showingAddExerciseSheet = true
                    }
                }
            }
            .actionSheet(isPresented: $showingAddExerciseSheet) {
                ActionSheet(title: Text("Select Exercise Type"), buttons: [
                    .default(Text("Lifting")) { addExercise(isCardio: false) },
                    .default(Text("Cardio")) { addExercise(isCardio: true) },
                    .cancel()
                ])
            }
            .navigationTitle("Add Workout")
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Save", action: saveWorkout)
            )
            .alert(isPresented: $showAlert) {
                           Alert(title: Text("Incomplete Workout"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                       }
        }
    }
    
    private func saveWorkout() {
        if workoutTitle.isEmpty {
                            errorMessage = "Please Enter a Workout Title"
                            showAlert = true
                            return // Exit early
                        }
                        // Check if the workout title already exists
                        if workoutManager.titleExists(workoutTitle) {
                            errorMessage = "Workout Title Already Exists"
                            showAlert = true
                            return // Exit early
                        }
                        // Ensure at least one exercise detail has been filled out
                        let filledDetails = workoutDetails.filter {
                            !$0.exerciseName.isEmpty && !$0.reps.isEmpty && !$0.weight.isEmpty || !$0.exerciseName.isEmpty && !$0.exerciseTime.isEmpty
                        }
                        if filledDetails.isEmpty {
                            // If no valid exercise details are provided, show an alert
                            errorMessage = "Please add at least one exercise detail"
                            showAlert = true
                        } else {
                            // Proceed with adding the workout and its details
                            for detailInput in filledDetails {
                                let exerciseName = detailInput.exerciseName // Already validated as not empty
                                let repsInt = Int32(detailInput.reps) ?? 0 // Default to 10 reps if invalid
                                let weightInt = Int32(detailInput.weight) ?? 0 // Default to 30 weight if invalid
                                let exerciseTime = detailInput.exerciseTime // Already validated as not empty
                                let cardio = detailInput.isCardio // this might not work
                                print(cardio)
                                workoutManager.addWorkoutDetail(
                                    workoutTitle: workoutTitle,
                                    exerciseName: exerciseName,
                                    reps: repsInt,
                                    weight: weightInt,
                                    color: colorManager.getRandomColor(),
                                    isCardio: cardio,
                                    exerciseTime: exerciseTime
                                )
                            }
                            presentationMode.wrappedValue.dismiss()
                        }
    }

    private func addExercise(isCardio: Bool) {
        let newDetail = WorkoutDetailInput(reps: isCardio ? "" : "", weight: isCardio ? "" : "", isCardio: isCardio, exerciseTime: isCardio ? "" : "")
        workoutDetails.append(newDetail)
    }
}
