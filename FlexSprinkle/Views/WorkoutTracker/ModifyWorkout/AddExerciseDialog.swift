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
    @State private var selectedWorkoutType: String = "Lifting" // Default selection
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
                Text("Lifting").tag("Lifting")
                Text("Cardio").tag("Cardio")
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
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
    }
    
    struct FilledButtonStyle: ButtonStyle {
        var backgroundColor: Color
        
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .padding()
                .background(backgroundColor)
                .foregroundColor(.white)
                .cornerRadius(8)
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        }
    }
    
    private func addNewExercise() {
        if(exerciseName.isEmpty) {
            return
        }
        else{
            let isCardio = selectedWorkoutType == "Cardio"
            let newDetail = WorkoutDetailInput(exerciseName: exerciseName, isCardio: isCardio, sets: [SetInput(reps: 0, weight: 0, time: 0, distance: 0)]) // Initialize with the provided exercise name and a default set
            workoutDetails.append(newDetail)
            self.showingDialog = false
        }
        
    }
    
    private func hideKeyboard()
    {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
