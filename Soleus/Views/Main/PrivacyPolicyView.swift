import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Privacy Matters")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Last updated: November 2025")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // No Data Collection
                    PrivacySection(
                        icon: "lock.shield.fill",
                        iconColor: .green,
                        title: "No Data Collection",
                        description: "Soleus doesn't collect, store, or transmit any of your personal information. All your workout data stays on your device."
                    )

                    // No Tracking
                    PrivacySection(
                        icon: "eye.slash.fill",
                        iconColor: .blue,
                        title: "No Tracking",
                        description: "We don't track your activity, location, or behavior. Your workouts are private and belong to you alone."
                    )

                    // No Ads
                    PrivacySection(
                        icon: "rectangle.slash.fill",
                        iconColor: .orange,
                        title: "No Advertisements",
                        description: "Soleus is completely ad-free. No third-party advertisers, no analytics services, no interruptions."
                    )

                    // Offline First
                    PrivacySection(
                        icon: "airplane",
                        iconColor: .purple,
                        title: "Works Offline",
                        description: "All features work completely offline. No internet connection required, no cloud services, no external servers."
                    )

                    // Your Data
                    PrivacySection(
                        icon: "externaldrive.fill",
                        iconColor: .myBlue,
                        title: "Your Data, Your Control",
                        description: "Your workout history, achievements, and settings are stored locally on your device. You have complete control over your data."
                    )

                    Divider()

                    // Footer
                    VStack(spacing: 12) {
                        Text("Simple Privacy")
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text("We built Soleus to be a simple, private workout tracker. No accounts, no sign-ups, no cloud syncing. Just you and your workouts.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)

                    Spacer()
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PrivacySection: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
