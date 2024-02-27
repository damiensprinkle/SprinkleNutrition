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
    @State private var repsInput: String = ""
    @State private var weightInput: String = ""
    @FocusState private var focusedField: FocusableField?

    
    var body: some View {
        HStack {
            Text("\(setIndex)")
                .frame(width: 50, alignment: .leading) // Fixed width for set number
            Spacer()
            Divider()
            TextField("Reps", text: $repsInput)
                .focused($focusedField, equals: .reps)
                .onChange(of: focusedField) {
                    if focusedField == .reps {
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
                .focused($focusedField, equals: .weight)
                .onChange(of: focusedField) {
                    if focusedField == .weight {
                        weightInput = "" // Clear the input when the field becomes focused
                    }
                }
                .onChange(of: weightInput) {
                    setInput.weight = Float(weightInput) ?? 0
                }
            
                .onAppear {
                    weightInput = String(setInput.weight) // Initialize the input when the view appears
                }
                .keyboardType(.decimalPad)
                .frame(width: 100) // Fixed width for weight input

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
    }
}
