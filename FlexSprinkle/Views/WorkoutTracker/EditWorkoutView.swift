//
//  EditWorkoutView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/5/24.
//

import SwiftUI

struct EditWorkoutView: View {
    @Binding var isFormPresented: Bool
    @State var workoutTitle: String
    @State var workoutDetails: [WorkoutDetail]
    @State var showAlert = false

    var onSave: (String, [WorkoutDetail]) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Workout Title")) {
                    TextField("Enter Workout Title", text: $workoutTitle)
                        .disableAutocorrection(true)
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
            .navigationBarTitle("Edit Workout")
            .navigationBarItems(trailing:
                Button("Done") {
                    if workoutTitle.isEmpty {
                        showAlert = true
                    } else {
                        onSave(workoutTitle, workoutDetails)
                        isFormPresented.toggle()
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

