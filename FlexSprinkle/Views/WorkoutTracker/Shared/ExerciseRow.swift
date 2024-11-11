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
    @State private var weightInput: String = ""
    @State private var distanceInput: String = ""
    @State private var timeInput: String = ""
    @FocusState private var focusedField: FocusableField?

    @AppStorage("weightPreference") private var weightPreference: String = "Lbs"
    @AppStorage("distancePreference") private var distancePreference: String = "Mile"

    var exerciseQuantifier: String
    var exerciseMeasurement: String

    var body: some View {
        HStack {
            Text("\(setIndex)")
                .frame(width: 50, alignment: .leading)
            Spacer()
            Divider()

            if exerciseQuantifier == "Reps" {
                TextField("Reps", text: $repsInput)
                    .focused($focusedField, equals: .reps)
                    .onChange(of: focusedField) {
                        if focusedField == .reps {
                            repsInput = ""
                        }
                    }
                    .onChange(of: repsInput) {
                        setInput.reps = Int32(repsInput) ?? 0
                    }
                    .onAppear {
                        repsInput = String(setInput.reps)
                    }
                    .keyboardType(.numberPad)
                    .frame(width: 100)
            }

            if exerciseQuantifier == "Distance" {
                TextField("Distance", text: $distanceInput)
                    .focused($focusedField, equals: .distance)
                    .onChange(of: focusedField) {
                        if focusedField == .distance {
                            distanceInput = ""
                        }
                        else{
                            if let floatValue = Float(distanceInput) {
                                    let numberFormatter = NumberFormatter()
                                    numberFormatter.minimumFractionDigits = 1
                                    numberFormatter.maximumFractionDigits = 2
                                    distanceInput = numberFormatter.string(from: NSNumber(value: floatValue)) ?? distanceInput
                                }
                        }
                    }
                    .onChange(of: distanceInput) {
                        setInput.distance = Float(distanceInput) ?? 0.0
                    }
                    .onAppear {
                        distanceInput = String(setInput.distance)
                    }
                    .keyboardType(.decimalPad)
                    .frame(width: 100)
                Spacer()
            }

            Divider()

            if exerciseMeasurement == "Weight" {
                TextField("Weight", text: $weightInput)
                    .focused($focusedField, equals: .weight)
                    .onChange(of: focusedField) {
                        if focusedField != .weight {
                            if let weightValue = Float(weightInput) {
                                weightInput = String(format: "%.1f", weightValue)
                            }
                        } else {
                            weightInput = ""
                        }
                    }
                    .onChange(of: weightInput) {
                        setInput.weight = Float(weightInput) ?? 0.0
                    }
                
                    .onAppear {
                        weightInput = String(setInput.weight)
                    }
                    .keyboardType(.decimalPad)
                    .frame(width: 100)
            }

            if exerciseMeasurement == "Time" {
                TextField("Time", text: $timeInput)
                    .focused($focusedField, equals: .time)
                    .onChange(of: focusedField) {
                        if focusedField == .time {
                            timeInput = ""
                        }
                    }
                    .onChange(of: timeInput) {
                        formatInput(timeInput)
                        
                    }
                    .onAppear {
                        let formattedTime = formatTimeFromSeconds(totalSeconds: Int(setInput.time))
                        timeInput = "\(formattedTime)"
                    }
                    .keyboardType(.numberPad)
                    .frame(width: 100)
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                if(focusedField == .time){
                    Button("Done") {
                        focusedField = nil
                    }
                }
                if(focusedField == .distance) {
                    Button("Done") {
                        focusedField = nil
                    }
                }
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
    
    private func formatInput(_ newValue: String) {
        let filtered = newValue.filter { "0123456789".contains($0) }
        let constrainedInput = String(filtered.suffix(6))
        let totalSeconds = convertToSeconds(constrainedInput)
        timeInput = formatToHHMMSS(totalSeconds)
        setInput.time = Int32(totalSeconds)
    }
    
}
