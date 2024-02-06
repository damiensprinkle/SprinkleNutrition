//
//  EditWorkoutView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/5/24.
//

import SwiftUI

import SwiftUI

struct EditWorkoutView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var workoutManager: WorkoutManager // Use if shared across views
    
    @State private var workoutTitle: String
    @State private var workoutDetails: [WorkoutDetail]
    @State private var showAlert: Bool = false

    var originalWorkoutTitle: String // To identify the workout being edited

    init(workoutTitle: String, workoutDetails: [WorkoutDetail], originalWorkoutTitle: String) {
        self._workoutTitle = State(initialValue: workoutTitle)
        self._workoutDetails = State(initialValue: workoutDetails)
        self.originalWorkoutTitle = originalWorkoutTitle
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Workout Title")) {
                    TextField("Enter Workout Title", text: $workoutTitle)
                        .disableAutocorrection(true)
                }

                Section(header: Text("Workout Details")) {
                    List {
                        ForEach($workoutDetails) { $detail in
                            WorkoutDetailView(detail: $detail)
                        }
                        .onDelete(perform: deleteDetail)

                        Button(action: addDetail) {
                            Label("Add Item", systemImage: "plus.circle.fill")
                        }
                    }
                }
            }
            .navigationBarTitle("Edit Workout", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Done") {
                doneAction()
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Incomplete Title"), message: Text("Please enter a workout title."), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func deleteDetail(at offsets: IndexSet) {
        workoutDetails.remove(atOffsets: offsets)
    }

    private func addDetail() {
        workoutDetails.append(WorkoutDetail())
    }

    private func doneAction() {
        if workoutTitle.isEmpty || workoutDetails.isEmpty {
            showAlert = true
        } else {
            // Update the workout details
            if originalWorkoutTitle != workoutTitle {
                workoutManager.deleteWorkout(withTitle: originalWorkoutTitle)
            }
            workoutManager.workoutsDict[workoutTitle] = workoutDetails
            if !workoutManager.workouts.contains(workoutTitle) {
                workoutManager.workouts.append(workoutTitle)
            }
            workoutManager.saveWorkouts()
            
            presentationMode.wrappedValue.dismiss()
        }
    }
}
