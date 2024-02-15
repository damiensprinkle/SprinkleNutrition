//
//  SettingsView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/3/24.
//

import SwiftUI

struct SettingsView: View {
    @State private var weightPreference = false
    @State private var distancePreference = false

    @State private var optionTwo = false
    @State private var optionThree = false
    var body: some View {
        Divider()
        
        NavigationView {
            Form {
                Picker("Weight Preference", selection: $weightPreference) {
                    Text("Lbs").tag("Lbs")
                    Text("KG").tag("KG")
                }
                Picker("Distance Preference", selection: $distancePreference) {
                    Text("Mile").tag("Mile")
                    Text("KM").tag("KM")
                }            }
        }
    }
}
