import SwiftUI
import HealthKit

struct HealthKitSettingsView: View {
    @EnvironmentObject private var healthKitManager: HealthKitManager

    @AppStorage("healthKitEnabled") private var healthKitEnabled: Bool = false

    @State private var showDeniedAlert = false

    var body: some View {
        Form {
            Section(
                footer: Text("When enabled, Soleus writes your completed workouts to Apple Health so they appear in the Fitness app and Activity rings. You will be prompted to grant permission the first time you turn this on.")
            ) {
                Toggle(isOn: Binding(
                    get: { healthKitEnabled },
                    set: { newValue in
                        if newValue {
                            requestOrEnable()
                        } else {
                            healthKitEnabled = false
                        }
                    }
                )) {
                    Text("Sync Workouts to Apple Health")
                }
                .tint(.green)
                .accessibilityIdentifier(AccessibilityID.healthKitToggle)
            }

            if healthKitEnabled {
                Section {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Connected to Apple Health")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .onAppear {
            if !healthKitManager.isAvailable {
                healthKitEnabled = false
            }
        }
        .alert("Apple Health Access Denied", isPresented: $showDeniedAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Health access is disabled for Soleus. Go to iOS Settings → Health → Data Access & Devices → Soleus to enable it.")
        }
    }

    // MARK: - Helpers

    private func requestOrEnable() {
        guard healthKitManager.isAvailable else {
            healthKitEnabled = false
            return
        }

        let status = healthKitManager.currentAuthorizationStatus()
        switch status {
        case .sharingAuthorized:
            healthKitEnabled = true
        case .notDetermined:
            healthKitManager.requestAuthorization { granted in
                if granted {
                    healthKitEnabled = true
                } else {
                    healthKitEnabled = false
                    showDeniedAlert = true
                }
            }
        case .sharingDenied:
            healthKitEnabled = false
            showDeniedAlert = true
        @unknown default:
            healthKitEnabled = false
        }
    }
}
