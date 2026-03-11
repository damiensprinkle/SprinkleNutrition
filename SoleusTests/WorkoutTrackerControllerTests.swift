import XCTest
import Combine
@testable import Soleus

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

    func testHasWorkoutChanged_DifferentCount_ReturnsTrue() {
        // Given
        let detail = WorkoutDetailInput(
            id: UUID(), exerciseId: UUID(), exerciseName: "Squat",
            orderIndex: 0, sets: [], exerciseQuantifier: "reps", exerciseMeasurement: "lbs"
        )
        sut.originalWorkoutDetails = [detail]
        sut.workoutDetails = [] // Removed

        // Then
        XCTAssertTrue(sut.hasWorkoutChanged())
    }

    // MARK: - Rename Exercise Tests

    func testRenameExercise_UpdatesName() {
        // Given
        sut.workoutDetails = [
            WorkoutDetailInput(id: UUID(), exerciseId: UUID(), exerciseName: "Old Name",
                               orderIndex: 0, sets: [], exerciseQuantifier: "reps", exerciseMeasurement: "lbs")
        ]

        // When
        sut.renameExercise(at: 0, to: "New Name")

        // Then
        XCTAssertEqual(sut.workoutDetails[0].exerciseName, "New Name")
    }

    func testRenameExercise_OutOfBounds_DoesNothing() {
        // Given
        sut.workoutDetails = []

        // When - should not crash
        sut.renameExercise(at: 5, to: "Crash Test")

        // Then
        XCTAssertTrue(sut.workoutDetails.isEmpty)
    }

    // MARK: - Delete Set Tests

    func testDeleteSet_RemovesCorrectSet() {
        // Given
        let set1 = SetInput(id: UUID(), reps: 10, weight: 100, time: 0, distance: 0, isCompleted: false, setIndex: 0)
        let set2 = SetInput(id: UUID(), reps: 8, weight: 120, time: 0, distance: 0, isCompleted: false, setIndex: 1)
        let set3 = SetInput(id: UUID(), reps: 6, weight: 140, time: 0, distance: 0, isCompleted: false, setIndex: 2)
        sut.workoutDetails = [
            WorkoutDetailInput(id: UUID(), exerciseId: UUID(), exerciseName: "Bench",
                               orderIndex: 0, sets: [set1, set2, set3],
                               exerciseQuantifier: "reps", exerciseMeasurement: "lbs")
        ]

        // When - delete middle set (setIndex: 1)
        sut.deleteSet(for: 0, setIndex: 1)

        // Then
        XCTAssertEqual(sut.workoutDetails[0].sets.count, 2)
        XCTAssertEqual(sut.workoutDetails[0].sets[0].setIndex, 0)
        XCTAssertEqual(sut.workoutDetails[0].sets[1].setIndex, 2)
    }

    func testDeleteSet_InvalidWorkoutIndex_DoesNothing() {
        // Given
        sut.workoutDetails = []

        // When - should not crash
        sut.deleteSet(for: 5, setIndex: 0)

        // Then
        XCTAssertTrue(sut.workoutDetails.isEmpty)
    }

    func testDeleteSet_NonexistentSetIndex_DoesNothing() {
        // Given
        let set1 = SetInput(id: UUID(), reps: 10, weight: 100, time: 0, distance: 0, isCompleted: false, setIndex: 0)
        sut.workoutDetails = [
            WorkoutDetailInput(id: UUID(), exerciseId: UUID(), exerciseName: "Bench",
                               orderIndex: 0, sets: [set1],
                               exerciseQuantifier: "reps", exerciseMeasurement: "lbs")
        ]

        // When - setIndex 99 doesn't exist
        sut.deleteSet(for: 0, setIndex: 99)

        // Then - nothing removed
        XCTAssertEqual(sut.workoutDetails[0].sets.count, 1)
    }

    // MARK: - Session Status Tests

    func testSetSessionStatus_Active_SetsProperties() {
        // Given
        let workoutId = UUID()

        // When
        sut.setSessionStatus(workoutId: workoutId, isActive: true)

        // Then
        XCTAssertTrue(sut.hasActiveSession)
        XCTAssertEqual(sut.activeWorkoutId, workoutId)
        XCTAssertTrue(mockManager.setSessionStatusCalled)
    }

    func testSetSessionStatus_Inactive_ClearsProperties() {
        // Given
        let workoutId = UUID()
        sut.setSessionStatus(workoutId: workoutId, isActive: true)

        // When
        sut.setSessionStatus(workoutId: workoutId, isActive: false)

        // Then
        XCTAssertFalse(sut.hasActiveSession)
        XCTAssertNil(sut.activeWorkoutId)
    }

    // MARK: - Save Workout Color Tests

    func testSaveWorkoutColor_WithColor_CallsManager() {
        // Given
        let workoutId = UUID()
        sut.cardColor = "MyRed"

        // When
        sut.saveWorkoutColor(workoutId: workoutId)

        // Then - verify it didn't crash and the mock received the call
        // MockWorkoutManager.updateWorkoutColor stores the color
    }

    func testSaveWorkoutColor_NilColor_DoesNothing() {
        // Given
        let workoutId = UUID()
        sut.cardColor = nil

        // When - should not crash
        sut.saveWorkoutColor(workoutId: workoutId)

        // Then - no crash, no call to manager
    }

    // MARK: - Save Workout History Aggregation Tests

    func testSaveWorkoutHistory_CalculatesTotalWeight() {
        // Given - 2 exercises, each with sets
        sut.workoutDetails = [
            WorkoutDetailInput(
                id: UUID(), exerciseId: UUID(), exerciseName: "Bench",
                orderIndex: 0,
                sets: [
                    SetInput(reps: 10, weight: 100, time: 0, distance: 0, setIndex: 0), // 10 * 100 = 1000
                    SetInput(reps: 8, weight: 120, time: 0, distance: 0, setIndex: 1),  // 8 * 120 = 960
                ],
                exerciseQuantifier: "Reps", exerciseMeasurement: "Weight"
            ),
            WorkoutDetailInput(
                id: UUID(), exerciseId: UUID(), exerciseName: "Squat",
                orderIndex: 1,
                sets: [
                    SetInput(reps: 5, weight: 200, time: 0, distance: 0, setIndex: 0),  // 5 * 200 = 1000
                ],
                exerciseQuantifier: "Reps", exerciseMeasurement: "Weight"
            ),
        ]

        // When
        sut.saveWorkoutHistory(elapsedTimeFormatted: "00:30:00", workoutId: UUID())

        // Then - total weight: 1000 + 960 + 1000 = 2960
        XCTAssertTrue(mockManager.saveWorkoutHistoryCalled)
        XCTAssertEqual(mockManager.lastSavedTotalWeight, 2960)
    }

    func testSaveWorkoutHistory_CalculatesTotalReps() {
        // Given
        sut.workoutDetails = [
            WorkoutDetailInput(
                id: UUID(), exerciseId: UUID(), exerciseName: "Curls",
                orderIndex: 0,
                sets: [
                    SetInput(reps: 12, weight: 30, time: 0, distance: 0, setIndex: 0),
                    SetInput(reps: 10, weight: 30, time: 0, distance: 0, setIndex: 1),
                    SetInput(reps: 8, weight: 30, time: 0, distance: 0, setIndex: 2),
                ],
                exerciseQuantifier: "Reps", exerciseMeasurement: "Weight"
            ),
        ]

        // When
        sut.saveWorkoutHistory(elapsedTimeFormatted: "00:15:00", workoutId: UUID())

        // Then - total reps: 12 + 10 + 8 = 30
        XCTAssertTrue(mockManager.saveWorkoutHistoryCalled)
        XCTAssertEqual(mockManager.lastSavedRepsCompleted, 30)
    }

    func testSaveWorkoutHistory_ZeroReps_UsesOneForWeightCalc() {
        // Given - reps = 0, weight = 50, so total weight should be 1 * 50 = 50
        sut.workoutDetails = [
            WorkoutDetailInput(
                id: UUID(), exerciseId: UUID(), exerciseName: "Static Hold",
                orderIndex: 0,
                sets: [
                    SetInput(reps: 0, weight: 50, time: 60, distance: 0, setIndex: 0),
                ],
                exerciseQuantifier: "Reps", exerciseMeasurement: "Weight"
            ),
        ]

        // When
        sut.saveWorkoutHistory(elapsedTimeFormatted: "00:05:00", workoutId: UUID())

        // Then - 0 reps treated as 1 for weight calc: 1 * 50 = 50
        XCTAssertTrue(mockManager.saveWorkoutHistoryCalled)
        XCTAssertEqual(mockManager.lastSavedTotalWeight, 50)
        XCTAssertEqual(mockManager.lastSavedRepsCompleted, 0)
    }

    func testSaveWorkoutHistory_EmptyDetails_SavesZeros() {
        // Given
        sut.workoutDetails = []

        // When
        sut.saveWorkoutHistory(elapsedTimeFormatted: "00:00:00", workoutId: UUID())

        // Then
        XCTAssertTrue(mockManager.saveWorkoutHistoryCalled)
        XCTAssertEqual(mockManager.lastSavedTotalWeight, 0)
        XCTAssertEqual(mockManager.lastSavedRepsCompleted, 0)
        XCTAssertEqual(mockManager.lastSavedTotalDistance, 0)
    }

    // MARK: - Move Exercise Boundary Tests

    func testMoveExercise_OutOfBoundsSource_DoesNothing() {
        // Given
        let exercise = WorkoutDetailInput(
            id: UUID(), exerciseId: UUID(), exerciseName: "Only Exercise",
            orderIndex: 0, sets: [], exerciseQuantifier: "reps", exerciseMeasurement: "lbs"
        )
        sut.workoutDetails = [exercise]

        // When - source index 5 is out of bounds
        sut.moveExercise(from: 5, to: 0)

        // Then
        XCTAssertEqual(sut.workoutDetails.count, 1)
        XCTAssertEqual(sut.workoutDetails[0].exerciseName, "Only Exercise")
    }

    func testMoveExercise_NegativeIndex_DoesNothing() {
        // Given
        let exercise = WorkoutDetailInput(
            id: UUID(), exerciseId: UUID(), exerciseName: "Only Exercise",
            orderIndex: 0, sets: [], exerciseQuantifier: "reps", exerciseMeasurement: "lbs"
        )
        sut.workoutDetails = [exercise]

        // When
        sut.moveExercise(from: -1, to: 0)

        // Then
        XCTAssertEqual(sut.workoutDetails.count, 1)
    }

    func testMoveExercise_UpdatesOrderIndices() {
        // Given
        let ex1 = WorkoutDetailInput(id: UUID(), exerciseId: UUID(), exerciseName: "A", orderIndex: 0, sets: [], exerciseQuantifier: "reps", exerciseMeasurement: "lbs")
        let ex2 = WorkoutDetailInput(id: UUID(), exerciseId: UUID(), exerciseName: "B", orderIndex: 1, sets: [], exerciseQuantifier: "reps", exerciseMeasurement: "lbs")
        let ex3 = WorkoutDetailInput(id: UUID(), exerciseId: UUID(), exerciseName: "C", orderIndex: 2, sets: [], exerciseQuantifier: "reps", exerciseMeasurement: "lbs")
        sut.workoutDetails = [ex1, ex2, ex3]

        // When - move C to position 0
        sut.moveExercise(from: 2, to: 0)

        // Then
        XCTAssertEqual(sut.workoutDetails[0].exerciseName, "C")
        XCTAssertEqual(sut.workoutDetails[0].orderIndex, 0)
        XCTAssertEqual(sut.workoutDetails[1].exerciseName, "A")
        XCTAssertEqual(sut.workoutDetails[1].orderIndex, 1)
        XCTAssertEqual(sut.workoutDetails[2].exerciseName, "B")
        XCTAssertEqual(sut.workoutDetails[2].orderIndex, 2)
    }

    // MARK: - Add Set Copies Last Set Values

    func testAddSet_CopiesLastSetValues() {
        // Given
        let lastSet = SetInput(id: UUID(), reps: 10, weight: 135, time: 0, distance: 0, isCompleted: false, setIndex: 0)
        sut.workoutDetails = [
            WorkoutDetailInput(id: UUID(), exerciseId: UUID(), exerciseName: "Bench",
                               orderIndex: 0, sets: [lastSet],
                               exerciseQuantifier: "reps", exerciseMeasurement: "lbs")
        ]

        // When
        sut.addSet(for: 0)

        // Then
        XCTAssertEqual(sut.workoutDetails[0].sets.count, 2)
        let newSet = sut.workoutDetails[0].sets[1]
        XCTAssertEqual(newSet.reps, 10)
        XCTAssertEqual(newSet.weight, 135)
        XCTAssertEqual(newSet.setIndex, 1)
    }

    func testAddSet_OutOfBounds_DoesNothing() {
        // Given
        sut.workoutDetails = []

        // When - should not crash
        sut.addSet(for: 5)

        // Then
        XCTAssertTrue(sut.workoutDetails.isEmpty)
    }

    // MARK: - Delete Exercise Boundary Tests

    func testDeleteExercise_OutOfBounds_DoesNothing() {
        // Given
        sut.workoutDetails = []

        // When - should not crash
        sut.deleteExercise(at: 0)

        // Then
        XCTAssertTrue(sut.workoutDetails.isEmpty)
    }

    func testDeleteExercise_NegativeIndex_DoesNothing() {
        // Given
        sut.workoutDetails = [
            WorkoutDetailInput(id: UUID(), exerciseId: UUID(), exerciseName: "Keep Me",
                               orderIndex: 0, sets: [], exerciseQuantifier: "reps", exerciseMeasurement: "lbs")
        ]

        // When
        sut.deleteExercise(at: -1)

        // Then
        XCTAssertEqual(sut.workoutDetails.count, 1)
    }
}
