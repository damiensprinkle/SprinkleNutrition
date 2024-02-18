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
    @FocusState private var focusedField: FocusableField?
    @State private var originalTimeInput: String = ""

    @State private var distanceInput: String = ""
    @State private var timeInput: String = ""
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var focusManager: FocusManager
    @State private var rawInput: String = ""
    
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
                    print(" on appearing set input is \(setInput.time)")
                    print("this is formatted to :  \(formattedTime)")
                    timeInput = "\(formattedTime)"
                }

                .frame(width: 100)
            
                .keyboardType(.numberPad)
        }
        .disabled(!workoutStarted)
        .opacity(!workoutStarted ? 0.5 : 1) // Manually adjust opacity to grey out view
        .foregroundColor(!workoutStarted ? .gray : .myBlack)
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
    
    
    private func interpretAsTotalSeconds(_ formattedTime: String) -> Int {
        let components = formattedTime.split(separator: ":").compactMap { Int($0) }
        guard components.count == 3 else { return 0 }
        
        let hours = components[0]
        let minutes = components[1]
        let seconds = components[2]
        
        // Ensure components are within valid ranges
        let validHours = max(0, min(99, hours))
        let validMinutes = max(0, min(59, minutes))
        let validSeconds = max(0, min(59, seconds))
        
        return validHours * 3600 + validMinutes * 60 + validSeconds
    }
}



extension String {
    func padStart(totalWidth: Int, with char: Character) -> String {
        let toPad = totalWidth - self.count
        guard toPad > 0 else { return self }
        
        return String(repeating: char, count: toPad) + self
    }
}
