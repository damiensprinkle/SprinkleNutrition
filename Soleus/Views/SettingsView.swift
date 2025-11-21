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
    
    @State private var showingPrivacyPolicy = false
    @State private var showingFAQ = false


    var body: some View {
        Form {
            Section(header: Text("Preferences")) {
                Picker("Weight Preference", selection: $weightPreference) {
                    Text("lbs").tag("lbs")
                    Text("kg").tag("kg")
                }

                Picker("Distance Preference", selection: $distancePreference) {
                    Text("mile").tag("mile")
                    Text("km").tag("km")
                }
            }

            Section(header: Text("About")) {
                Button(action: {
                    showingFAQ = true
                }) {
                    HStack {
                        Label("Help & FAQ", systemImage: "questionmark.circle.fill")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Button(action: {
                    showingPrivacyPolicy = true
                }) {
                    HStack {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .background(Color.myWhite)
        .listStyle(.insetGrouped)
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showingFAQ) {
            FAQView()
        }
    }
}
