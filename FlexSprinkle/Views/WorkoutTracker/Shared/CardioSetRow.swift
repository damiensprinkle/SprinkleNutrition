//
//  CardioSetRow.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/13/24.
//

import SwiftUI

import SwiftUI

struct CardioSetRow: View {
    let setIndex: Int
    @Binding var setInput: SetInput
    @State private var distanceInput: String = ""
    @State private var timeInput: String = ""
    @FocusState private var focusedField: FocusableField?

    
    // Simplified time selection
    @State private var selectedTimeIndex: Int = 0
    
    // Initialization
    init(setIndex: Int, setInput: Binding<SetInput>) {
        self.setIndex = setIndex
        self._setInput = setInput
        
        // Generate time options (e.g., every minute up to 1 hour for simplicity)
        var options: [String] = []
        for hour in 0..<2 { // Adjust range as needed
            for minute in 0..<60 {
                for second in stride(from: 0, to: 60, by: 30) { // Change stride for different granularity
                    let timeString = String(format: "%02d:%02d:%02d", hour, minute, second)
                    options.append(timeString)
                }
            }
        }
        
        // Calculate the default selected index based on setInput.time
        let totalSeconds = Int(setInput.wrappedValue.time)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = (totalSeconds % 60) / 30 * 30 // Assuming granularity adjustment
        if let defaultIndex = options.firstIndex(of: String(format: "%02d:%02d:%02d", hours, minutes, seconds)) {
            self._selectedTimeIndex = State(initialValue: defaultIndex)
        }
    }
    
    var body: some View {
        HStack {
            Text("\(setIndex)")
                .frame(width: 50, alignment: .leading)
            Spacer()
            Divider()
            TextField("Distance", text: $distanceInput)
                .focused($focusedField, equals: .distance)
                .onChange(of: focusedField) {
                    if focusedField == .distance {
                        distanceInput = "" // Clear the input when the field becomes focused
                    }
                    else{
                        if let floatValue = Float(distanceInput) {
                                // Use a NumberFormatter to convert the float value back to a string with at least one decimal place
                                let numberFormatter = NumberFormatter()
                                numberFormatter.minimumFractionDigits = 1 // Ensure at least one decimal place
                                numberFormatter.maximumFractionDigits = 2 // Adjust maximum digits as needed
                                distanceInput = numberFormatter.string(from: NSNumber(value: floatValue)) ?? distanceInput
                            }
                    }
                }
                .onChange(of: distanceInput) {
                    setInput.distance = Float(distanceInput) ?? 0.0
                }
                .onAppear {
                    distanceInput = String(setInput.distance) // Initialize the input when the view appears
                }
                .keyboardType(.decimalPad)
                .frame(width: 100) // Fixed width for distance input
            Spacer()
            Divider()
            TextField("Time", text: $timeInput)
                .focused($focusedField, equals: .time)
                .onChange(of: focusedField) {
                    if focusedField == .time {
                        timeInput = "" // Clear the input when the field becomes focused
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
                .frame(width: 100) // Fixed width for distance input
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
            }
        }
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
    
    private func formatToHHMMSS(_ totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
}
