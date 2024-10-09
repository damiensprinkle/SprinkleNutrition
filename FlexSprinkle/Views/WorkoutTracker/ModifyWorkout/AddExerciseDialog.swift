//
//  AddExerciseView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/13/24.
//

import SwiftUI

struct AddExerciseDialog: View {
    @Binding var workoutDetails: [WorkoutDetailInput]
    @Binding var showingDialog: Bool
    @State private var selectedWorkoutType: String = "Repetitive" // Default selection
    @State private var exerciseName: String = "" // State to hold the exercise name input
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Exercise Details").font(.headline)
            
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(exerciseName.isEmpty ? Color.red.opacity(0.3) : Color(UIColor.systemBackground)) // Adjust color here
                    .frame(height: 36)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1) // Grey border
                    )
                
                TextField("Exercise Name", text: $exerciseName)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
            }
            .frame(height: 36) // Fixed height for TextField
            
            Picker("Workout Type", selection: $selectedWorkoutType) {
                Text("Repetitive").tag("Repetitive")
                Text("Timed").tag("Timed")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            HStack {
                Button("Cancel") {
                    self.showingDialog = false
                }
                Spacer()
                
                Button("  Add  ") {
                    addNewExercise()
                }
                
            }
        }
        .onAppear{
            hideKeyboard()
        }
        .padding()
        .background(Color.myWhite)
        .cornerRadius(15)
        .shadow(radius: 10)
    }
    
    private func addNewExercise() {
        if(exerciseName.isEmpty) {
            return
        }
        else{
            
            //get existing indexes of workouts
            let newIndex = workoutDetails.last?.orderIndex ?? 0
            let isCardio = selectedWorkoutType == "Timed"
            let newDetail = WorkoutDetailInput(exerciseName: exerciseName, isCardio: isCardio, orderIndex: newIndex + 1, sets: [SetInput(reps: 0, weight: 0, time: 0, distance: 0)]) // Initialize with the provided exercise name and a default set
            workoutDetails.append(newDetail)
            self.showingDialog = false
        }
        
    }
    
    private func hideKeyboard()
    {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
