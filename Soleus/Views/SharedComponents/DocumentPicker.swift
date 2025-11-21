//
//  DocumentPicker.swift
//  FlexSprinkle
//
//  Created by Claude Code
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var importedWorkout: ShareableWorkout?
    @Binding var showImportPreview: Bool

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType(filenameExtension: "flexsprinkle")!])
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No update needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }

            guard url.startAccessingSecurityScopedResource() else {
                print("Failed to access security-scoped resource")
                return
            }

            defer {
                url.stopAccessingSecurityScopedResource()
            }

            do {
                let data = try Data(contentsOf: url)
                if let workout = ShareableWorkout.import(from: data) {
                    DispatchQueue.main.async {
                        self.parent.importedWorkout = workout
                        // Don't set showImportPreview here - let the sheet's onDismiss handle it
                    }
                }
            } catch {
                print("Error reading file: \(error.localizedDescription)")
            }
        }
    }
}
