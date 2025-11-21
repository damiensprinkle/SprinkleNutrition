//
//  ExerciciseRow.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 11/9/24.
//

import SwiftUI

struct ExerciseRow: View {
    let setIndex: Int
    @Binding var setInput: SetInput
    @State private var repsInput: String = ""
    @State private var originalReps: String = ""
    
    @State private var weightInput: String = ""
    @State private var originalWeight: String = ""
    
    @State private var distanceInput: String = ""
    @State private var originalDistance: String = ""
    
    @State private var timeInput: String = ""
    @State private var originalTime: String = ""
    
    @FocusState private var focusedField: FocusableField?
    @EnvironmentObject var focusManager: FocusManager
    
    @AppStorage("weightPreference") private var weightPreference: String = "Lbs"
    @AppStorage("distancePreference") private var distancePreference: String = "Mile"
    
    var exerciseQuantifier: String
    var exerciseMeasurement: String
    
    var body: some View {
        HStack {
            Text("\(setIndex)")
                .frame(width: 50, alignment: .leading)
                .padding(.leading, 8)
            Spacer()
            Divider()
            
            if exerciseQuantifier == "Reps" {
                TextField("Reps", text: $repsInput)
                    .focused($focusedField, equals: .reps)
                    .onChange(of: focusedField) {
                        if focusedField == .reps {
                            focusManager.isAnyTextFieldFocused = true
                            focusManager.currentlyFocusedField = .reps
                            originalReps = repsInput
                            repsInput = ""
                        } else if repsInput.isEmpty {
                            repsInput = originalReps
                        }
                    }
                    .onChange(of: repsInput) {
                        validateAndSetInputInt(&repsInput, for: &setInput.reps, maxLength: 3)
                        if !repsInput.isEmpty {
                            let newReps = Int32(repsInput) ?? 0
                            if setInput.reps != newReps {
                                setInput.reps = newReps
                            }
                        }
                    }
                    .onAppear {
                        repsInput = "\(setInput.reps)"
                        originalReps = repsInput
                    }
                    .keyboardType(.numberPad)
                    .frame(width: 100, height: 20)
            }
            
            
            if exerciseQuantifier == "Distance" {
                TextField("Distance", text: $distanceInput)
                    .focused($focusedField, equals: .distance)
                    .onChange(of: focusedField) {
                        if focusedField == .distance {
                            focusManager.isAnyTextFieldFocused = true
                            focusManager.currentlyFocusedField = .distance
                            originalDistance = distanceInput
                            distanceInput = ""
                        } else if distanceInput.isEmpty {
                            distanceInput = originalDistance
                        } else if let floatValue = Float(distanceInput) {
                            let numberFormatter = NumberFormatter()
                            numberFormatter.minimumFractionDigits = 1
                            numberFormatter.maximumFractionDigits = 2
                            distanceInput = numberFormatter.string(from: NSNumber(value: floatValue)) ?? distanceInput
                        }
                    }
                    .onChange(of: distanceInput) {
                        validateAndSetInputFloat(&distanceInput, for: &setInput.distance, maxLength: 5, maxDecimals: 2)
                        if !distanceInput.isEmpty {
                            let newDistance = Float(distanceInput) ?? 0.0
                            if setInput.distance != newDistance {
                                setInput.distance = newDistance
                            }
                        }
                    }
                    .onAppear {
                        distanceInput = String(setInput.distance)
                        originalDistance = distanceInput
                    }
                    .keyboardType(.decimalPad)
                    .frame(width: 100, height: 20)
                Spacer()
            }
            
            Divider()
            
            if exerciseMeasurement == "Weight" {
                TextField("Weight", text: $weightInput)
                    .focused($focusedField, equals: .weight)
                    .onChange(of: focusedField) {
                        if focusedField == .weight {
                            focusManager.isAnyTextFieldFocused = true
                            focusManager.currentlyFocusedField = .weight
                            originalWeight = weightInput
                            weightInput = ""
                        } else if weightInput.isEmpty {
                            weightInput = originalWeight
                        } else if let weightValue = Float(weightInput) {
                            weightInput = String(format: "%.1f", weightValue)
                        }
                    }
                    .onChange(of: weightInput) {
                        validateAndSetInputFloat(&weightInput, for: &setInput.weight, maxLength: 5, maxDecimals: 2)
                    }
                    .onAppear {
                        weightInput = String(setInput.weight)
                        originalWeight = weightInput
                    }
                    .keyboardType(.decimalPad)
                    .frame(width: 100, height: 20)
            }
            
            if exerciseMeasurement == "Time" {
                TextField("Time", text: $timeInput)
                    .focused($focusedField, equals: .time)
                    .onChange(of: focusedField) {
                        if focusedField == .time {
                            focusManager.isAnyTextFieldFocused = true
                            focusManager.currentlyFocusedField = .time
                            originalTime = timeInput
                            timeInput = ""
                        } else if timeInput.isEmpty {
                            timeInput = originalTime
                        }
                    }
                    .onChange(of: timeInput) {
                        formatInput(timeInput)
                    }
                    .onAppear {
                        let formattedTime = formatTimeFromSeconds(totalSeconds: Int(setInput.time))
                        timeInput = "\(formattedTime)"
                        originalTime = timeInput
                    }
                    .keyboardType(.numberPad)
                    .frame(width: 100, height: 20)
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                if(focusedField == .time){
                    Button("Done") {
                        focusedField = nil
                        focusManager.isAnyTextFieldFocused = false
                        focusManager.currentlyFocusedField = nil
                    }
                }
                if(focusedField == .distance) {
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
    }
    
    private func formatInput(_ newValue: String) {
        let filtered = newValue.filter { "0123456789".contains($0) }
        let constrainedInput = String(filtered.suffix(6))
        let totalSeconds = convertToSeconds(constrainedInput)
        timeInput = formatToHHMMSS(totalSeconds)
        setInput.time = Int32(totalSeconds)
    }
    
}
