//
//  WorkoutDetailView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/5/24.
//

import SwiftUI

struct WorkoutDetailView: View {
    @Binding var detail: WorkoutDetail

    var body: some View {
        HStack {
            TextField("Name", text: $detail.name)
            Spacer() // Add a spacer to distribute space evenly

            TextField("Reps", text: $detail.reps)
                .keyboardType(.numberPad) // Allow only numeric input for "Reps"

            TextField("Weight", text: $detail.weight)
                .keyboardType(.numberPad) // Allow only numeric input for "Weight"
        }


    }
}

