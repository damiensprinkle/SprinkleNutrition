//
//  WorkoutDetailView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/5/24.
//

import SwiftUI

import SwiftUI

struct WorkoutDetailView: View {
    @Binding var detail: WorkoutDetailInput

    var body: some View {
        VStack {
            // Input Fields
            HStack {
                TextField("Exercise Name", text: $detail.exerciseName)
                    .disableAutocorrection(true)
                    .frame(minWidth: 0, maxWidth: .infinity)
                
                Divider() // Visually separate fields
                
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
                .frame(width: 60)
                .multilineTextAlignment(.center)
                
                Divider() // Visually separate fields
                
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
                .frame(width: 60)
                .multilineTextAlignment(.center)
            }
        }
    }
}
