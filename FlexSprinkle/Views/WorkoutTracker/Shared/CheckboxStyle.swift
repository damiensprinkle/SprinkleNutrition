//
//  CheckboxStyle.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/22/24.
//

import SwiftUI

struct CheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle() // Toggle the state
        }) {
            HStack {
                if configuration.isOn {
                    Image(systemName: "checkmark.square.fill") // Checked state
                        .foregroundColor(.blue) // Customize color
                } else {
                    Image(systemName: "square") // Unchecked state
                        .foregroundColor(.gray) // Customize color
                }
                configuration.label
            }
        }
        .buttonStyle(PlainButtonStyle()) // Use plain button to avoid any unwanted styling
    }
}
