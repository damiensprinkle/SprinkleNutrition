import SwiftUI

struct SettingsView: View {
    @AppStorage("weightPreference") private var weightPreference: String = "lbs"
    @AppStorage("distancePreference") private var distancePreference: String = "mile"
    @AppStorage("defaultRestDuration") private var defaultRestDuration: Int = 90
    @AppStorage("autoStartRestTimer") private var autoStartRestTimer: Bool = true

    @State private var showingPrivacyPolicy = false
    @State private var showingFAQ = false
    @State private var showingDevMenu = false
    @State private var devMenuTapCount = 0

    private let restDurationOptions = [30, 45, 60, 90, 120, 180, 240, 300]

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

            Section(header: Text("Rest Timer")) {
                Toggle("Auto-start rest timer", isOn: $autoStartRestTimer)
                    .tint(.green)

                if autoStartRestTimer {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Default rest duration")
                            .font(.subheadline)
                            .foregroundColor(.primary)

                        // Full picker for all options
                        Picker("", selection: $defaultRestDuration) {
                            ForEach(restDurationOptions, id: \.self) { seconds in
                                Text(formatRestDuration(seconds)).tag(seconds)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }
                    .padding(.vertical, 4)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "info.circle")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("How it works")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    Text("Rest timer automatically starts when you complete a set. Adjust time with +/-30s buttons or skip entirely.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
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

                // Secret dev menu trigger (invisible)
                Color.clear
                    .frame(height: 10)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        devMenuTapCount += 1
                        if devMenuTapCount >= 5 {
                            showingDevMenu = true
                            devMenuTapCount = 0
                        }
                        // Reset counter after 3 seconds of no taps
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            devMenuTapCount = 0
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
        .sheet(isPresented: $showingDevMenu) {
            DevMenuView()
        }
    }

    private func formatRestDuration(_ seconds: Int) -> String {
        if seconds >= 60 {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            if remainingSeconds > 0 {
                return "\(minutes)m \(remainingSeconds)s"
            } else {
                return "\(minutes) minute\(minutes == 1 ? "" : "s")"
            }
        } else {
            return "\(seconds) seconds"
        }
    }

    private func formatRestDurationShort(_ seconds: Int) -> String {
        if seconds >= 60 {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            if remainingSeconds > 0 {
                return "\(minutes):\(String(format: "%02d", remainingSeconds))"
            } else {
                return "\(minutes)min"
            }
        } else {
            return "\(seconds)s"
        }
    }
}
