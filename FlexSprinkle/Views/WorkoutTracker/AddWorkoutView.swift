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
                if workoutTitle.isEmpty {
                    errorMessage = "Please Enter a Workout Title"
                    showAlert = true
                } else if workoutManager.titleExists(workoutTitle) {
                    errorMessage = "Workout Title Already Exists"
                    showAlert = true
                } else {
                    // Filter out empty detail inputs
                    let filledDetails = workoutDetails.filter { detailInput in
                        !detailInput.exerciseName.isEmpty || !detailInput.reps.isEmpty || !detailInput.weight.isEmpty
                    }
                    
                    // Proceed only with filled details, skipping entirely if no details are filled
                    if filledDetails.isEmpty {
                        // If all inputs were empty, decide on your logic here.
                        // For now, we do nothing, respecting your requirement to not default if any detail is provided.
                    } else {
                        // Iterate through each filled detailInput
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


