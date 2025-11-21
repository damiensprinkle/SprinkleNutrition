//
//  RenameExerciseDialog.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/18/24.
//

import SwiftUI

struct RenameExerciseDialogView: View {
    @Binding var isPresented: Bool
    @Binding var exerciseName: String
    var onRename: (String) -> Void

    @State private var temporaryName: String

    init(isPresented: Binding<Bool>, exerciseName: Binding<String>, onRename: @escaping (String) -> Void) {
        self._isPresented = isPresented
        self._exerciseName = exerciseName
        self.onRename = onRename
        self._temporaryName = State(initialValue: exerciseName.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Rename Exercise")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.myBlack)
                Text("Update the exercise name")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 24)
            .padding(.bottom, 20)

            // Form Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Exercise Name")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.myBlack)

                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(UIColor.systemBackground))
                        .frame(height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )

                    TextField("Enter exercise name", text: $temporaryName)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                }
                .frame(height: 44)
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
                    onRename(temporaryName)
                    isPresented = false
                }) {
                    Text("Save")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.staticWhite)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(temporaryName.isEmpty ? Color.myBlue.opacity(0.5) : Color.myBlue)
                        .cornerRadius(8)
                }
                .disabled(temporaryName.isEmpty)
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
