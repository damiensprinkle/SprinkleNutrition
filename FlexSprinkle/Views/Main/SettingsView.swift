//
//  SettingsView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/3/24.
//

import SwiftUI

struct SettingsView: View {
    @State private var optionOne = false
        @State private var optionTwo = false
        @State private var optionThree = false
    var body: some View {
        Divider()

        NavigationView {
                  Form {
                      Toggle("Option One", isOn: $optionOne)
                      Toggle("Option Two", isOn: $optionTwo)
                      Toggle("Option Three", isOn: $optionThree)
                  }
              }
    }
}
