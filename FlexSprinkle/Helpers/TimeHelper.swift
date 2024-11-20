//
//  SwiftUIView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/15/24.
//

import SwiftUI

func formatTimeFromSeconds(totalSeconds: Int) -> String {
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}

func formatToHHMMSS(_ totalSeconds: Int) -> String {
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}

func convertToSeconds(_ input: String) -> Int {
    let paddedInput = input.padding(toLength: 6, withPad: "0", startingAt: 0)
    let hours = Int(paddedInput.prefix(2)) ?? 0
    let minutes = Int(paddedInput.dropFirst(2).prefix(2)) ?? 0
    let seconds = Int(paddedInput.suffix(2)) ?? 0
    return hours * 3600 + minutes * 60 + seconds
}
