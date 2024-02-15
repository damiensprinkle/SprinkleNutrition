//
//  SettingsView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/3/24.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("weightPreference") private var weightPreference: String = "lbs"
    @AppStorage("distancePreference") private var distancePreference: String = "mile"
    
    var body: some View {
        Divider()
        
        NavigationView {
            Form {
                Picker("Weight Preference", selection: $weightPreference) {
                    Text("lbs").tag("lbs")
                    Text("kg").tag("kg")
                }
                Picker("Distance Preference", selection: $distancePreference) {
                    Text("mile").tag("mile")
                    Text("km").tag("km")
                }
            }
        }
    }
}
