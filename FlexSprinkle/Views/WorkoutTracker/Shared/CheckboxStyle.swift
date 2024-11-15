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
            configuration.isOn.toggle()
        }) {
            HStack {
                if configuration.isOn {
                    Image(systemName: "checkmark.square.fill")
                        .foregroundColor(.blue)
                } else {
                    Image(systemName: "square")
                        .foregroundColor(.gray)
                }
                configuration.label
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
