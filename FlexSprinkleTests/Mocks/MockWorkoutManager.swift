//
//  MockWorkoutManager.swift
//  FlexSprinkleTests
//
//  Created by Claude Code
//

import Foundation
import CoreData
import Combine
@testable import FlexSprinkle

class MockWorkoutManager: ObservableObject, WorkoutManaging {
    @Published var workouts: [WorkoutInfo] = []
    var context: NSManagedObjectContext?

    // Test data storage - simplified to avoid CoreData
    private var storedWorkoutData: [UUID: (name: String, color: String?)] = [:]
    private var storedHistory: [UUID: [WorkoutHistory]] = [:]
    private var storedSessions: [WorkoutSession] = []
    private var activeSessionWorkoutId: UUID?

    // Track method calls for verification
    var addWorkoutDetailCalled = false
    var deleteWorkoutCalled = false
    var updateWorkoutDetailsCalled = false
    var saveWorkoutHistoryCalled = false
    var setSessionStatusCalled = false
    var lastDeletedWorkoutId: UUID?
    var lastUpdatedWorkoutId: UUID?

    // MARK: - Workout CRUD Operations

    func addWorkoutDetail(
        id: UUID,
        workoutTitle: String,
        exerciseName: String,
        color: String,
        orderIndex: Int32,
        sets: [SetInput],
        exerciseMeasurement: String,
        exerciseQuantifier: String
    ) {
        addWorkoutDetailCalled = true

        // Store workout data
        storedWorkoutData[id] = (name: workoutTitle, color: color)

        let workoutInfo = WorkoutInfo(id: id, name: workoutTitle)
        workouts.append(workoutInfo)
    }

    func fetchWorkoutById(for workoutId: UUID) -> Workouts? {
        // Return nil for mock - tests don't need actual CoreData objects
        return nil
    }

    func loadWorkoutsWithId() {
        // In tests, we can directly set the workouts array
        // Only load from storedWorkoutData if workouts array is empty
        if workouts.isEmpty {
            workouts = storedWorkoutData.map { (id, data) in
                WorkoutInfo(id: id, name: data.name)
            }
        }
    }

    func deleteWorkout(for workoutId: UUID) {
        deleteWorkoutCalled = true
        lastDeletedWorkoutId = workoutId
        storedWorkoutData.removeValue(forKey: workoutId)
        workouts.removeAll { $0.id == workoutId }
    }

    func duplicateWorkout(originalWorkoutId: UUID) {
        guard let original = storedWorkoutData[originalWorkoutId] else { return }

        let newId = UUID()
        storedWorkoutData[newId] = (name: "\(original.name)-copy", color: original.color)

        let workoutInfo = WorkoutInfo(id: newId, name: "\(original.name)-copy")
        workouts.append(workoutInfo)
    }

    func updateWorkoutTitle(workoutId: UUID, to newTitle: String) {
        if var data = storedWorkoutData[workoutId] {
            data.name = newTitle
            storedWorkoutData[workoutId] = data
        }
        if let index = workouts.firstIndex(where: { $0.id == workoutId }) {
            workouts[index] = WorkoutInfo(id: workoutId, name: newTitle)
        }
    }

    func updateWorkoutColor(workoutId: UUID, color: String) {
        if var data = storedWorkoutData[workoutId] {
            data.color = color
            storedWorkoutData[workoutId] = data
        }
    }

    func updateWorkoutDetails(workoutId: UUID, workoutDetailsInput: [WorkoutDetailInput]) {
        updateWorkoutDetailsCalled = true
        lastUpdatedWorkoutId = workoutId
    }

    func titleExists(_ title: String) -> Bool {
        return workouts.contains { $0.name.lowercased() == title.lowercased() }
    }

    // MARK: - Active Workout / Temporary Data

    func saveOrUpdateSetsDuringActiveWorkout(
        workoutId: UUID,
        exerciseId: UUID,
        exerciseName: String,
        setsInput: [SetInput],
        orderIndex: Int32
    ) {
        // Mock implementation - do nothing
    }

    func loadTemporaryWorkoutData(for workoutId: UUID) -> [WorkoutDetailInput] {
        return []
    }

    func deleteAllTemporaryWorkoutDetails() {
        // Mock implementation - do nothing
    }

    // MARK: - Session Management

    func getSessions() -> [WorkoutSession] {
        return storedSessions
    }

    func getWorkoutIdOfActiveSession() -> UUID? {
        return activeSessionWorkoutId
    }

    func setSessionStatus(workoutId: UUID, isActive: Bool) {
        setSessionStatusCalled = true
        if isActive {
            activeSessionWorkoutId = workoutId
        } else {
            activeSessionWorkoutId = nil
        }
    }

    // MARK: - Workout History

    func saveWorkoutHistory(
        workoutId: UUID,
        dateCompleted: Date,
        totalWeightLifted: Float,
        repsCompleted: Int32,
        workoutTimeToComplete: String,
        totalCardioTime: String,
        totalDistance: Float,
        workoutDetailsInput: [WorkoutDetailInput]
    ) {
        saveWorkoutHistoryCalled = true

        let history = MockWorkoutHistory(
            id: UUID(),
            workoutDate: dateCompleted,
            totalWeightLifted: totalWeightLifted,
            repsCompleted: repsCompleted,
            workoutTimeToComplete: workoutTimeToComplete
        )

        if storedHistory[workoutId] == nil {
            storedHistory[workoutId] = []
        }
        storedHistory[workoutId]?.append(history)
    }

    func fetchLatestWorkoutHistory(for workoutId: UUID) -> WorkoutHistory? {
        return storedHistory[workoutId]?.last
    }

    func fetchAllWorkoutHistory(for date: Date) -> [WorkoutHistory]? {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)

        return storedHistory.values.flatMap { $0 }.filter { history in
            guard let historyDate = history.workoutDate else { return false }
            let historyMonth = calendar.component(.month, from: historyDate)
            let historyYear = calendar.component(.year, from: historyDate)
            return historyMonth == month && historyYear == year
        }
    }

    func deleteWorkoutHistory(for historyId: UUID) {
        for (workoutId, histories) in storedHistory {
            storedHistory[workoutId] = histories.filter { $0.id != historyId }
        }
    }
}

// MARK: - Mock CoreData Objects

class MockWorkoutHistory: WorkoutHistory {
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    init(id: UUID, workoutDate: Date, totalWeightLifted: Float, repsCompleted: Int32, workoutTimeToComplete: String) {
        let entity = NSEntityDescription()
        entity.name = "WorkoutHistory"
        super.init(entity: entity, insertInto: nil)
        self.id = id
        self.workoutDate = workoutDate
        self.totalWeightLifted = totalWeightLifted
        self.repsCompleted = repsCompleted
        self.workoutTimeToComplete = workoutTimeToComplete
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
