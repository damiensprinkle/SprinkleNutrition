import XCTest
import HealthKit
@testable import Soleus

// MARK: - MockHealthKitStore

final class MockHealthKitStore: HealthKitStoring {
    var healthDataAvailable = true
    var authorizationStatusToReturn: HKAuthorizationStatus = .notDetermined
    var requestAuthorizationResult: (Bool, Error?) = (true, nil)

    var savedObjects: [HKObject] = []
    var saveObjectsCallCount = 0

    func isHealthDataAvailable() -> Bool { healthDataAvailable }

    func authorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus {
        authorizationStatusToReturn
    }

    func requestAuthorization(toShare typesToShare: Set<HKSampleType>?, read typesToRead: Set<HKObjectType>?, completion: @escaping @Sendable (Bool, Error?) -> Void) {
        completion(requestAuthorizationResult.0, requestAuthorizationResult.1)
    }

    func save(_ object: HKObject, withCompletion completionHandler: @escaping @Sendable (Bool, Error?) -> Void) {
        savedObjects.append(object)
        completionHandler(true, nil)
    }

    func save(_ objects: [HKObject], withCompletion completionHandler: @escaping @Sendable (Bool, Error?) -> Void) {
        saveObjectsCallCount += 1
        savedObjects.append(contentsOf: objects)
        completionHandler(true, nil)
    }
}

// MARK: - Tests

final class HealthKitManagerTests: XCTestCase {
    var mockStore: MockHealthKitStore!
    var sut: HealthKitManager!

    override func setUp() {
        super.setUp()
        mockStore = MockHealthKitStore()
        sut = HealthKitManager(store: mockStore)
        UserDefaults.standard.set(false, forKey: "healthKitEnabled")
        UserDefaults.standard.set("mile", forKey: "distancePreference")
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "healthKitEnabled")
        UserDefaults.standard.removeObject(forKey: "distancePreference")
        sut = nil
        mockStore = nil
        super.tearDown()
    }

    // MARK: - isAvailable

    func testIsAvailable_WhenStoreReturnsTrue() {
        mockStore.healthDataAvailable = true
        XCTAssertTrue(sut.isAvailable)
    }

    func testIsAvailable_WhenStoreReturnsFalse() {
        mockStore.healthDataAvailable = false
        XCTAssertFalse(sut.isAvailable)
    }

    // MARK: - currentAuthorizationStatus

    func testCurrentAuthorizationStatus_WhenUnavailable_ReturnsNotDetermined() {
        mockStore.healthDataAvailable = false
        XCTAssertEqual(sut.currentAuthorizationStatus(), .notDetermined)
    }

    func testCurrentAuthorizationStatus_WhenAuthorized() {
        mockStore.authorizationStatusToReturn = .sharingAuthorized
        XCTAssertEqual(sut.currentAuthorizationStatus(), .sharingAuthorized)
    }

    // MARK: - requestAuthorization

    func testRequestAuthorization_WhenUnavailable_CallsBackFalse() {
        mockStore.healthDataAvailable = false
        let exp = expectation(description: "callback")
        sut.requestAuthorization { granted in
            XCTAssertFalse(granted)
            exp.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testRequestAuthorization_WhenGranted_CallsBackTrue() {
        mockStore.requestAuthorizationResult = (true, nil)
        let exp = expectation(description: "callback")
        sut.requestAuthorization { granted in
            XCTAssertTrue(granted)
            exp.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testRequestAuthorization_WhenDenied_CallsBackFalse() {
        mockStore.requestAuthorizationResult = (false, nil)
        let exp = expectation(description: "callback")
        sut.requestAuthorization { granted in
            XCTAssertFalse(granted)
            exp.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    // MARK: - saveWorkout gating

    func testSaveWorkout_WhenDisabled_DoesNotSave() {
        UserDefaults.standard.set(false, forKey: "healthKitEnabled")
        mockStore.authorizationStatusToReturn = .sharingAuthorized
        sut.saveWorkout(startTime: Date(), endTime: Date(), totalDistance: 0, workoutDetailsInput: [])
        XCTAssertEqual(mockStore.saveObjectsCallCount, 0)
    }

    func testSaveWorkout_WhenUnavailable_DoesNotSave() {
        mockStore.healthDataAvailable = false
        UserDefaults.standard.set(true, forKey: "healthKitEnabled")
        mockStore.authorizationStatusToReturn = .sharingAuthorized
        sut.saveWorkout(startTime: Date(), endTime: Date(), totalDistance: 0, workoutDetailsInput: [])
        XCTAssertEqual(mockStore.saveObjectsCallCount, 0)
    }

    func testSaveWorkout_WhenNotAuthorized_DoesNotSave() {
        UserDefaults.standard.set(true, forKey: "healthKitEnabled")
        mockStore.authorizationStatusToReturn = .notDetermined
        sut.saveWorkout(startTime: Date(), endTime: Date(), totalDistance: 0, workoutDetailsInput: [])
        XCTAssertEqual(mockStore.saveObjectsCallCount, 0)
    }

    func testSaveWorkout_WhenEnabledAndAuthorized_Saves() {
        UserDefaults.standard.set(true, forKey: "healthKitEnabled")
        mockStore.authorizationStatusToReturn = .sharingAuthorized
        let start = Date().addingTimeInterval(-3600)
        sut.saveWorkout(startTime: start, endTime: Date(), totalDistance: 0, workoutDetailsInput: [])
        XCTAssertEqual(mockStore.saveObjectsCallCount, 1)
    }

    // MARK: - Activity type detection (pure function — no HealthKit infrastructure needed)

    func testActivityType_StrengthWorkout_UsesTraditionalStrengthTraining() {
        let input = [WorkoutDetailInput(exerciseName: "Bench Press", exerciseQuantifier: "Reps", exerciseMeasurement: "Weight")]
        XCTAssertEqual(HealthKitManager.activityType(for: input), .traditionalStrengthTraining)
    }

    func testActivityType_AllCardioByTime_UsesOther() {
        let input = [WorkoutDetailInput(exerciseName: "Running", exerciseQuantifier: "Time", exerciseMeasurement: "min")]
        XCTAssertEqual(HealthKitManager.activityType(for: input), .other)
    }

    func testActivityType_AllCardioByDistance_UsesOther() {
        let input = [WorkoutDetailInput(exerciseName: "Running", exerciseQuantifier: "Distance", exerciseMeasurement: "km")]
        XCTAssertEqual(HealthKitManager.activityType(for: input), .other)
    }

    func testActivityType_MixedWorkout_UsesTraditionalStrengthTraining() {
        let input = [
            WorkoutDetailInput(exerciseName: "Treadmill", exerciseQuantifier: "Time", exerciseMeasurement: "min"),
            WorkoutDetailInput(exerciseName: "Squat", exerciseQuantifier: "Reps", exerciseMeasurement: "Weight")
        ]
        XCTAssertEqual(HealthKitManager.activityType(for: input), .traditionalStrengthTraining)
    }

    func testActivityType_EmptyList_UsesTraditionalStrengthTraining() {
        XCTAssertEqual(HealthKitManager.activityType(for: []), .traditionalStrengthTraining)
    }

    // MARK: - Distance sample creation (via mock save path)

    func testSaveWorkout_WithDistance_SavesDistanceSample() {
        UserDefaults.standard.set(true, forKey: "healthKitEnabled")
        mockStore.authorizationStatusToReturn = .sharingAuthorized
        let start = Date().addingTimeInterval(-3600)
        sut.saveWorkout(startTime: start, endTime: Date(), totalDistance: 1.0, workoutDetailsInput: [])
        let hasDistanceSample = mockStore.savedObjects.contains { $0 is HKQuantitySample }
        XCTAssertTrue(hasDistanceSample)
    }

    func testSaveWorkout_WithoutDistance_SavesNoObjects() {
        UserDefaults.standard.set(true, forKey: "healthKitEnabled")
        mockStore.authorizationStatusToReturn = .sharingAuthorized
        let start = Date().addingTimeInterval(-3600)
        sut.saveWorkout(startTime: start, endTime: Date(), totalDistance: 0, workoutDetailsInput: [])
        XCTAssertEqual(mockStore.savedObjects.count, 0)
    }

    func testSaveWorkout_DistanceInMiles_ConvertsToMeters() {
        UserDefaults.standard.set(true, forKey: "healthKitEnabled")
        UserDefaults.standard.set("mile", forKey: "distancePreference")
        mockStore.authorizationStatusToReturn = .sharingAuthorized
        let start = Date().addingTimeInterval(-3600)
        sut.saveWorkout(startTime: start, endTime: Date(), totalDistance: 1.0, workoutDetailsInput: [])

        let sample = mockStore.savedObjects.compactMap { $0 as? HKQuantitySample }.first
        let meters = sample?.quantity.doubleValue(for: .meter()) ?? 0
        XCTAssertEqual(meters, 1609.344, accuracy: 0.01)
    }

    func testSaveWorkout_DistanceInKm_ConvertsToMeters() {
        UserDefaults.standard.set(true, forKey: "healthKitEnabled")
        UserDefaults.standard.set("km", forKey: "distancePreference")
        mockStore.authorizationStatusToReturn = .sharingAuthorized
        let start = Date().addingTimeInterval(-3600)
        sut.saveWorkout(startTime: start, endTime: Date(), totalDistance: 1.0, workoutDetailsInput: [])

        let sample = mockStore.savedObjects.compactMap { $0 as? HKQuantitySample }.first
        let meters = sample?.quantity.doubleValue(for: .meter()) ?? 0
        XCTAssertEqual(meters, 1000.0, accuracy: 0.01)
    }
}

// MARK: - WorkoutDetailInput convenience init for tests

private extension WorkoutDetailInput {
    init(exerciseName: String, exerciseQuantifier: String, exerciseMeasurement: String) {
        self.init()
        self.exerciseName = exerciseName
        self.exerciseQuantifier = exerciseQuantifier
        self.exerciseMeasurement = exerciseMeasurement
    }
}
