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
    
    // State to manage the presentation of UserDetailsFormView
    @State private var showingUserDetailsForm = false
    @State private var showingPrivacyPolicy = false
    @State private var showingFAQ = false
    @EnvironmentObject var userManager: UserManager


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
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showingFAQ) {
            FAQView()
        }
    }
}
