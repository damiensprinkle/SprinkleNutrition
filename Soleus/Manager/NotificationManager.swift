import Foundation
import UserNotifications

struct NotificationManager {

    // MARK: - Identifiers

    static let activeWorkoutID   = "active_workout_reminder"
    static let inactivityID      = "inactivity_reminder"
    static let streakReminderID  = "streak_reminder"

    // MARK: - Active Workout Reminder

    /// Schedules a notification that fires 2 hours after the workout starts.
    /// Should be called when a workout session becomes active.
    static func scheduleActiveWorkoutReminder() {
        guard UserDefaults.standard.bool(forKey: "notificationsEnabled"),
              UserDefaults.standard.bool(forKey: "notifyActiveWorkout") else { return }

        cancelActiveWorkoutReminder()

        let content = UNMutableNotificationContent()
        content.title = "Workout Still Running"
        content.body = "Your workout has been running for over 2 hours. Don't forget to end your session."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7200, repeats: false)
        let request = UNNotificationRequest(identifier: activeWorkoutID, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                AppLogger.lifecycle.error("Failed to schedule active workout reminder: \(error.localizedDescription)")
            }
        }
    }

    /// Cancels the active workout reminder. Call when a workout ends or the app returns to foreground.
    static func cancelActiveWorkoutReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [activeWorkoutID])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [activeWorkoutID])
    }

    // MARK: - Inactivity Reminder

    /// Schedules a notification at `hour` on the day `days` days from now.
    /// Should be called on workout completion and when the setting changes.
    static func scheduleInactivityReminder(afterDays days: Int, hour: Int) {
        guard UserDefaults.standard.bool(forKey: "notificationsEnabled"),
              UserDefaults.standard.bool(forKey: "notifyInactivity"),
              days > 0 else { return }

        cancelInactivityReminder()

        let content = UNMutableNotificationContent()
        content.title = "Time to Work Out"
        content.body = "You haven't logged a workout in \(days) day\(days == 1 ? "" : "s"). Get back at it!"
        content.sound = .default

        let fireDate = Date().addingTimeInterval(Double(days) * 86400)
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: fireDate)
        dateComponents.hour = hour
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: inactivityID, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                AppLogger.lifecycle.error("Failed to schedule inactivity reminder: \(error.localizedDescription)")
            }
        }
    }

    static func cancelInactivityReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [inactivityID])
    }

    // MARK: - Streak Reminder

    /// Schedules a streak-at-risk notification for tonight at `hour` if the user has an active
    /// streak and has not yet worked out today. Cancels any existing reminder otherwise.
    /// Should be called when the app goes to background and when settings change.
    static func scheduleStreakReminderIfNeeded(streakCount: Int, workedOutToday: Bool, hour: Int) {
        guard UserDefaults.standard.bool(forKey: "notificationsEnabled"),
              UserDefaults.standard.bool(forKey: "notifyStreakAtRisk"),
              streakCount > 0,
              !workedOutToday else {
            cancelStreakReminder()
            return
        }

        cancelStreakReminder()

        let content = UNMutableNotificationContent()
        content.title = "Streak at Risk"
        content.body = "Your \(streakCount)-day streak is at risk! Complete a workout today to keep it alive."
        content.sound = .default

        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        dateComponents.hour = hour
        dateComponents.minute = 0

        guard let scheduledDate = Calendar.current.date(from: dateComponents),
              scheduledDate > Date() else {
            return // Scheduled time has already passed today
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: streakReminderID, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                AppLogger.lifecycle.error("Failed to schedule streak reminder: \(error.localizedDescription)")
            }
        }
    }

    static func cancelStreakReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [streakReminderID])
    }

    // MARK: - Cancel All

    static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}
