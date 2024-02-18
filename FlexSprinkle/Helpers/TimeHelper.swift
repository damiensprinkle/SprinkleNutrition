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
