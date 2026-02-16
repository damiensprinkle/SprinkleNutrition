import UIKit

/// Manager for providing haptic feedback throughout the app
class HapticManager {
    static let shared = HapticManager()

    private init() {}

    // MARK: - Impact Feedback

    /// Light impact (e.g., UI interactions, selections)
    func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Medium impact (e.g., set completion, moderate actions)
    func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// Heavy impact (e.g., workout start/end, major actions)
    func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    /// Rigid impact (e.g., errors, warnings)
    func rigid() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
    }

    /// Soft impact (e.g., subtle feedback)
    func soft() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }

    // MARK: - Notification Feedback

    /// Success notification (e.g., workout completed, set saved)
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Warning notification (e.g., workout cancelled, action about to be destructive)
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    /// Error notification (e.g., save failed, validation error)
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    // MARK: - Selection Feedback

    /// Selection changed (e.g., switching tabs, toggling options)
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    // MARK: - Custom Patterns

    /// Set completed - medium impact for tactile feedback
    func setCompleted() {
        medium()
    }

    /// Set uncompleted - light impact
    func setUncompleted() {
        light()
    }

    /// Rest timer completed - notification success
    func restTimerCompleted() {
        success()
    }

    /// Rest timer skipped - selection feedback
    func restTimerSkipped() {
        selection()
    }

    /// Workout started - heavy impact + success notification
    func workoutStarted() {
        heavy()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }

    /// Workout completed - success notification + medium impact
    func workoutCompleted() {
        success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }

    /// Workout cancelled - warning notification
    func workoutCancelled() {
        warning()
    }

    /// Exercise deleted - warning notification
    func exerciseDeleted() {
        warning()
    }

    /// Exercise reordered - selection feedback
    func exerciseReordered() {
        selection()
    }
}
