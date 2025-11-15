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
    @AppStorage("userHeightPreference") private var userHeightPreference: String = "inches"
    
    // State to manage the presentation of UserDetailsFormView
    @State private var showingUserDetailsForm = false
    @EnvironmentObject var userManager: UserManager

    
    var body: some View {
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
                Picker("Height Preference", selection: $userHeightPreference) {
                    Text("inches").tag("inches")
                    Text("cm").tag("cm")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.myWhite)
            .navigationBarTitle("Settings")
            .toolbar {
                // Person icon button to show UserDetailsFormView
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingUserDetailsForm = true
                    }) {
                        Image(systemName: "person.fill")
                    }
                }
            }
            .sheet(isPresented: $showingUserDetailsForm) {
                UserDetailsFormView(isPresented: $showingUserDetailsForm)
                    .environmentObject(userManager)
            }
        }
    }
}
