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

    @State private var workoutTitle: String
    @State private var workoutDetailsInput: [WorkoutDetailInput]
    @State private var showAlert: Bool = false
    @State private var errorMessage: String = ""

    var originalWorkoutTitle: String


    init(workoutTitle: String, workoutDetails: [WorkoutDetail], originalWorkoutTitle: String) {
        self._workoutTitle = State(initialValue: workoutTitle)
        self._workoutDetailsInput = State(initialValue: workoutDetails.map { detail in
            WorkoutDetailInput(name: detail.name, id: detail.id, exerciseName: detail.exerciseName, reps: String(detail.reps), weight: String(detail.weight))
        })
        self.originalWorkoutTitle = originalWorkoutTitle
    }



    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Workout Title")) {
                    TextField("Enter Workout Title", text: $workoutTitle)
                        .disableAutocorrection(true)
                }

                Section(header: Text("Workout Details")) {
                    List {
                        ForEach($workoutDetailsInput.indices, id: \.self) { index in
                            WorkoutDetailView(detail: $workoutDetailsInput[index])
                        }
                        .onDelete(perform: deleteDetail)

                        Button(action: addDetail) {
                            Label("Add Item", systemImage: "plus.circle.fill")
                        }
                    }
                }
            }
            .navigationTitle("Edit Workout")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Done") {
                doneAction()
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Incomplete Workout"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func deleteDetail(at offsets: IndexSet) {
        workoutDetailsInput.remove(atOffsets: offsets)
    }

    private func addDetail() {
        workoutDetailsInput.append(WorkoutDetailInput())
    }

    private func doneAction() {
        if workoutTitle.isEmpty {
            errorMessage = "Please Enter a Workout Title"
            showAlert = true
        } else if originalWorkoutTitle != workoutTitle && workoutManager.titleExists(workoutTitle) {
            errorMessage = "Workout Title Already Exists"
            showAlert = true
        } else {
            // Filter out empty detail inputs before processing
            let filledDetails = workoutDetailsInput.filter { detailInput in
                !detailInput.exerciseName.isEmpty || !detailInput.reps.isEmpty || !detailInput.weight.isEmpty
            }
            
            // Proceed only with filled details
            if filledDetails.isEmpty && workoutDetailsInput.isEmpty {
                // If user has not added any new details and all existing details are removed, decide on your logic here.
                // For now, do nothing or show an error message if needed.
                errorMessage = "Please add at least one exercise"
                showAlert = true
            } else {
                // Update the workout details with filled details only
                workoutManager.updateWorkoutDetails(for: originalWorkoutTitle, withNewTitle: workoutTitle, workoutDetailsInput: filledDetails)
                
                presentationMode.wrappedValue.dismiss()
            }
        }
    }



}
