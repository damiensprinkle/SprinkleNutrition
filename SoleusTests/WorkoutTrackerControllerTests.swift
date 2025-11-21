//
//  WorkoutTrackerControllerTests.swift
//  FlexSprinkleTests
//
//  Created by Claude Code
//

import XCTest
import Combine
@testable import FlexSprinkle

final class WorkoutTrackerControllerTests: XCTestCase {
    var sut: WorkoutTrackerController!
    var mockManager: MockWorkoutManager!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockManager = MockWorkoutManager()
        sut = WorkoutTrackerController(workoutManager: mockManager)
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        mockManager = nil
        super.tearDown()
    }

    // MARK: - Load Workouts Tests

    func testLoadWorkouts_LoadsWorkoutsFromManager() {
        // Given
        let workout1 = WorkoutInfo(id: UUID(), name: "Push Day")
        let workout2 = WorkoutInfo(id: UUID(), name: "Pull Day")
        mockManager.workouts = [workout1, workout2]

        // When
        sut.loadWorkouts()

        // Then
        XCTAssertEqual(sut.workouts.count, 2)
        XCTAssertEqual(sut.workouts[0].name, "Push Day")
        XCTAssertEqual(sut.workouts[1].name, "Pull Day")
    }

    // MARK: - Save Workout Tests

    func testSaveWorkout_WithEmptyTitle_ReturnsError() {
        // Given
        let emptyTitle = "   "
        sut.workoutDetails = [
            WorkoutDetailInput(
                id: UUID(),
                exerciseId: UUID(),
                exerciseName: "Bench Press",
                orderIndex: 0,
                sets: [SetInput(id: UUID(), reps: 10, weight: 100, time: 0, distance: 0, isCompleted: false, setIndex: 0)],
                exerciseQuantifier: "reps", exerciseMeasurement: "lbs"
            )
        ]

        // When
        let result = sut.saveWorkout(title: emptyTitle, update: false, workoutId: UUID())

        // Then
        switch result {
        case .failure(let error):
            XCTAssertEqual(error, .emptyTitle)
        case .success:
            XCTFail("Expected failure, got success")
        }
    }

    func testSaveWorkout_WithNoExercises_ReturnsError() {
        // Given
        let title = "My Workout"
        sut.workoutDetails = []

        // When
        let result = sut.saveWorkout(title: title, update: false, workoutId: UUID())

        // Then
        switch result {
        case .failure(let error):
            XCTAssertEqual(error, .noExerciseDetails)
        case .success:
            XCTFail("Expected failure, got success")
        }
    }

    func testSaveWorkout_WithExistingTitle_ReturnsError() {
        // Given
        let title = "Existing Workout"
        mockManager.workouts = [WorkoutInfo(id: UUID(), name: title)]
        sut.workoutDetails = [
            WorkoutDetailInput(
                id: UUID(),
                exerciseId: UUID(),
                exerciseName: "Squat",
                orderIndex: 0,
                sets: [SetInput(id: UUID(), reps: 5, weight: 200, time: 0, distance: 0, isCompleted: false, setIndex: 0)],
                exerciseQuantifier: "reps", exerciseMeasurement: "lbs"
            )
        ]

        // When
        let result = sut.saveWorkout(title: title, update: false, workoutId: UUID())

        // Then
        switch result {
        case .failure(let error):
            XCTAssertEqual(error, .titleExists)
        case .success:
            XCTFail("Expected failure, got success")
        }
    }

    func testSaveWorkout_NewWorkout_CallsAddWorkoutDetail() {
        // Given
        let title = "New Workout"
        sut.workoutDetails = [
            WorkoutDetailInput(
                id: UUID(),
                exerciseId: UUID(),
                exerciseName: "Deadlift",
                orderIndex: 0,
                sets: [SetInput(id: UUID(), reps: 5, weight: 300, time: 0, distance: 0, isCompleted: false, setIndex: 0)],
                exerciseQuantifier: "reps", exerciseMeasurement: "lbs"
            )
        ]

        // When
        let result = sut.saveWorkout(title: title, update: false, workoutId: UUID())

        // Then
        switch result {
        case .success:
            XCTAssertTrue(mockManager.addWorkoutDetailCalled)
        case .failure:
            XCTFail("Expected success, got failure")
        }
    }

    func testSaveWorkout_UpdateWorkout_CallsUpdateWorkoutDetails() {
        // Given
        let workoutId = UUID()
        let title = "Updated Workout"
        sut.workoutDetails = [
            WorkoutDetailInput(
                id: UUID(),
                exerciseId: UUID(),
                exerciseName: "Press",
                orderIndex: 0,
                sets: [SetInput(id: UUID(), reps: 8, weight: 150, time: 0, distance: 0, isCompleted: false, setIndex: 0)],
                exerciseQuantifier: "reps", exerciseMeasurement: "lbs"
            )
        ]

        // When
        let result = sut.saveWorkout(title: title, update: true, workoutId: workoutId)

        // Then
        switch result {
        case .success:
            XCTAssertTrue(mockManager.updateWorkoutDetailsCalled)
            XCTAssertEqual(mockManager.lastUpdatedWorkoutId, workoutId)
        case .failure:
            XCTFail("Expected success, got failure")
        }
    }

    // MARK: - Delete Workout Tests

    func testDeleteWorkout_CallsManagerDelete() {
        // Given
        let workoutId = UUID()

        // When
        sut.deleteWorkout(workoutId)

        // Then
        XCTAssertTrue(mockManager.deleteWorkoutCalled)
        XCTAssertEqual(mockManager.lastDeletedWorkoutId, workoutId)
    }

    // MARK: - Duplicate Workout Tests

    func testDuplicateWorkout_CreatesNewWorkout() {
        // Given
        let originalId = UUID()
        mockManager.addWorkoutDetail(
            id: originalId,
            workoutTitle: "Original",
            exerciseName: "Test Exercise",
            color: "MyBlue",
            orderIndex: 0,
            sets: [],
            exerciseMeasurement: "lbs",
            exerciseQuantifier: "reps"
        )

        // When
        sut.duplicateWorkout(originalId)

        // Then - Check controller's workouts array after duplication
        XCTAssertEqual(sut.workouts.count, 2)
        XCTAssertTrue(sut.workouts.contains { $0.name == "Original-copy" })
    }

    // MARK: - Exercise Management Tests

    func testMoveExercise_MovesExerciseUpInList() {
        // Given
        let exercise1 = WorkoutDetailInput(
            id: UUID(),
            exerciseId: UUID(),
            exerciseName: "Exercise 1",
            orderIndex: 0,
            sets: [],
            exerciseQuantifier: "reps", exerciseMeasurement: "lbs"
        )
        let exercise2 = WorkoutDetailInput(
            id: UUID(),
            exerciseId: UUID(),
            exerciseName: "Exercise 2",
            orderIndex: 1,
            sets: [],
            exerciseQuantifier: "reps", exerciseMeasurement: "lbs"
        )
        sut.workoutDetails = [exercise1, exercise2]

        // When
        sut.moveExercise(from: 1, to: 0)

        // Then
        XCTAssertEqual(sut.workoutDetails[0].exerciseName, "Exercise 2")
        XCTAssertEqual(sut.workoutDetails[1].exerciseName, "Exercise 1")
        XCTAssertEqual(sut.workoutDetails[0].orderIndex, 0)
        XCTAssertEqual(sut.workoutDetails[1].orderIndex, 1)
    }

    func testDeleteExercise_RemovesExerciseFromList() {
        // Given
        let exercise = WorkoutDetailInput(
            id: UUID(),
            exerciseId: UUID(),
            exerciseName: "To Delete",
            orderIndex: 0,
            sets: [],
            exerciseQuantifier: "reps", exerciseMeasurement: "lbs"
        )
        sut.workoutDetails = [exercise]

        // When
        sut.deleteExercise(at: 0)

        // Then
        XCTAssertTrue(sut.workoutDetails.isEmpty)
    }

    func testAddSet_AddsSetToExercise() {
        // Given
        let exercise = WorkoutDetailInput(
            id: UUID(),
            exerciseId: UUID(),
            exerciseName: "Bench Press",
            orderIndex: 0,
            sets: [],
            exerciseQuantifier: "reps", exerciseMeasurement: "lbs"
        )
        sut.workoutDetails = [exercise]

        // When
        sut.addSet(for: 0)

        // Then
        XCTAssertEqual(sut.workoutDetails[0].sets.count, 1)
    }

    // MARK: - Change Detection Tests

    func testHasWorkoutChanged_WithChanges_ReturnsTrue() {
        // Given
        let originalDetail = WorkoutDetailInput(
            id: UUID(),
            exerciseId: UUID(),
            exerciseName: "Squat",
            orderIndex: 0,
            sets: [SetInput(id: UUID(), reps: 5, weight: 200, time: 0, distance: 0, isCompleted: false, setIndex: 0)],
            exerciseQuantifier: "reps", exerciseMeasurement: "lbs"
        )
        let modifiedDetail = WorkoutDetailInput(
            id: originalDetail.id,
            exerciseId: originalDetail.exerciseId,
            exerciseName: "Squat",
            orderIndex: 0,
            sets: [SetInput(id: UUID(), reps: 8, weight: 220, time: 0, distance: 0, isCompleted: false, setIndex: 0)], // Changed
            exerciseQuantifier: "reps", exerciseMeasurement: "lbs"
        )

        sut.originalWorkoutDetails = [originalDetail]
        sut.workoutDetails = [modifiedDetail]

        // When
        let hasChanged = sut.hasWorkoutChanged()

        // Then
        XCTAssertTrue(hasChanged)
    }

    func testHasWorkoutChanged_WithNoChanges_ReturnsFalse() {
        // Given
        let detail = WorkoutDetailInput(
            id: UUID(),
            exerciseId: UUID(),
            exerciseName: "Press",
            orderIndex: 0,
            sets: [SetInput(id: UUID(), reps: 10, weight: 100, time: 0, distance: 0, isCompleted: false, setIndex: 0)],
            exerciseQuantifier: "reps", exerciseMeasurement: "lbs"
        )

        sut.originalWorkoutDetails = [detail]
        sut.workoutDetails = [detail]

        // When
        let hasChanged = sut.hasWorkoutChanged()

        // Then
        XCTAssertFalse(hasChanged)
    }
}
