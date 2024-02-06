//
//  WorkoutManager.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/5/24.
//

import Foundation

class WorkoutManager: ObservableObject {
    @Published var workoutsDict = [String: [WorkoutDetail]]()
    @Published var workouts: [String] = []

    init() {
        loadWorkouts()
    }

    // Load workouts from UserDefaults
    func loadWorkouts() {
        guard let savedWorkoutsDict = UserDefaults.standard.dictionary(forKey: "workouts") as? [String: [WorkoutDetail]] else {
            return
        }
        workoutsDict = savedWorkoutsDict
        workouts = Array(workoutsDict.keys)
    }

    // Fetch workout details for a given title
    func fetchWorkoutDetails(for title: String) -> [WorkoutDetail] {
        guard let workoutDetails = workoutsDict[title] else {
            return []
        }
        return workoutDetails
    }
    
    // Delete workout/card based on title
    func deleteWorkout(withTitle title: String) {
         workoutsDict[title] = nil
         workouts = Array(workoutsDict.keys)
         saveWorkouts()
     }
    
    // Edit a workout
    func editWorkout(oldTitle: String, newTitle: String, newDetails: [WorkoutDetail]) {
        // Delete the old workout
        deleteWorkout(withTitle: oldTitle)

        // Add the edited workout
        workoutsDict[newTitle] = newDetails
        workouts.append(newTitle)

        // Save the workouts
        saveWorkouts()
    }

    // Save workouts to UserDefaults
    func saveWorkouts() {
        var encodedWorkoutsDict = [String: [[String: Any]]]()

        for (title, details) in workoutsDict {
            let encodedDetails = details.map { detail in
                [
                    "id": detail.id.uuidString,
                    "name": detail.name,
                    "reps": detail.reps,
                    "weight": detail.weight
                ]
            }

            encodedWorkoutsDict[title] = encodedDetails
        }

        UserDefaults.standard.set(encodedWorkoutsDict, forKey: "workouts")
        workouts = Array(workoutsDict.keys)
    }

}
