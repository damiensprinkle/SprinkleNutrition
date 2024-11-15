//
//  ValidatedTextField.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 11/13/24.
//

import SwiftUI

enum InputType: Equatable {
    case integer, float(maxDecimals: Int)
}

struct ValidatedTextField: View {
    let placeholder: String
    @Binding var text: String
    let inputType: InputType
    let maxLength: Int
    @FocusState private var isFocused: Bool
    let onCommit: (() -> Void)?

    init(
        placeholder: String,
        text: Binding<String>,
        inputType: InputType,
        maxLength: Int = 10,
        onCommit: (() -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.inputType = inputType
        self.maxLength = maxLength
        self.onCommit = onCommit
    }

    var body: some View {
        TextField(placeholder, text: $text)
            .focused($isFocused)
            .onChange(of: isFocused) {
                if !isFocused {
                    applyFormatting()
                } else {
                    text = "" // Clear on focus if needed
                }
            }
            .onChange(of: text) {
                validateInput()
            }
            .onSubmit {
                onCommit?()
            }
            .keyboardType(inputType == .integer ? .numberPad : .decimalPad)
            .frame(width: 100)
    }

    private func validateInput() {
        // Limit length
        if text.count > maxLength {
            text = String(text.prefix(maxLength))
        }
        
        // Apply validation based on input type
        switch inputType {
        case .integer:
            text = text.filter { "0123456789".contains($0) }
        case .float(let maxDecimals):
            let decimalPattern = "^[0-9]{0,\(maxLength)}(?:\\.[0-9]{0,\(maxDecimals)})?$"
            let regex = try! NSRegularExpression(pattern: decimalPattern)
            let range = NSRange(location: 0, length: text.utf16.count)
            if regex.firstMatch(in: text, options: [], range: range) == nil {
                text = String(text.dropLast()) // Revert to previous valid input
            }
        }
    }

    private func applyFormatting() {
        // Apply any final formatting if needed (e.g., float formatting with fixed decimal places)
        if case .float(let maxDecimals) = inputType, let floatValue = Float(text) {
            text = String(format: "%.\(maxDecimals)f", floatValue)
        }
    }
}
