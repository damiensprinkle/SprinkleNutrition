//
//  NewWorkoutView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/4/24.
//

import SwiftUI

struct AddWorkoutView: View {
    @Binding var isFormPresented: Bool
    @State var workoutTitle: String
    @State var workoutDetails: [WorkoutDetail]
    var onSave: (String, [WorkoutDetail]) -> Void
    var initialWorkout: (String, [WorkoutDetail])?

    // Inject WorkoutManager
    @ObservedObject var workoutManager: WorkoutManager

    // Initialization for creating a new workout
    init(isFormPresented: Binding<Bool>, onSave: @escaping (String, [WorkoutDetail]) -> Void, workoutManager: WorkoutManager) {
        _isFormPresented = isFormPresented
        _workoutTitle = State(initialValue: "")
        _workoutDetails = State(initialValue: [])
        self.onSave = onSave
        self.workoutManager = workoutManager
    }

    // Add a state variable to control the alert
    @State private var showAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Workout Title")) {
                    TextField("Enter Workout Title", text: $workoutTitle)
                        .disableAutocorrection(true) // Disable autocorrection if needed
                }

                Section(header: Text("Workout Details")) {
                    List {
                        ForEach(workoutDetails.indices, id: \.self) { index in
                            WorkoutDetailView(detail: $workoutDetails[index])
                        }
                        .onDelete { indexSet in
                            workoutDetails.remove(atOffsets: indexSet)
                        }
                    }

                    Button(action: {
                        if workoutDetails.count < 15 {
                            workoutDetails.append(WorkoutDetail())
                        }
                    }) {
                        Label("Add Item", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationBarTitle("Add Workout")
            .navigationBarItems(trailing:
                Button("Done") {
                    if workoutTitle.isEmpty {
                        showAlert = true
                    } else {
                        onSave(workoutTitle, workoutDetails)
                        isFormPresented.toggle()

                        // Save workouts to the manager
                        workoutManager.workoutsDict[workoutTitle] = workoutDetails
                        workoutManager.saveWorkouts()
                    }
                }
            )
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Incomplete Title"),
                    message: Text("Please enter a workout title."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
