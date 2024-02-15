//
//  CardioSetRowsActive.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/13/24.
//

import SwiftUI

struct CardioSetRowActive: View {
    let setIndex: Int
    @Binding var setInput: SetInput
    let workoutDetails: WorkoutDetailInput
    let workoutId: UUID
    let workoutStarted: Bool
    @FocusState private var distanceFieldFocused: Bool
    @FocusState private var timeFieldFocused: Bool
    @State private var distanceInput: String = ""
    @State private var timeInput: String = ""
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var focusManager: FocusManager


    var body: some View {
        HStack {
            Text("\(setIndex)")
                .frame(width: 50, alignment: .leading)
            Spacer()
            Divider()
            TextField("Distance", text: $distanceInput)
                .focused($distanceFieldFocused)
                .onChange(of: distanceFieldFocused) {
                    if distanceFieldFocused {
                        distanceInput = ""
                        focusManager.isAnyTextFieldFocused = true
                    } else {
                        // When focus is lost and no input was entered, reset to the original value
                        if distanceInput.isEmpty {
                            distanceInput = "\(setInput.distance)"
                            saveWorkoutDetail()

                        } else {
                            // Update the model with new input
                            setInput.distance = Int32(distanceInput)!
                            saveWorkoutDetail()

                        }
                    }
                }
                .onAppear {
                    distanceInput = "\(setInput.distance)"
                }
                .keyboardType(.numberPad)
                .frame(width: 100)
            Spacer()
            Divider()
            TextField("Time", text: $timeInput)
                .focused($timeFieldFocused)
                .onChange(of: timeFieldFocused) {
                    if timeFieldFocused {
                        timeInput = ""
                        focusManager.isAnyTextFieldFocused = true
                    } else {
                        // When focus is lost and no input was entered, reset to the original value
                        if timeInput.isEmpty {
                            timeInput = "\(setInput.time)"

                        } else {
                            // Update the model with new input
                            setInput.time = Int32(timeInput)!
                            saveWorkoutDetail()

                        }
                    }
                }
                .onAppear {
                    timeInput = "\(setInput.time)"
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
        setInput.distance = Int32(distanceInput) ?? 0
        setInput.time = Int32(timeInput) ?? 0

        // Proceed with saving
        let setsInput = [setInput] // Directly use updated setInput
        workoutManager.saveOrUpdateSetsDuringActiveWorkout(workoutId: workoutId, exerciseId: workoutDetails.exerciseId!, exerciseName: workoutDetails.exerciseName, setsInput: setsInput, isCardio: workoutDetails.isCardio, orderIndex: workoutDetails.orderIndex)
    }
}
