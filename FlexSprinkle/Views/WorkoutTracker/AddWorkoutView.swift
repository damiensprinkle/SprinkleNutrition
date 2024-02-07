//
//  NewWorkoutView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/4/24.
//

import SwiftUI

struct AddWorkoutView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var workoutManager: WorkoutManager
    
    @State private var workoutTitle: String = ""
    @State private var workoutDetails: [WorkoutDetailInput] = [] // Use WorkoutDetailInput
    @State private var showAlert: Bool = false
    private let colorManager = ColorManager()
    @State private var errorMessage: String = ""

    var body: some View {        
        NavigationStack {
            Form {
                Section(header: Text("Workout Title")) {
                    TextField("Enter Workout Title", text: $workoutTitle)
                        .disableAutocorrection(true)
                }

                Section(header: Text("Workout Details")) {
                    List {
                        ForEach($workoutDetails.indices, id: \.self) { index in
                            WorkoutDetailView(detail: $workoutDetails[index])
                        }
                        .onDelete { indexSet in
                            workoutDetails.remove(atOffsets: indexSet)
                        }
                        Button(action: {
                            workoutDetails.append(WorkoutDetailInput())
                        }) {
                            Label("Add Item", systemImage: "plus.circle.fill")
                        }
                    }
                }
            }
            .navigationTitle("Add Workout")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Done") {
                // Check if the workout title is empty
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
                    !$0.exerciseName.isEmpty && !$0.reps.isEmpty && !$0.weight.isEmpty
                }
                if filledDetails.isEmpty {
                    // If no valid exercise details are provided, show an alert
                    errorMessage = "Please add at least one exercise detail"
                    showAlert = true
                } else {
                    // Proceed with adding the workout and its details
                    for detailInput in filledDetails {
                        let exerciseName = detailInput.exerciseName // Already validated as not empty
                        let repsInt = Int32(detailInput.reps) ?? 10 // Default to 10 reps if invalid
                        let weightInt = Int32(detailInput.weight) ?? 5 // Default to 5 weight if invalid
                        
                        workoutManager.addWorkoutDetail(
                            workoutTitle: workoutTitle,
                            exerciseName: exerciseName,
                            reps: repsInt,
                            weight: weightInt,
                            color: colorManager.getRandomColor()
                        )
                    }
                    presentationMode.wrappedValue.dismiss()
                }
            })


            
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Incomplete Workout"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}


