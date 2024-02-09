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
            TextField("Exercise Name", text: $detail.exerciseName)
                .disableAutocorrection(true)
                .frame(minWidth: 0, maxWidth: .infinity)
            Divider() // Visually separate fields
            
            
            if detail.isCardio {
                TextField("Time/Description", text: $detail.exerciseTime)
                    .keyboardType(.numberPad)
                    .frame(width: 135)
            } else {
                TextField("Reps", text: $detail.reps)
                    .keyboardType(.numberPad)
                    .frame(width: 60)
                Divider() // Visually separate fields
                
                
                TextField("Weight", text: $detail.weight)
                    .keyboardType(.numberPad)
                    .frame(width: 60)
            }
        }
        .padding(.vertical, 4)
    }
}
