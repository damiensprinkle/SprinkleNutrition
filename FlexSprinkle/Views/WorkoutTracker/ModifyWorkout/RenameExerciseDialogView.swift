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
        VStack(spacing: 15) {
            Text("Rename Exercise")
                .font(.headline)
            
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(UIColor.systemBackground))
                    .frame(height: 36)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                
                TextField("Exercise Name", text: $temporaryName)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
            }
            .frame(height: 36)
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .frame(maxWidth: .infinity)
                .padding()
                Spacer()
                Button("OK") {
                    onRename(temporaryName)
                    isPresented = false
                }
                .disabled(temporaryName.isEmpty)
                .opacity(temporaryName.isEmpty ? 0.5 : 1.0)
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
        .padding()
        .background(Color.myWhite)
        .cornerRadius(15)
        .shadow(radius: 10)
        .frame(width: 300)
    }
}
