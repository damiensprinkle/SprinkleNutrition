import SwiftUI
import MessageUI

struct MailComposer: UIViewControllerRepresentable {
    let subject: String
    let body: String
    let attachLogs: Bool
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients([ContactUsView.supportEmail])
        composer.setSubject(subject)
        composer.setMessageBody(body, isHTML: false)

        if attachLogs {
            let logText = LogCapture.shared.logs.map { entry in
                "[\(entry.formattedTime)] [\(entry.level.rawValue)] [\(entry.category)] \(entry.message)"
            }.joined(separator: "\n")

            if let data = logText.data(using: .utf8) {
                composer.addAttachmentData(data, mimeType: "text/plain", fileName: "soleus-logs.txt")
            }
        }

        return composer
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposer

        init(_ parent: MailComposer) { self.parent = parent }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            parent.isPresented = false
        }
    }
}
