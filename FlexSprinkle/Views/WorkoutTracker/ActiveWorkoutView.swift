//
//  ActiveWorkout.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/5/24.
//

import SwiftUI

struct ActiveWorkoutView: View {
    var workoutDetails: [WorkoutDetail]
    @EnvironmentObject var workoutManager: WorkoutManager

    var body: some View {
        let workout = workoutManager.fetchWorkoutDetails(for: workoutDetails.first!.name)
        VStack {
            Text("Active Workout")
                .font(.title)

            List(workout, id: \.self) { detail in
                VStack(alignment: .leading) {
                    Text("Exercise: \(detail.exerciseName)")
                    Text("Reps: \(detail.reps)")
                    Text("Weight: \(detail.weight)")
                }
            }

        }
        .padding()
    }
}




