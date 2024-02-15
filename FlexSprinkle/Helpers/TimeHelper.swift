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

func totalSecondsFromFormattedTime(formattedTime: String) -> Int {
    let components = formattedTime.split(separator: ":").map { Int($0) ?? 0 }
    let hours = components.count > 2 ? components[0] : 0
    let minutes = components.count > 1 ? components[components.count - 2] : 0
    let seconds = components.last ?? 0
    return hours * 3600 + minutes * 60 + seconds
}
