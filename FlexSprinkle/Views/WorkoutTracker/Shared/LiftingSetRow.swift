//
//  LiftingSetRow.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/13/24.
//

import SwiftUI

struct LiftingSetRow: View {
    let setIndex: Int
    @Binding var setInput: SetInput
    @FocusState private var repsFieldFocused: Bool
    @FocusState private var weightFieldFocused: Bool
    @State private var repsInput: String = ""
    @State private var weightInput: String = ""
    
    var body: some View {
        HStack {
            Text("\(setIndex)")
                .frame(width: 50, alignment: .leading) // Fixed width for set number
            Spacer()
            Divider()
            TextField("Reps", text: $repsInput)
                .focused($repsFieldFocused)
                .onChange(of: repsFieldFocused) {
                    if repsFieldFocused {
                        repsInput = "" // Clear the input when the field becomes focused
                    }
                }
                .onChange(of: repsInput) {
                    setInput.reps = Int32(repsInput) ?? 0
                }
                .onAppear {
                    repsInput = String(setInput.reps) // Initialize the input when the view appears
                }
                .keyboardType(.numberPad)
                .frame(width: 100) // Fixed width for reps input
            Spacer()
            Divider()
            TextField("Weight", text: $weightInput)
                .focused($weightFieldFocused)
                .onChange(of: weightFieldFocused) {
                    if weightFieldFocused {
                        weightInput = "" // Clear the input when the field becomes focused
                    }
                }
                .onChange(of: weightInput) {
                    setInput.weight = Int32(weightInput) ?? 0
                }
            
                .onAppear {
                    weightInput = String(setInput.weight) // Initialize the input when the view appears
                }
                .keyboardType(.numberPad)
                .frame(width: 100) // Fixed width for weight input
        }
    }
}
