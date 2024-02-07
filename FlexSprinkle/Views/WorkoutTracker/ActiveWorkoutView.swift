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
    @State private var userInputs: [UUID: (reps: String, weight: String)] = [:]

    init(workoutDetails: [WorkoutDetail]) {
        self.workoutDetails = workoutDetails
        // Initialize userInputs with empty strings to allow direct input
        _userInputs = State(initialValue: workoutDetails.reduce(into: [:]) { result, detail in
            result[detail.id] = ("", "") // Placeholder will be shown instead
        })
    }

    var body: some View {
        VStack {
            Text(workoutDetails.first?.name ?? "Workout") // Workout Name as non-editable
                .font(.title)
                .padding()
            
            List {
                // Headers
                HStack {
                    Text("Exercise Name")
                        .bold()
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    Divider()
                    Text("Reps")
                        .bold()
                        .frame(width: 80, alignment: .leading)
                    Divider()
                    Text("Weight")
                        .bold()
                        .frame(width: 80, alignment: .leading)
                }
                
                // Detail Rows
                ForEach(workoutDetails, id: \.id) { detail in
                    HStack {
                        Text(detail.exerciseName)
                            .frame(minWidth: 0, maxWidth: .infinity)
                        Divider()
                        TextField("\(detail.reps)", text: Binding(
                            get: { self.userInputs[detail.id]?.reps ?? "" },
                            set: { self.userInputs[detail.id]?.reps = $0 }
                        ))
                        .keyboardType(.numberPad)
                        .frame(width: 80)
                        Divider()
                        TextField("\(detail.weight)", text: Binding(
                            get: { self.userInputs[detail.id]?.weight ?? "" },
                            set: { self.userInputs[detail.id]?.weight = $0 }
                        ))
                        .keyboardType(.numberPad)
                        .frame(width: 80)
                    }
                }
            }
        }
        .background(Color.white)
    }
}
