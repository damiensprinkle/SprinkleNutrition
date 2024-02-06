//
//  NewWorkoutView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/4/24.
//

import SwiftUI

import SwiftUI

struct AddWorkoutView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var workoutManager: WorkoutManager
    
    @State private var workoutTitle: String = ""
    @State private var workoutDetails: [WorkoutDetail] = []
    @State private var showAlert: Bool = false
    
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
                        ForEach($workoutDetails) { $detail in
                            WorkoutDetailView(detail: $detail)
                        }
                        .onDelete { indexSet in
                            workoutDetails.remove(atOffsets: indexSet)
                        }
                        Button(action: {
                            workoutDetails.append(WorkoutDetail())
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
                if workoutTitle.isEmpty || workoutDetails.isEmpty {
                    showAlert = true
                } else {
                    onSave(workoutTitle, workoutDetails)
                    presentationMode.wrappedValue.dismiss()
                }
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Incomplete Title"), message: Text("Please enter a workout title."), dismissButton: .default(Text("OK")))
            }
        }
    }
}
