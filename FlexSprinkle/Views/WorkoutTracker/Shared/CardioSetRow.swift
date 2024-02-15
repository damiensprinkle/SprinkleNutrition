//
//  CardioSetRow.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/13/24.
//

import SwiftUI

struct CardioSetRow: View {
    let setIndex: Int
    @Binding var setInput: SetInput
    @FocusState private var distanceFieldFocused: Bool
    @FocusState private var timeFieldFocused: Bool
    @State private var distanceInput: String = ""
    @State private var timeInput: String = ""

    var body: some View {
        HStack {
            Text("\(setIndex)")
                .frame(width: 50, alignment: .leading) // Fixed width for set number
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
                    setInput.distance = Int32(distanceInput) ?? 0
                }
                .onAppear {
                    distanceInput = String(setInput.distance) // Initialize the input when the view appears
                }
                .keyboardType(.numberPad)
                .frame(width: 100) // Fixed width for distance input
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
                    setInput.time = Int32(timeInput) ?? 0
                }
                .onAppear {
                    timeInput = String(setInput.time) // Initialize the input when the view appears
                }
                .keyboardType(.numberPad)
                .frame(width: 100) // Fixed width for time input
        }
    }
}
