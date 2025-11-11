//
//  WorkoutManaging.swift
//  FlexSprinkle
//
//  Created by Claude Code
//

import Foundation
import CoreData
import Combine

/// Protocol defining the interface for managing workouts, sessions, and history
protocol WorkoutManaging: AnyObject, ObservableObject {

    // MARK: - Published Properties
    var workouts: [WorkoutInfo] { get set }

    // MARK: - Context Management
    var context: NSManagedObjectContext? { get set }

    // MARK: - Workout CRUD Operations

    /// Adds a new workout with exercise details
    func addWorkoutDetail(
        id: UUID,
        workoutTitle: String,
        exerciseName: String,
        color: String,
        orderIndex: Int32,
        sets: [SetInput],
        exerciseMeasurement: String,
        exerciseQuantifier: String
    )

    /// Fetches a workout by its ID
    func fetchWorkoutById(for workoutId: UUID) -> Workouts?

    /// Loads all workouts with their IDs
    func loadWorkoutsWithId()

    /// Deletes a workout and all associated data
    func deleteWorkout(for workoutId: UUID)

    /// Duplicates an existing workout
    func duplicateWorkout(originalWorkoutId: UUID)

    /// Updates the title of a workout
    func updateWorkoutTitle(workoutId: UUID, to newTitle: String)

    /// Updates the color of a workout
    func updateWorkoutColor(workoutId: UUID, color: String)

    /// Updates workout details (exercises and sets)
    func updateWorkoutDetails(workoutId: UUID, workoutDetailsInput: [WorkoutDetailInput])

    /// Checks if a workout title already exists
    func titleExists(_ title: String) -> Bool

    // MARK: - Active Workout / Temporary Data Management

    /// Saves or updates sets during an active workout
    func saveOrUpdateSetsDuringActiveWorkout(
        workoutId: UUID,
        exerciseId: UUID,
        exerciseName: String,
        setsInput: [SetInput],
        orderIndex: Int32
    )

    /// Loads temporary workout data for an active workout
    func loadTemporaryWorkoutData(for workoutId: UUID) -> [WorkoutDetailInput]

    /// Deletes all temporary workout details
    func deleteAllTemporaryWorkoutDetails()

    // MARK: - Session Management

    /// Gets all workout sessions
    func getSessions() -> [WorkoutSession]

    /// Gets the workout ID of the currently active session
    func getWorkoutIdOfActiveSession() -> UUID?

    /// Sets the session status (active/inactive) for a workout
    func setSessionStatus(workoutId: UUID, isActive: Bool)

    // MARK: - Workout History

    /// Saves workout history after completion
    func saveWorkoutHistory(
        workoutId: UUID,
        dateCompleted: Date,
        totalWeightLifted: Float,
        repsCompleted: Int32,
        workoutTimeToComplete: String,
        totalCardioTime: String,
        totalDistance: Float,
        workoutDetailsInput: [WorkoutDetailInput]
    )

    /// Fetches the most recent workout history for a specific workout
    func fetchLatestWorkoutHistory(for workoutId: UUID) -> WorkoutHistory?

    /// Fetches all workout history for a specific month
    func fetchAllWorkoutHistory(for date: Date) -> [WorkoutHistory]?

    /// Deletes a specific workout history entry
    func deleteWorkoutHistory(for historyId: UUID)
}
