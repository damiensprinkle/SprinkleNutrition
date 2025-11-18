//
//  ExerciseNotesDialogView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 11/18/24.
//

import SwiftUI

struct ExerciseNotesDialogView: View {
    @Binding var isPresented: Bool
    @Binding var exerciseNotes: String?

    @State private var temporaryNotes: String

    init(isPresented: Binding<Bool>, exerciseNotes: Binding<String?>) {
        self._isPresented = isPresented
        self._exerciseNotes = exerciseNotes
        self._temporaryNotes = State(initialValue: exerciseNotes.wrappedValue ?? "")
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Exercise Notes")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.myBlack)
                Text("Add notes or instructions for this exercise")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 24)
            .padding(.bottom, 20)

            // Form Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.myBlack)

                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(UIColor.systemBackground))
                        .frame(height: 140)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )

                    TextEditor(text: $temporaryNotes)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .frame(height: 140)
                        .scrollContentBackground(.hidden)
                }
                .frame(height: 140)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)

            // Buttons
            HStack(spacing: 12) {
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.myBlack)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.myGrey.opacity(0.2))
                        .cornerRadius(8)
                }

                Button(action: {
                    exerciseNotes = temporaryNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : temporaryNotes
                    isPresented = false
                }) {
                    Text("Save")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.staticWhite)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.myBlue)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.myWhite)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        .frame(width: 340)
    }
}
