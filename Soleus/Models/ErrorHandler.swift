//
//  ErrorHandler.swift
//  FlexSprinkle
//
//  Created by Claude Code
//

import Foundation
import SwiftUI

/// Centralized error handling for the app
class ErrorHandler: ObservableObject {
    @Published var currentError: CoreDataError?
    @Published var showError: Bool = false

    func handle(_ error: CoreDataError) {
        DispatchQueue.main.async {
            self.currentError = error
            self.showError = true
        }
    }

    func clearError() {
        currentError = nil
        showError = false
    }
}

/// Alert view modifier to display errors
struct ErrorAlert: ViewModifier {
    @ObservedObject var errorHandler: ErrorHandler

    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: $errorHandler.showError) {
                Button("OK") {
                    errorHandler.clearError()
                }
            } message: {
                if let error = errorHandler.currentError {
                    VStack(alignment: .leading) {
                        Text(error.errorDescription ?? "An error occurred")
                        if let suggestion = error.recoverySuggestion {
                            Text(suggestion)
                                .font(.caption)
                        }
                    }
                }
            }
    }
}

extension View {
    func errorAlert(_ errorHandler: ErrorHandler) -> some View {
        modifier(ErrorAlert(errorHandler: errorHandler))
    }
}
