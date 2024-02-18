//
//  CardioSetRow.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/13/24.
//

import SwiftUI

import SwiftUI

struct CardioSetRow: View {
    @AppStorage("distancePreference") private var distancePreference: String = "Mile"
    let setIndex: Int
    @Binding var setInput: SetInput
    @State private var distanceInput: String = ""
    @FocusState private var distanceFieldFocused: Bool
    @State private var timeInput: String = ""
    @FocusState private var timeFieldFocused: Bool
    
    // Simplified time selection
    @State private var selectedTimeIndex: Int = 0
    let timeOptions: [String]
    
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
        self.timeOptions = options
        
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
                .focused($distanceFieldFocused)
                .onChange(of: distanceFieldFocused) {
                    if distanceFieldFocused {
                        distanceInput = "" // Clear the input when the field becomes focused
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
                .addDoneButton() // Add the done button to this TextField
            
            Spacer()
            Divider()
            TextField("Time", text: $timeInput)
                .focused($timeFieldFocused)
                .onChange(of: timeFieldFocused) {
                    if timeFieldFocused {
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
                .addDoneButton() // Add the done button to this TextField
        }
    }
    private func onChange() {
        let selectedTime = self.timeOptions[selectedTimeIndex]
        let components = selectedTime.split(separator: ":").compactMap { Int($0) }
        if components.count == 3 {
            let hours = components[0]
            let minutes = components[1]
            let seconds = components[2]
            let totalSeconds = hours * 3600 + minutes * 60 + seconds
            setInput.time = Int32(totalSeconds)
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

// Include the extension for adding a Done button to the keyboard


extension View {
    func addDoneButton() -> some View {
        self.toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer() // Use Spacer to push the button to the right
                Button("Done") {
                    // Hide the keyboard
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
    }
}
