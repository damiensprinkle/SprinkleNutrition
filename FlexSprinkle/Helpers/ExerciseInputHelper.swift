//
//  ExerciseInputHelper.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 11/15/24.
//
import SwiftUI


func validateAndSetInputFloat(_ input: inout String, for setInputField: inout Float, maxLength: Int = 10, maxDecimals: Int = 2) {
    if input.count > maxLength {
        input = String(input.prefix(maxLength))
    }

    let decimalPattern = "^[0-9]{0,\(maxLength)}(?:\\.[0-9]{0,\(maxDecimals)})?$"
    guard let regex = try? NSRegularExpression(pattern: decimalPattern) else {
        print("Error: Failed to create regex with pattern: \(decimalPattern)")
        setInputField = Float(input) ?? 0.0
        return
    }
    let range = NSRange(location: 0, length: input.utf16.count)

    if regex.firstMatch(in: input, options: [], range: range) == nil {
        input = String(input.dropLast())
    }

    setInputField = Float(input) ?? 0.0
}

func validateAndSetInputInt(_ input: inout String, for setInputField: inout Int32, maxLength: Int = 10) {
    if input.count > maxLength {
        input = String(input.prefix(maxLength))
    }

    let integerPattern = "^[0-9]{0,\(maxLength)}$"
    guard let regex = try? NSRegularExpression(pattern: integerPattern) else {
        print("Error: Failed to create regex with pattern: \(integerPattern)")
        setInputField = Int32(input) ?? 0
        return
    }
    let range = NSRange(location: 0, length: input.utf16.count)

    if regex.firstMatch(in: input, options: [], range: range) == nil {
        input = String(input.dropLast())
    }

    setInputField = Int32(input) ?? 0
}
