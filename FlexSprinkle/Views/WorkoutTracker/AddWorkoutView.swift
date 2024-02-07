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
    
    var body: some View {
        NavigationView {
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
            .navigationBarTitle("Add Workout", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Done") {
                if workoutTitle.isEmpty {
                    showAlert = true
                } else {
                    // Check if there are any details provided
                    if workoutDetails.isEmpty {
                        // Add a default workout detail if no details are provided
                        workoutManager.addWorkoutDetail(
                            workoutTitle: workoutTitle,
                            exerciseName: "Default Exercise", // Default exercise name
                            reps: 10, // Default number of reps
                            weight: 5, // Default weight
                            color: "MyPurple" // Default color
                        )
                    } else {
                        // Iterate through each detailInput, providing defaults for missing values
                        workoutDetails.forEach { detailInput in
                            let exerciseName = detailInput.exerciseName.isEmpty ? "Default Exercise" : detailInput.exerciseName
                            let repsInt = detailInput.reps.isEmpty ? 10 : Int32(detailInput.reps) ?? 10 // Default to 10 reps if empty or invalid
                            let weightInt = detailInput.weight.isEmpty ? 5 : Int32(detailInput.weight) ?? 5 // Default to 5 weight if empty or invalid
                            
                            workoutManager.addWorkoutDetail(
                                workoutTitle: workoutTitle,
                                exerciseName: exerciseName,
                                reps: repsInt,
                                weight: weightInt,
                                color: "MyPurple"
                            )
                        }
                    }
                    presentationMode.wrappedValue.dismiss()
                }
            }


            )
            
            
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Incomplete Workout"), message: Text("Please enter a workout title and at least one exercise"), dismissButton: .default(Text("OK")))
            }
        }
    }
}


struct WorkoutDetailInput {
    var name: String = ""
    var id: UUID? // Optional, as it might not exist for new details
    var exerciseName: String = ""
    var reps: String = ""
    var weight: String = ""
}
