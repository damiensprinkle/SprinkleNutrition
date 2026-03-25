import SwiftUI
import MessageUI
import UIKit

struct ContactUsView: View {
    @Environment(\.dismiss) var dismiss

    @State private var mailParams: MailParams?
    @State private var showingMailUnavailableAlert = false
    @State private var includeLogs = true

    static let supportEmail = "SoleusApp@gmail.com"

    struct MailParams: Identifiable {
        let id = UUID()
        let subject: String
        let body: String
        let attachLogs: Bool
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    Button { openMail(type: .bug) } label: {
                        ContactRow(
                            icon: "ant.fill",
                            iconColor: .red,
                            title: "Report a Bug",
                            subtitle: "Something not working right?"
                        )
                    }
                    .accessibilityIdentifier(AccessibilityID.contactUsBugReportButton)

                    Button { openMail(type: .feature) } label: {
                        ContactRow(
                            icon: "lightbulb.fill",
                            iconColor: .yellow,
                            title: "Request a Feature",
                            subtitle: "Have an idea to improve Soleus?"
                        )
                    }
                    .accessibilityIdentifier(AccessibilityID.contactUsFeatureRequestButton)
                }

                Section(
                    header: Text("Bug Reports"),
                    footer: Text("App logs help us diagnose issues faster. They contain no personal data — only in-app events like workout saves and errors.")
                ) {
                    Toggle("Attach logs to bug reports", isOn: $includeLogs)
                        .tint(.green)
                        .accessibilityIdentifier(AccessibilityID.contactUsAttachLogsToggle)
                }

                Section(footer: Text("We typically respond within 48 hours.")) {
                    HStack(spacing: 10) {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.secondary)
                        Text(Self.supportEmail)
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Contact Us")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .sheet(item: $mailParams) { params in
            MailComposer(
                subject: params.subject,
                body: params.body,
                attachLogs: params.attachLogs,
                isPresented: Binding(
                    get: { mailParams != nil },
                    set: { if !$0 { mailParams = nil } }
                )
            )
        }
        .alert("Mail Not Available", isPresented: $showingMailUnavailableAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please set up a Mail account on your device, or email us directly at \(Self.supportEmail).")
        }
    }

    private enum ContactType { case bug, feature }

    private func openMail(type: ContactType) {
        guard MFMailComposeViewController.canSendMail() else {
            showingMailUnavailableAlert = true
            return
        }

        switch type {
        case .bug:
            mailParams = MailParams(subject: "Bug Report — Soleus", body: bugReportBody(), attachLogs: includeLogs)
        case .feature:
            mailParams = MailParams(subject: "Feature Request — Soleus", body: featureRequestBody(), attachLogs: false)
        }
    }

    private func bugReportBody() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        let device = UIDevice.current

        return """
        Describe the bug:


        Steps to reproduce:
        1.
        2.
        3.

        Expected behavior:


        Actual behavior:


        ---
        App Version: \(version) (\(build))
        iOS: \(device.systemVersion)
        Device: \(device.model)
        """
    }

    private func featureRequestBody() -> String {
        return """
        Feature description:


        Why would this be useful?


        Any additional context:

        """
    }
}

// MARK: - Row subview

private struct ContactRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(.primary)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
