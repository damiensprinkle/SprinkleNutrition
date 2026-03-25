import Foundation
import HealthKit

// MARK: - Protocol

protocol HealthKitStoring {
    func isHealthDataAvailable() -> Bool
    func authorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus
    func requestAuthorization(toShare typesToShare: Set<HKSampleType>?, read typesToRead: Set<HKObjectType>?, completion: @escaping @Sendable (Bool, Error?) -> Void)
    func save(_ object: HKObject, withCompletion completionHandler: @escaping @Sendable (Bool, Error?) -> Void)
    func save(_ objects: [HKObject], withCompletion completionHandler: @escaping @Sendable (Bool, Error?) -> Void)
}

extension HKHealthStore: HealthKitStoring {
    func isHealthDataAvailable() -> Bool {
        HKHealthStore.isHealthDataAvailable()
    }
}

// MARK: - HealthKitManager

class HealthKitManager: ObservableObject {
    private let store: HealthKitStoring

    var isAvailable: Bool {
        store.isHealthDataAvailable()
    }

    init(store: HealthKitStoring = HKHealthStore()) {
        self.store = store
    }

    func currentAuthorizationStatus() -> HKAuthorizationStatus {
        guard isAvailable else { return .notDetermined }
        return store.authorizationStatus(for: HKObjectType.workoutType())
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard isAvailable else {
            DispatchQueue.main.async { completion(false) }
            return
        }

        var shareTypes: Set<HKSampleType> = [HKObjectType.workoutType()]
        if let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) {
            shareTypes.insert(distanceType)
        }

        store.requestAuthorization(toShare: shareTypes, read: nil) { granted, error in
            if let error = error {
                AppLogger.workout.error("HealthKit authorization error: \(error.localizedDescription)")
            }
            DispatchQueue.main.async { completion(granted) }
        }
    }

    func saveWorkout(startTime: Date, endTime: Date, totalDistance: Float, workoutDetailsInput: [WorkoutDetailInput]) {
        guard isAvailable else { return }
        guard UserDefaults.standard.bool(forKey: "healthKitEnabled") else { return }
        guard currentAuthorizationStatus() == .sharingAuthorized else { return }

        let activityType = HealthKitManager.activityType(for: workoutDetailsInput)
        let distanceInMeters = convertDistanceToMeters(totalDistance)
        let distanceSample = makeDistanceSample(distanceInMeters: distanceInMeters, startTime: startTime, endTime: endTime)

        guard let healthStore = store as? HKHealthStore else {
            // Test path via MockHealthKitStore: save distance sample only (no HKWorkout needed)
            let objects: [HKObject] = distanceSample.map { [$0] } ?? []
            store.save(objects) { _, _ in }
            return
        }

        saveViaBuilder(
            healthStore: healthStore,
            activityType: activityType,
            startTime: startTime,
            endTime: endTime,
            distanceSample: distanceSample
        )
    }

    // MARK: - Internal (visible for testing)

    static func activityType(for workoutDetailsInput: [WorkoutDetailInput]) -> HKWorkoutActivityType {
        let allCardio = !workoutDetailsInput.isEmpty && workoutDetailsInput.allSatisfy {
            $0.exerciseQuantifier == "Time" || $0.exerciseQuantifier == "Distance"
        }
        return allCardio ? .other : .traditionalStrengthTraining
    }

    // MARK: - Helpers

    private func makeDistanceSample(distanceInMeters: Double, startTime: Date, endTime: Date) -> HKQuantitySample? {
        guard distanceInMeters > 0,
              let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else { return nil }
        return HKQuantitySample(
            type: distanceType,
            quantity: HKQuantity(unit: .meter(), doubleValue: distanceInMeters),
            start: startTime,
            end: endTime
        )
    }

    private func saveViaBuilder(
        healthStore: HKHealthStore,
        activityType: HKWorkoutActivityType,
        startTime: Date,
        endTime: Date,
        distanceSample: HKQuantitySample?
    ) {
        let config = HKWorkoutConfiguration()
        config.activityType = activityType
        let builder = HKWorkoutBuilder(healthStore: healthStore, configuration: config, device: nil)
        builder.beginCollection(withStart: startTime) { _, error in
            if let error = error {
                AppLogger.workout.error("HealthKit builder beginCollection error: \(error.localizedDescription)")
                return
            }
            let finishWorkout = {
                builder.endCollection(withEnd: endTime) { _, error in
                    if let error = error {
                        AppLogger.workout.error("HealthKit builder endCollection error: \(error.localizedDescription)")
                        return
                    }
                    builder.finishWorkout { _, error in
                        if let error = error {
                            AppLogger.workout.error("HealthKit save error: \(error.localizedDescription)")
                        } else {
                            AppLogger.workout.info("HealthKit workout saved successfully")
                        }
                    }
                }
            }

            if let sample = distanceSample {
                builder.add([sample]) { _, error in
                    if let error = error {
                        AppLogger.workout.error("HealthKit builder add samples error: \(error.localizedDescription)")
                    }
                    finishWorkout()
                }
            } else {
                finishWorkout()
            }
        }
    }

    private func convertDistanceToMeters(_ distance: Float) -> Double {
        guard distance > 0 else { return 0 }
        let distancePreference = UserDefaults.standard.string(forKey: "distancePreference") ?? "mile"
        return distancePreference == "km" ? Double(distance) * 1000 : Double(distance) * 1609.344
    }
}
