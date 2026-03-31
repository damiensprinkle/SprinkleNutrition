import Foundation
import FirebaseAnalytics

struct AnalyticsManager {

    // MARK: - Workout Templates

    static func logWorkoutCreated(exerciseCount: Int) {
        Analytics.logEvent("workout_created", parameters: [
            "exercise_count": exerciseCount
        ])
    }

    static func logWorkoutUpdated(exerciseCount: Int) {
        Analytics.logEvent("workout_updated", parameters: [
            "exercise_count": exerciseCount
        ])
    }

    static func logWorkoutDeleted() {
        Analytics.logEvent("workout_deleted", parameters: nil)
    }

    // MARK: - Active Workout

    static func logWorkoutStarted(exerciseCount: Int) {
        Analytics.logEvent("workout_started", parameters: [
            "exercise_count": exerciseCount
        ])
    }

    static func logWorkoutCompleted(durationSeconds: Int, totalWeightLifted: Float, repsCompleted: Int, exerciseCount: Int) {
        Analytics.logEvent("workout_completed", parameters: [
            "duration_seconds": durationSeconds,
            "total_weight_lifted": totalWeightLifted,
            "reps_completed": repsCompleted,
            "exercise_count": exerciseCount
        ])
    }

    static func logWorkoutAbandoned() {
        Analytics.logEvent("workout_abandoned", parameters: nil)
    }
}
