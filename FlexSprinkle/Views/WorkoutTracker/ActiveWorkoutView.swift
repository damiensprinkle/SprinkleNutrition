//
//  ActiveWorkout.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/5/24.
//

import SwiftUI

struct ActiveWorkoutView: View {
    var workoutDetails: [WorkoutDetail]

    var body: some View {
        VStack {
            Text("Active Workout")
                .font(.title)

            List(workoutDetails) { detail in
                VStack(alignment: .leading) {
                    Text("Exercise: \(detail.name)")
                    Text("Reps: \(detail.reps)")
                    Text("Weight: \(detail.weight)")
                }
            }
        }
        .padding()
    }
}




