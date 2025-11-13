//
//  ShareableWorkout.swift
//  FlexSprinkle
//
//  Created by Claude Code
//

import Foundation

/// Codable model for exporting/importing workouts as JSON
struct ShareableWorkout: Codable {
    var version: String = "1.0"
    let workoutName: String
    let workoutColor: String?
    let exercises: [ShareableExercise]
    let exportDate: Date

    struct ShareableExercise: Codable {
        let name: String
        let orderIndex: Int32
        let quantifier: String // "Reps" or "Distance"
        let measurement: String // "Weight" or "Time"
        let sets: [ShareableSet]
    }

    struct ShareableSet: Codable {
        let setIndex: Int32
        let reps: Int32
        let weight: Float
        let time: Int32
        let distance: Float
    }

    /// Export workout details to JSON data
    static func export(workoutName: String, workoutColor: String?, workoutDetails: [WorkoutDetailInput]) -> Data? {
        let exercises = workoutDetails.map { detail in
            let sets = detail.sets.map { set in
                ShareableSet(
                    setIndex: set.setIndex,
                    reps: set.reps,
                    weight: set.weight,
                    time: set.time,
                    distance: set.distance
                )
            }

            return ShareableExercise(
                name: detail.exerciseName,
                orderIndex: detail.orderIndex,
                quantifier: detail.exerciseQuantifier,
                measurement: detail.exerciseMeasurement,
                sets: sets
            )
        }

        let shareableWorkout = ShareableWorkout(
            workoutName: workoutName,
            workoutColor: workoutColor,
            exercises: exercises,
            exportDate: Date()
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        return try? encoder.encode(shareableWorkout)
    }

    /// Import workout from JSON data
    static func `import`(from data: Data) -> ShareableWorkout? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try? decoder.decode(ShareableWorkout.self, from: data)
    }

    /// Convert to WorkoutDetailInput array for saving
    func toWorkoutDetails() -> [WorkoutDetailInput] {
        return exercises.map { exercise in
            let setInputs = exercise.sets.map { set in
                SetInput(
                    reps: set.reps,
                    weight: set.weight,
                    time: set.time,
                    distance: set.distance,
                    setIndex: set.setIndex
                )
            }

            return WorkoutDetailInput(
                id: UUID(), // Generate new ID for imported workout
                exerciseId: UUID(), // Generate new exercise ID
                exerciseName: exercise.name,
                orderIndex: exercise.orderIndex,
                sets: setInputs,
                exerciseQuantifier: exercise.quantifier,
                exerciseMeasurement: exercise.measurement
            )
        }
    }
}
