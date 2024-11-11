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
    @State private var selectedWorkoutQuantifier: String = "Reps"
    @State private var selectedWorkoutMeasurement: String = "Weight"

    @State private var exerciseName: String = ""
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Exercise Details").font(.headline)
            
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(exerciseName.isEmpty ? Color.red.opacity(0.3) : Color(UIColor.systemBackground))
                    .frame(height: 36)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                
                TextField("Exercise Name", text: $exerciseName)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
            }
            .frame(height: 36)
            
            Picker("Workout Quantifier", selection: $selectedWorkoutQuantifier) {
                Text("Reps").tag("Reps")
                Text("Distance").tag("Distance")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Picker("Workout Measurement", selection: $selectedWorkoutMeasurement) {
                Text("Weight").tag("Weight")
                Text("Time").tag("Time")
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
            let measurement = selectedWorkoutMeasurement
            let quantifier = selectedWorkoutQuantifier
            let newIndex = workoutDetails.last?.orderIndex ?? 0
            let newDetail = WorkoutDetailInput(exerciseName: exerciseName, orderIndex: newIndex + 1, sets: [SetInput(reps: 0, weight: 0, time: 0, distance: 0)], exerciseQuantifier: quantifier, exerciseMeasurement: measurement)
            workoutDetails.append(newDetail)
            self.showingDialog = false
        }
        
    }
    
    private func hideKeyboard()
    {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
