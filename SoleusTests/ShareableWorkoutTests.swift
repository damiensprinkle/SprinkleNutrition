import XCTest
@testable import Soleus

final class ShareableWorkoutTests: XCTestCase {

    // MARK: - Export

    func testExport_ProducesValidData() {
        let details = [makeDetail(name: "Bench Press", reps: 10, weight: 135)]
        let data = ShareableWorkout.export(workoutName: "Push Day", workoutColor: "MyBlue", workoutDetails: details)

        XCTAssertNotNil(data)
        // Export now uses a binary envelope (magic header + zlib-compressed JSON).
        // Verify round-trip fidelity via import rather than raw JSON parsing.
        let workout = ShareableWorkout.import(from: data!)
        XCTAssertNotNil(workout)
        XCTAssertEqual(workout?.workoutName, "Push Day")
    }

    func testExport_IncludesAllExercises() {
        let details = [
            makeDetail(name: "Bench Press", reps: 10, weight: 135),
            makeDetail(name: "Overhead Press", reps: 8, weight: 95),
        ]
        let data = ShareableWorkout.export(workoutName: "Push", workoutColor: nil, workoutDetails: details)

        let workout = ShareableWorkout.import(from: data!)
        XCTAssertEqual(workout?.exercises.count, 2)
        XCTAssertEqual(workout?.exercises[0].name, "Bench Press")
        XCTAssertEqual(workout?.exercises[1].name, "Overhead Press")
    }

    func testExport_NilColor() {
        let details = [makeDetail(name: "Squat", reps: 5, weight: 225)]
        let data = ShareableWorkout.export(workoutName: "Legs", workoutColor: nil, workoutDetails: details)

        let workout = ShareableWorkout.import(from: data!)
        XCTAssertNil(workout?.workoutColor)
    }

    func testExport_PreservesSetData() {
        let sets = [
            SetInput(reps: 10, weight: 135, time: 0, distance: 0, setIndex: 0),
            SetInput(reps: 8, weight: 155, time: 0, distance: 0, setIndex: 1),
            SetInput(reps: 6, weight: 175, time: 0, distance: 0, setIndex: 2),
        ]
        let detail = WorkoutDetailInput(
            id: UUID(), exerciseId: UUID(), exerciseName: "Bench",
            orderIndex: 0, sets: sets,
            exerciseQuantifier: "Reps", exerciseMeasurement: "Weight"
        )
        let data = ShareableWorkout.export(workoutName: "Test", workoutColor: "MyBlue", workoutDetails: [detail])

        let workout = ShareableWorkout.import(from: data!)
        let importedSets = workout!.exercises[0].sets
        XCTAssertEqual(importedSets.count, 3)
        XCTAssertEqual(importedSets[0].reps, 10)
        XCTAssertEqual(importedSets[0].weight, 135)
        XCTAssertEqual(importedSets[1].reps, 8)
        XCTAssertEqual(importedSets[2].weight, 175)
    }

    func testExport_EmptyExerciseList() {
        let data = ShareableWorkout.export(workoutName: "Empty", workoutColor: nil, workoutDetails: [])

        let workout = ShareableWorkout.import(from: data!)
        XCTAssertNotNil(workout)
        XCTAssertEqual(workout?.exercises.count, 0)
    }

    // MARK: - Import

    func testImport_InvalidData_ReturnsNil() {
        let garbage = "not json".data(using: .utf8)!
        XCTAssertNil(ShareableWorkout.import(from: garbage))
    }

    func testImport_EmptyData_ReturnsNil() {
        XCTAssertNil(ShareableWorkout.import(from: Data()))
    }

    // MARK: - Round-trip

    func testRoundTrip_ExportImport() {
        let details = [
            makeDetail(name: "Squat", reps: 5, weight: 225, quantifier: "Reps", measurement: "Weight"),
            makeDetail(name: "Running", reps: 0, weight: 0, time: 1800, distance: 3.1, quantifier: "Distance", measurement: "Time"),
        ]
        let data = ShareableWorkout.export(workoutName: "Full Body", workoutColor: "MyGreen", workoutDetails: details)!

        let imported = ShareableWorkout.import(from: data)!

        XCTAssertEqual(imported.workoutName, "Full Body")
        XCTAssertEqual(imported.workoutColor, "MyGreen")
        XCTAssertEqual(imported.exercises.count, 2)
        XCTAssertEqual(imported.exercises[0].name, "Squat")
        XCTAssertEqual(imported.exercises[0].quantifier, "Reps")
        XCTAssertEqual(imported.exercises[1].name, "Running")
        XCTAssertEqual(imported.exercises[1].measurement, "Time")
        XCTAssertEqual(imported.exercises[1].sets[0].distance, 3.1, accuracy: 0.01)
    }

    // MARK: - toWorkoutDetails

    func testToWorkoutDetails_CreatesNewUUIDs() {
        let details = [makeDetail(name: "Bench", reps: 10, weight: 135)]
        let data = ShareableWorkout.export(workoutName: "Test", workoutColor: nil, workoutDetails: details)!
        let imported = ShareableWorkout.import(from: data)!

        let converted = imported.toWorkoutDetails()

        XCTAssertEqual(converted.count, 1)
        XCTAssertEqual(converted[0].exerciseName, "Bench")
        XCTAssertNotNil(converted[0].id)
        XCTAssertNotNil(converted[0].exerciseId)
        // UUIDs should be freshly generated, not matching originals
        XCTAssertNotEqual(converted[0].id, details[0].id)
    }

    func testToWorkoutDetails_PreservesSetValues() {
        let sets = [
            SetInput(reps: 10, weight: 135, time: 0, distance: 0, setIndex: 0),
            SetInput(reps: 8, weight: 155, time: 0, distance: 0, setIndex: 1),
        ]
        let detail = WorkoutDetailInput(
            id: UUID(), exerciseId: UUID(), exerciseName: "Curl",
            orderIndex: 0, sets: sets,
            exerciseQuantifier: "Reps", exerciseMeasurement: "Weight"
        )
        let data = ShareableWorkout.export(workoutName: "Arms", workoutColor: nil, workoutDetails: [detail])!
        let imported = ShareableWorkout.import(from: data)!

        let converted = imported.toWorkoutDetails()
        XCTAssertEqual(converted[0].sets.count, 2)
        XCTAssertEqual(converted[0].sets[0].reps, 10)
        XCTAssertEqual(converted[0].sets[0].weight, 135)
        XCTAssertEqual(converted[0].sets[1].reps, 8)
        XCTAssertEqual(converted[0].sets[1].weight, 155)
    }

    func testToWorkoutDetails_PreservesExerciseMetadata() {
        let detail = WorkoutDetailInput(
            id: UUID(), exerciseId: UUID(), exerciseName: "Run",
            orderIndex: 2, sets: [],
            exerciseQuantifier: "Distance", exerciseMeasurement: "Time"
        )
        let data = ShareableWorkout.export(workoutName: "Cardio", workoutColor: nil, workoutDetails: [detail])!
        let imported = ShareableWorkout.import(from: data)!

        let converted = imported.toWorkoutDetails()
        XCTAssertEqual(converted[0].exerciseName, "Run")
        XCTAssertEqual(converted[0].orderIndex, 2)
        XCTAssertEqual(converted[0].exerciseQuantifier, "Distance")
        XCTAssertEqual(converted[0].exerciseMeasurement, "Time")
    }

    // MARK: - Helpers

    private func makeDetail(
        name: String,
        reps: Int32 = 0,
        weight: Float = 0,
        time: Int32 = 0,
        distance: Float = 0,
        quantifier: String = "Reps",
        measurement: String = "Weight"
    ) -> WorkoutDetailInput {
        WorkoutDetailInput(
            id: UUID(),
            exerciseId: UUID(),
            exerciseName: name,
            orderIndex: 0,
            sets: [SetInput(reps: reps, weight: weight, time: time, distance: distance, setIndex: 0)],
            exerciseQuantifier: quantifier,
            exerciseMeasurement: measurement
        )
    }
}
