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
        if workoutTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please Enter a Workout Title"
            showAlert = true
        }
        else if workoutDetails.isEmpty {
            errorMessage = "Please add at least one exercise detail"
            showAlert = true
        }
        else if workoutManager.titleExists(workoutTitle) {
            errorMessage = "Title Already Exists"
            showAlert = true
        }
         else {
            // Iterate over filled details and add them
            for detail in workoutDetails {
                workoutManager.addWorkoutDetail(
                    workoutTitle: workoutTitle,
                    exerciseName: detail.exerciseName,
                    reps: Int32(detail.reps) ?? 0,
                    weight: Int32(detail.weight) ?? 0,
                    color: colorManager.getRandomColor(),
                    isCardio: detail.isCardio,
                    exerciseTime: detail.exerciseTime
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
