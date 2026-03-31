import XCTest
import CoreData
@testable import Soleus

/// Tests that WorkoutManager correctly persists and reloads set values during
/// an active workout via the TemporaryWorkoutDetail entity.
final class ActiveWorkoutSaveTests: XCTestCase {

    var workoutManager: WorkoutManager!
    var context: NSManagedObjectContext!

    // IDs resolved after workout creation
    var workoutId: UUID!
    var exerciseId: UUID!
    var setId: UUID!

    override func setUp() {
        super.setUp()
        let persistence = PersistenceController.forUITesting
        context = persistence.container.viewContext
        workoutManager = WorkoutManager()
        workoutManager.context = context

        // Create a Reps/Weight workout with one set
        setId = UUID()
        workoutManager.addWorkoutDetail(
            id: UUID(),
            workoutTitle: "ActiveSaveTest Workout",
            exerciseName: "Bench Press",
            color: "MyBlue",
            orderIndex: 0,
            sets: [SetInput(id: setId, reps: 10, weight: 135, time: 0, distance: 0, isCompleted: false, setIndex: 0)],
            exerciseMeasurement: "Weight",
            exerciseQuantifier: "Reps"
        )

        // Resolve the auto-generated workout UUID
        let workoutReq = NSFetchRequest<Workouts>(entityName: "Workouts")
        workoutReq.predicate = NSPredicate(format: "name == %@", "ActiveSaveTest Workout")
        let workouts = try? context.fetch(workoutReq)
        workoutId = workouts?.first?.id

        // Resolve the exerciseId assigned by addWorkoutDetail
        if let workout = workouts?.first,
           let details = workout.details as? Set<WorkoutDetail>,
           let detail = details.first(where: { $0.exerciseName == "Bench Press" }) {
            exerciseId = detail.exerciseId
        }
    }

    override func tearDown() {
        // Delete test workout and all its relationships
        let req = NSFetchRequest<Workouts>(entityName: "Workouts")
        req.predicate = NSPredicate(format: "name == %@", "ActiveSaveTest Workout")
        if let workouts = try? context.fetch(req) {
            workouts.forEach { context.delete($0) }
        }
        let tempReq = NSFetchRequest<TemporaryWorkoutDetail>(entityName: "TemporaryWorkoutDetail")
        if let tempDetails = try? context.fetch(tempReq) {
            tempDetails.forEach { context.delete($0) }
        }
        try? context.save()

        workoutManager = nil
        context = nil
        workoutId = nil
        exerciseId = nil
        setId = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func save(reps: Int32 = 10, weight: Float = 135, setIndex: Int32 = 0) {
        workoutManager.saveOrUpdateSetsDuringActiveWorkout(
            workoutId: workoutId,
            exerciseId: exerciseId,
            exerciseName: "Bench Press",
            setsInput: [SetInput(id: setId, reps: reps, weight: weight, time: 0, distance: 0, isCompleted: false, setIndex: setIndex)],
            orderIndex: 0
        )
    }

    private func loadTemp() -> [WorkoutDetailInput] {
        workoutManager.loadTemporaryWorkoutData(for: workoutId)
    }

    // MARK: - Persistence Tests

    func test_SaveCreatesTemporaryDetail() {
        save()

        let results = loadTemp()
        XCTAssertEqual(results.count, 1, "Should create one TemporaryWorkoutDetail")
        XCTAssertEqual(results.first?.exerciseName, "Bench Press")
    }

    func test_SavePersistsWeightValue() {
        save(weight: 225.5)

        let sets = loadTemp().first?.sets
        XCTAssertEqual(sets?.first?.weight ?? 0, Float(225.5), accuracy: Float(0.01))
    }

    func test_SavePersistsRepsValue() {
        save(reps: 12)

        let sets = loadTemp().first?.sets
        XCTAssertEqual(sets?.first?.reps, Int32(12))
    }

    func test_SaveUpdatesExistingRecord_NotDuplicate() {
        save(weight: 135)
        save(weight: 185)

        let results = loadTemp()
        XCTAssertEqual(results.count, 1, "Second save should update, not create a new entry")
        XCTAssertEqual(results.first?.sets.count, 1, "Should not duplicate the set")
        XCTAssertEqual(results.first?.sets.first?.weight ?? 0, Float(185), accuracy: Float(0.01))
    }

    func test_SaveOnlyOneSet_DoesNotOverwriteOtherSets() {
        // Create a workout detail with two sets
        let set2Id = UUID()
        let otherExerciseId = UUID()
        workoutManager.saveOrUpdateSetsDuringActiveWorkout(
            workoutId: workoutId,
            exerciseId: exerciseId,
            exerciseName: "Bench Press",
            setsInput: [
                SetInput(id: setId,  reps: 10, weight: 135, time: 0, distance: 0, isCompleted: false, setIndex: 0),
                SetInput(id: set2Id, reps: 8,  weight: 145, time: 0, distance: 0, isCompleted: false, setIndex: 1),
            ],
            orderIndex: 0
        )

        // Now update only set 1
        workoutManager.saveOrUpdateSetsDuringActiveWorkout(
            workoutId: workoutId,
            exerciseId: exerciseId,
            exerciseName: "Bench Press",
            setsInput: [SetInput(id: setId, reps: 10, weight: 155, time: 0, distance: 0, isCompleted: false, setIndex: 0)],
            orderIndex: 0
        )

        let sets = loadTemp().first?.sets.sorted { $0.setIndex < $1.setIndex }
        XCTAssertEqual(sets?.count, 2, "Both sets should still exist")
        XCTAssertEqual(sets?.first?.weight ?? 0, Float(155), accuracy: Float(0.01), "Set 1 should be updated")
        XCTAssertEqual(sets?.last?.weight  ?? 0, Float(145), accuracy: Float(0.01), "Set 2 should be unchanged")

        _ = otherExerciseId // suppress warning
    }

    // MARK: - Round-Trip Reload Test

    /// Simulates what WorkoutTrackerViewModel does when the view reloads:
    /// 1. loadWorkoutDetails (permanent template)
    /// 2. loadTemporaryWorkoutDetails (overlay temp values)
    func test_RoundTrip_TempValuesOverlayTemplateOnReload() {
        save(reps: 15, weight: 155)

        // Step 1: load permanent template
        var detailsList: [WorkoutDetailInput] = []
        if let workout = workoutManager.fetchWorkoutById(for: workoutId),
           let detailsSet = workout.details as? Set<WorkoutDetail> {
            detailsList = detailsSet.sorted { $0.orderIndex < $1.orderIndex }.compactMap { detail in
                guard let exerciseName = detail.exerciseName,
                      let quantifier = detail.exerciseQuantifier,
                      let measurement = detail.exerciseMeasurement else { return nil }
                let sortedSets = (detail.sets?.allObjects as? [WorkoutSet])?
                    .sorted { $0.setIndex < $1.setIndex } ?? []
                return WorkoutDetailInput(
                    id: detail.id,
                    exerciseId: detail.exerciseId,
                    exerciseName: exerciseName,
                    orderIndex: detail.orderIndex,
                    sets: sortedSets.map { SetInput(id: $0.id, reps: $0.reps, weight: $0.weight, time: $0.time, distance: $0.distance, isCompleted: $0.isCompleted, setIndex: $0.setIndex) },
                    exerciseQuantifier: quantifier,
                    exerciseMeasurement: measurement
                )
            }
        }

        // Step 2: overlay temp values
        let tempDetails = loadTemp()
        for tempDetail in tempDetails {
            guard let idx = detailsList.firstIndex(where: { $0.exerciseId == tempDetail.exerciseId }) else { continue }
            var existingSets = detailsList[idx].sets
            for tempSet in tempDetail.sets {
                if let setIdx = existingSets.firstIndex(where: { $0.id == tempSet.id }) {
                    existingSets[setIdx] = tempSet
                }
            }
            detailsList[idx].sets = existingSets
        }

        XCTAssertEqual(detailsList.first?.sets.first?.reps, Int32(15), "Temp reps should overlay the template")
        XCTAssertEqual(detailsList.first?.sets.first?.weight ?? 0, Float(155), accuracy: Float(0.01), "Temp weight should overlay the template")
    }

    // MARK: - Edge Cases

    func test_SaveWithUnknownWorkoutId_DoesNotCrash() {
        // Should fail gracefully without crashing
        workoutManager.saveOrUpdateSetsDuringActiveWorkout(
            workoutId: UUID(),
            exerciseId: exerciseId,
            exerciseName: "Bench Press",
            setsInput: [SetInput(id: setId, reps: 10, weight: 135, time: 0, distance: 0, isCompleted: false, setIndex: 0)],
            orderIndex: 0
        )
        // No assertion needed — just verifying no crash
    }

    func test_LoadTempForUnknownWorkoutId_ReturnsEmpty() {
        let results = workoutManager.loadTemporaryWorkoutData(for: UUID())
        XCTAssertEqual(results.count, 0)
    }
}
