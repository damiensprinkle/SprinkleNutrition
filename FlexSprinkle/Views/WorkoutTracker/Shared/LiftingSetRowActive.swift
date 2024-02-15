//
//  CardioSetRowsActive.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/13/24.
//

import SwiftUI

struct LiftingSetRowActive: View {
    let setIndex: Int
    @Binding var setInput: SetInput
    let workoutDetails: WorkoutDetailInput
    let workoutId: UUID
    let workoutStarted: Bool
    @FocusState private var weightFieldFocused: Bool
    @FocusState private var repsFieldFocused: Bool
    @State private var weightInput: String = ""
    @State private var repsInput: String = ""
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var focusManager: FocusManager


    var body: some View {
        HStack {
            Text("\(setIndex)")
                .frame(width: 50, alignment: .leading)
            Spacer()
            Divider()
            TextField("Reps", text: $repsInput)
                .focused($repsFieldFocused)
                .onChange(of: repsFieldFocused) {
                    if repsFieldFocused {
                        focusManager.isAnyTextFieldFocused = true
                        repsInput = ""
                    } else {
                        // When focus is lost and no input was entered, reset to the original value
                        if repsInput.isEmpty {
                            repsInput = "\(setInput.reps)"
                            saveWorkoutDetail()

                        } else {
                            // Update the model with new input
                            setInput.reps = Int32(repsInput)!
                            saveWorkoutDetail()

                        }
                    }
                }
                .onAppear {
                    repsInput = "\(setInput.reps)"
                }
                .keyboardType(.numberPad)
                .frame(width: 100)
            Spacer()
            Divider()
            TextField("Weight", text: $weightInput)
                .focused($weightFieldFocused)
                .onChange(of: weightFieldFocused) {
                    if weightFieldFocused {
                        focusManager.isAnyTextFieldFocused = true
                        weightInput = ""
                    } else {
                        // When focus is lost and no input was entered, reset to the original value
                        if weightInput.isEmpty {
                            weightInput = "\(setInput.weight)"

                        } else {
                            // Update the model with new input
                            setInput.weight = Int32(weightInput)!
                            saveWorkoutDetail()
                        }
                    }
                }
                .onAppear {
                    weightInput = "\(setInput.weight)"
                }
                .keyboardType(.numberPad)
                .frame(width: 100)
        }
        .disabled(!workoutStarted)
        .opacity(!workoutStarted ? 0.5 : 1) // Manually adjust opacity to grey out view
        .foregroundColor(!workoutStarted ? .gray : .myBlack)
    }

    func saveWorkoutDetail() {
        // Ensure setInput is updated with the latest input values
        setInput.distance = Float(weightInput) ?? 0.0
        setInput.reps = Int32(repsInput) ?? 0

        // Proceed with saving
        let setsInput = [setInput] // Directly use updated setInput
        workoutManager.saveOrUpdateSetsDuringActiveWorkout(workoutId: workoutId, exerciseId: workoutDetails.exerciseId!, exerciseName: workoutDetails.exerciseName, setsInput: setsInput, isCardio: workoutDetails.isCardio, orderIndex: workoutDetails.orderIndex)
    }
}
