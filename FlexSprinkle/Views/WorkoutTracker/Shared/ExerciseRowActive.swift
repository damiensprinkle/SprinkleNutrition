//
//  ExerciseRowActive.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 11/9/24.
//

import SwiftUI

struct ExerciseRowActive: View {
    @Binding var setInput: SetInput
    
    let setIndex: Int
    let workoutDetails: WorkoutDetailInput
    let workoutId: UUID
    let workoutStarted: Bool
    var exerciseQuantifier: String
    var exerciseMeasurement: String

    
    @FocusState private var focusedField: FocusableField?
    @State private var originalTimeInput: String = ""
    @State private var hasLoaded = false
    @State private var distanceInput: String = ""
    @State private var timeInput: String = ""
    @State private var weightInput: String = ""
    @State private var repsInput: String = ""
    @State private var checked: Bool = false
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var focusManager: FocusManager
    
    
    var body: some View {
        HStack {
            Spacer()
            Text("\(setIndex)")
                .frame(width: 50, alignment: .leading)
            Divider()
            if exerciseQuantifier == "Reps" {
                repsTextField
                Spacer()
                Divider()
            }
            
            if exerciseQuantifier == "Distance" {
                distanceTextField
                Spacer()
                Divider()
            }
            if exerciseMeasurement == "Weight" {
                weightTextField
                Spacer()
                Divider()
            }
            
            if exerciseMeasurement == "Time"  {
                timeTextField
                Spacer()
                Divider()
            }
            
            Toggle(isOn: $checked) {
                Text("")
            }
            .onAppear {
                if hasLoaded {
                    checked = setInput.isCompleted
                }
            }
            .onChange(of: checked) {
                setInput.isCompleted = checked
                saveWorkoutDetail()
            }
            .frame(width: 50)
            .toggleStyle(SwitchToggleStyle(tint: Color(UIColor.green)))
            .scaleEffect(0.8)
            .padding(.trailing, 10)

        }
        .onAppear{
            if (!hasLoaded){
                hasLoaded = true
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                if(focusedField == .distance){
                    Button("Done") {
                        focusedField = nil
                        focusManager.isAnyTextFieldFocused = false
                        focusManager.currentlyFocusedField = nil
                    }
                }
                if(focusedField == .time) {
                    Button("Done") {
                        focusedField = nil
                        focusManager.isAnyTextFieldFocused = false
                        focusManager.currentlyFocusedField = nil
                    }
                }
                if(focusedField == .weight){
                    Button("Done") {
                        focusedField = nil
                        focusManager.isAnyTextFieldFocused = false
                        focusManager.currentlyFocusedField = nil
                    }
                }
                if(focusedField == .reps) {
                    Button("Done") {
                        focusedField = nil
                        focusManager.isAnyTextFieldFocused = false
                        focusManager.currentlyFocusedField = nil
                    }
                }
            }
        }
        .disabled(!workoutStarted)
        .opacity(!workoutStarted ? 0.5 : 1)
        .foregroundColor(!workoutStarted ? .gray : .myBlack)
        .background(checked ? Color.green.opacity(0.2) : Color.clear)
    }
    
    private var repsTextField: some View {
        TextField("Reps", text: $repsInput)
            .focused($focusedField, equals: .reps)
            .onChange(of: focusedField) {
                if focusedField == .reps {
                    focusManager.isAnyTextFieldFocused = true
                    focusManager.currentlyFocusedField = .reps
                    repsInput = ""
                } else {
                    if repsInput.isEmpty {
                        repsInput = "\(setInput.reps)"
                        saveWorkoutDetail()
                    }
                }
            }
            .onChange(of: repsInput) {
                if !repsInput.isEmpty {
                    let newReps = Int32(repsInput) ?? 0
                    if setInput.reps != newReps {
                        setInput.reps = newReps
                        saveWorkoutDetail()
                    }
                }
            }
            .onAppear {
                repsInput = "\(setInput.reps)"
            }
            .keyboardType(.numberPad)
            .frame(width: 100, height: 20)
    }
    
    private var distanceTextField: some View {
        TextField("Distance", text: $distanceInput)
            .focused($focusedField, equals: .distance)
            .onChange(of: focusedField) {
                if focusedField == .distance {
                    distanceInput = ""
                    focusManager.isAnyTextFieldFocused = true
                    focusManager.currentlyFocusedField = .distance
                } else {
                    if distanceInput.isEmpty {
                        distanceInput = "\(setInput.distance)"
                        saveWorkoutDetail()
                    }
                }
            }
            .onChange(of: distanceInput){
                if(!distanceInput.isEmpty){
                    let newDistance = Float(distanceInput) ?? 0.0
                    if(setInput.distance != newDistance){
                        setInput.distance = newDistance
                        saveWorkoutDetail()
                    }
                }
            }
            .onAppear {
                distanceInput = "\(setInput.distance)"
            }
            .keyboardType(.numberPad)
            .frame(width: 100, height: 20)
    }
    
    private var weightTextField: some View {
        TextField("Weight", text: $weightInput)
            .focused($focusedField, equals: .weight)
            .onChange(of: focusedField) {
                if focusedField == .weight {
                    focusManager.isAnyTextFieldFocused = true
                    focusManager.currentlyFocusedField = .weight
                    weightInput = ""
                } else {
                    if weightInput.isEmpty {
                        weightInput = "\(setInput.weight)"
                    }
                }
            }
            .onChange(of: weightInput){
                if(!weightInput.isEmpty){
                    let newWeight = Float(weightInput) ?? 0
                    if(setInput.weight != newWeight){
                        setInput.weight = newWeight
                        saveWorkoutDetail()
                    }
                }
            }
            .onAppear {
                weightInput = "\(setInput.weight)"
            }
            .keyboardType(.decimalPad)
            .frame(width: 100, height: 20)
    }
    
    private var timeTextField : some View {
        TextField("Time", text: $timeInput)
            .focused($focusedField, equals: .time)
            .onChange(of: focusedField) {
                if focusedField == .time {
                    originalTimeInput = timeInput
                    timeInput = "00:00:00"
                    focusManager.isAnyTextFieldFocused = true
                    focusManager.currentlyFocusedField = .time
                } else if focusedField == nil {
                    if timeInput == "00:00:00" {
                        timeInput = originalTimeInput
                    }
                    else {
                        formatInput(timeInput)
                        if !timeInput.isEmpty && timeInput != originalTimeInput {
                            saveWorkoutDetail()
                        }
                    }
                }
            }
            .onChange(of: timeInput){
                formatInput(timeInput)
                if(!timeInput.isEmpty){
                    let formattedTime = formatTimeFromSeconds(totalSeconds: Int(setInput.time))
                    if formattedTime != "00:00:00" && timeInput != formattedTime {
                        saveWorkoutDetail()
                    }
                }
            }
            .onAppear {
                let formattedTime = formatTimeFromSeconds(totalSeconds: Int(setInput.time))
                timeInput = "\(formattedTime)"
            }
        
            .frame(width: 100, height: 20)
            .keyboardType(.numberPad)
    }
    
    func saveWorkoutDetail() {
        let setsInput = [setInput]
        workoutManager.saveOrUpdateSetsDuringActiveWorkout(workoutId: workoutId, exerciseId: workoutDetails.exerciseId!, exerciseName: workoutDetails.exerciseName, setsInput: setsInput, orderIndex: workoutDetails.orderIndex)
    }
    
    private func formatInput(_ newValue: String) {
        let filtered = newValue.filter { "0123456789".contains($0) }
        let constrainedInput = String(filtered.suffix(6))
        let totalSeconds = convertToSeconds(constrainedInput)
        
        timeInput = formatToHHMMSS(totalSeconds)
        setInput.time = Int32(totalSeconds)
    }
    
    private func convertToSeconds(_ input: String) -> Int {
        let paddedInput = input.padding(toLength: 6, withPad: "0", startingAt: 0)
        let hours = Int(paddedInput.prefix(2)) ?? 0
        let minutes = Int(paddedInput.dropFirst(2).prefix(2)) ?? 0
        let seconds = Int(paddedInput.suffix(2)) ?? 0
        
        return hours * 3600 + minutes * 60 + seconds
    }
    
    private func formatToHHMMSS(_ totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
