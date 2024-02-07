//
//  WorkoutDetailView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/5/24.
//

import SwiftUI

struct WorkoutDetailView: View {
    @Binding var detail: WorkoutDetailInput

    var body: some View {
        HStack {
            // Exercise Name TextField - larger and more prominent
            TextField("Exercise Name", text: $detail.exerciseName)
                .disableAutocorrection(true)
                .frame(minWidth: 0, maxWidth: .infinity) // Makes this field take up the most space

            // Reps TextField - limited input and smaller
            TextField("Reps", text: Binding(
                get: { detail.reps },
                set: { newValue in
                    if newValue.count <= 3, newValue.allSatisfy(\.isNumber) {
                        detail.reps = newValue
                    } else if newValue.count > 3 {
                        detail.reps = String(newValue.prefix(3))
                    }
                }
            ))
            .keyboardType(.numberPad)
            .frame(width: 60) // Fixed smaller width
            .multilineTextAlignment(.center)
            .border(Color.gray, width: /* desired border width */ 0.5)

            // Weight TextField - limited input and smaller
            TextField("Weight", text: Binding(
                get: { detail.weight },
                set: { newValue in
                    if newValue.count <= 3, newValue.allSatisfy(\.isNumber) {
                        detail.weight = newValue
                    } else if newValue.count > 3 {
                        detail.weight = String(newValue.prefix(3))
                    }
                }
            ))
            .keyboardType(.numberPad)
            .frame(width: 60) // Fixed smaller width
            .multilineTextAlignment(.center)
            .border(Color.gray, width: /* desired border width */ 0.5)
        }
    }
}





