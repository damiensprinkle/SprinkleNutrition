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
    @FocusState private var focusedField: FocusableField?
    @State private var hasLoaded = false

    @State private var weightInput: String = ""
    @State private var repsInput: String = ""
    @State private var isCompleted: Bool = false

    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var focusManager: FocusManager
    
    var body: some View {
        HStack {
            Spacer()
            Text("\(setIndex)")
                .frame(width: 50, alignment: .leading)
            Spacer()
            Divider()
            TextField("Reps", text: $repsInput)
                .focused($focusedField, equals: .reps)
                .onChange(of: focusedField) {
                    if focusedField == .reps {
                        focusManager.isAnyTextFieldFocused = true
                        repsInput = ""
                    } else {
                        // When focus is lost and no input was entered, reset to the original value
                        if repsInput.isEmpty {
                            repsInput = "\(setInput.reps)"
                            saveWorkoutDetail()
                        }
                    }
                }
                .onChange(of: repsInput){
                    if(!repsInput.isEmpty){
                        if(Int32(repsInput)! != 0){
                            setInput.reps = Int32(repsInput) ?? 0
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
                .focused($focusedField, equals: .weight)
                .onChange(of: focusedField) {
                    if focusedField == .weight {
                        focusManager.isAnyTextFieldFocused = true
                        weightInput = ""
                    } else {
                        // When focus is lost and no input was entered, reset to the original value
                        if weightInput.isEmpty {
                            weightInput = "\(setInput.weight)"
                        }
                    }
                }
                .onChange(of: weightInput){
                    if(!weightInput.isEmpty){
                        setInput.weight = Int32(weightInput) ?? 0
                        saveWorkoutDetail()
                    }
                }
                .onAppear {
                    weightInput = "\(setInput.weight)"
                }
                .keyboardType(.numberPad)
                .frame(width: 100)
            Divider()
            Toggle("", isOn: $isCompleted)
                .onChange(of: isCompleted) {
                    if hasLoaded {
                        setInput.isCompleted = isCompleted
                        saveWorkoutDetail()
                    }
                }
                .toggleStyle(CheckboxStyle())
                .labelsHidden()
                .onAppear {
                    isCompleted = setInput.isCompleted
                    hasLoaded = true
                }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                if(focusedField == .weight){
                    Button("Done") {
                        focusedField = nil
                    }
                }
                if(focusedField == .reps) {
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
        }
        .disabled(!workoutStarted)
        .opacity(!workoutStarted ? 0.5 : 1) // Manually adjust opacity to grey out view
        .foregroundColor(!workoutStarted ? .gray : .myBlack)
        .background(isCompleted ? Color.green.opacity(0.2) : Color.clear) // Conditional background color
    }
    
    func saveWorkoutDetail() {
        // Proceed with saving
        let setsInput = [setInput] // Directly use updated setInput
        workoutManager.saveOrUpdateSetsDuringActiveWorkout(workoutId: workoutId, exerciseId: workoutDetails.exerciseId!, exerciseName: workoutDetails.exerciseName, setsInput: setsInput, isCardio: workoutDetails.isCardio, orderIndex: workoutDetails.orderIndex)
    }
}
