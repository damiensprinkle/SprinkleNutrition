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

    var body: some View {
        VStack {
            Text("Rename Exercise")
                .font(.headline)
            TextField("Exercise Name", text: $exerciseName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            HStack {
                Button("OK") {
                    onRename(exerciseName)
                    isPresented = false
                }
                .padding()
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.myWhite)
        .cornerRadius(15)
        .shadow(radius: 10)
        .frame(width: 300) // Adjust the width as necessary
    }
}
