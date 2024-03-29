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
    @FocusState private var focusedField: FocusableField?
    @State private var originalTimeInput: String = ""
    @State private var hasLoaded = false

    
    @State private var distanceInput: String = ""
    @State private var timeInput: String = ""
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
            TextField("Distance", text: $distanceInput)
                .focused($focusedField, equals: .distance)
                .onChange(of: focusedField) {
                    if focusedField == .distance {
                        distanceInput = ""
                        focusManager.isAnyTextFieldFocused = true
                    } else {
                        if distanceInput.isEmpty {
                            distanceInput = "\(setInput.distance)"
                            saveWorkoutDetail()
                        }
                    }
                }
                .onChange(of: distanceInput){
                    if(!distanceInput.isEmpty){
                        setInput.distance = Float(distanceInput) ?? 0.0
                        saveWorkoutDetail()
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
                .focused($focusedField, equals: .time)
                .onChange(of: focusedField) {
                    if focusedField == .time {
                        // Remember the current input as the original before changing it
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
                        if(formattedTime != "00:00:00") {
                            saveWorkoutDetail()
                        }
                        
                    }
                }
                .onAppear {
                    let formattedTime = formatTimeFromSeconds(totalSeconds: Int(setInput.time))
                    timeInput = "\(formattedTime)"
                }
            
                .frame(width: 100)
            
                .keyboardType(.numberPad)
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
                if(focusedField == .distance){
                    Button("Done") {
                        focusedField = nil
                    }
                }
                if(focusedField == .time) {
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
    
    
    
    private func formatInput(_ newValue: String) {
        // Remove non-numeric characters
        let filtered = newValue.filter { "0123456789".contains($0) }
        
        // Ensure that the input is not longer than 6 characters (HHMMSS)
        let constrainedInput = String(filtered.suffix(6))
        
        // Convert the constrained input into seconds
        let totalSeconds = convertToSeconds(constrainedInput)
        
        // Update the formatted time string and the model
        timeInput = formatToHHMMSS(totalSeconds)
        setInput.time = Int32(totalSeconds)
    }
    
    private func convertToSeconds(_ input: String) -> Int {
        // Pad the input string to ensure it has at least 6 characters
        let paddedInput = input.padding(toLength: 6, withPad: "0", startingAt: 0)
        
        // Extract hours, minutes, and seconds
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
