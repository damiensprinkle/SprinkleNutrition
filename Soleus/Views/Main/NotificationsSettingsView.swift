import SwiftUI
import UserNotifications

struct NotificationsSettingsView: View {
    @EnvironmentObject private var achievementManager: AchievementManager

    @AppStorage("notificationsEnabled")     private var notificationsEnabled: Bool = false
    @AppStorage("notifyActiveWorkout")      private var notifyActiveWorkout: Bool = false
    @AppStorage("notifyInactivity")         private var notifyInactivity: Bool = false
    @AppStorage("inactivityReminderDays")   private var inactivityReminderDays: Int = 3
    @AppStorage("inactivityReminderHour")   private var inactivityReminderHour: Int = 9
    @AppStorage("notifyStreakAtRisk")       private var notifyStreakAtRisk: Bool = false
    @AppStorage("streakReminderHour")       private var streakReminderHour: Int = 20

    @State private var authStatus: UNAuthorizationStatus = .notDetermined
    @State private var showDeniedAlert = false

    private let inactivityDayOptions = Array(1...7)
    private let reminderHourOptions  = Array(6...22)

    var body: some View {
        Form {
            // MARK: Master Toggle
            Section(
                header: Text("Push Notifications"),
                footer: Text("When enabled, Soleus can send you reminders and alerts. You will be prompted to grant permission the first time you turn this on.")
            ) {
                Toggle(isOn: Binding(
                    get: { notificationsEnabled },
                    set: { newValue in
                        if newValue { requestOrEnableNotifications() } else { disableAllNotifications() }
                    }
                )) {
                    Text("Enable Notifications")
                }
                .tint(.green)
            }

            if notificationsEnabled {

                // MARK: Active Workout Reminder
                Section(
                    footer: Text("Sends a reminder if your workout timer has been running for over 2 hours while the app is in the background.")
                ) {
                    Toggle("Remind Me If A Workout Is Left Running", isOn: Binding(
                        get: { notifyActiveWorkout },
                        set: { notifyActiveWorkout = $0 }
                    ))
                    .tint(.green)
                }

                // MARK: Inactivity Reminder
                Section(
                    footer: Text("Sends a nudge if you haven't logged a workout within the selected number of days.")
                ) {
                    Toggle("Remind Me To Workout", isOn: Binding(
                        get: { notifyInactivity },
                        set: { newValue in
                            notifyInactivity = newValue
                            if newValue {
                                NotificationManager.scheduleInactivityReminder(afterDays: inactivityReminderDays, hour: inactivityReminderHour)
                            } else {
                                NotificationManager.cancelInactivityReminder()
                            }
                        }
                    ))
                    .tint(.green)

                    if notifyInactivity {
                        Picker("Days Without a Workout", selection: Binding(
                            get: { inactivityReminderDays },
                            set: { newValue in
                                inactivityReminderDays = newValue
                                NotificationManager.scheduleInactivityReminder(afterDays: newValue, hour: inactivityReminderHour)
                            }
                        )) {
                            ForEach(inactivityDayOptions, id: \.self) { days in
                                Text("\(days) day\(days == 1 ? "" : "s")").tag(days)
                            }
                        }

                        Picker("Reminder Time", selection: Binding(
                            get: { inactivityReminderHour },
                            set: { newValue in
                                inactivityReminderHour = newValue
                                NotificationManager.scheduleInactivityReminder(afterDays: inactivityReminderDays, hour: newValue)
                            }
                        )) {
                            ForEach(reminderHourOptions, id: \.self) { hour in
                                Text(formatHour(hour)).tag(hour)
                            }
                        }
                    }
                }

                // MARK: Streak Reminder
                Section(
                    footer: Text("Sends a reminder at the selected time if you have an active streak but haven't worked out yet today.")
                ) {
                    Toggle("Streak At Risk Reminder", isOn: Binding(
                        get: { notifyStreakAtRisk },
                        set: { newValue in
                            notifyStreakAtRisk = newValue
                            if newValue {
                                let stats = achievementManager.getWorkoutStats()
                                NotificationManager.scheduleStreakReminderIfNeeded(
                                    streakCount: stats.currentStreak,
                                    workedOutToday: stats.workedOutToday,
                                    hour: streakReminderHour
                                )
                            } else {
                                NotificationManager.cancelStreakReminder()
                            }
                        }
                    ))
                    .tint(.green)

                    if notifyStreakAtRisk {
                        Picker("Reminder Time", selection: Binding(
                            get: { streakReminderHour },
                            set: { newValue in
                                streakReminderHour = newValue
                                let stats = achievementManager.getWorkoutStats()
                                NotificationManager.scheduleStreakReminderIfNeeded(
                                    streakCount: stats.currentStreak,
                                    workedOutToday: stats.workedOutToday,
                                    hour: newValue
                                )
                            }
                        )) {
                            ForEach(reminderHourOptions, id: \.self) { hour in
                                Text(formatHour(hour)).tag(hour)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Notification Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            refreshAuthStatus()
        }
        .alert("Notifications Disabled", isPresented: $showDeniedAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Notifications are disabled for Soleus. Go to iOS Settings → Soleus to enable them.")
        }
    }

    // MARK: - Helpers

    private func refreshAuthStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                authStatus = settings.authorizationStatus
                if settings.authorizationStatus == .denied || settings.authorizationStatus == .notDetermined {
                    notificationsEnabled = false
                }
            }
        }
    }

    private func requestOrEnableNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                authStatus = settings.authorizationStatus
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    notificationsEnabled = true
                case .notDetermined:
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                        DispatchQueue.main.async {
                            notificationsEnabled = granted
                            authStatus = granted ? .authorized : .denied
                        }
                    }
                case .denied:
                    notificationsEnabled = false
                    showDeniedAlert = true
                @unknown default:
                    notificationsEnabled = false
                }
            }
        }
    }

    private func disableAllNotifications() {
        notificationsEnabled = false
        notifyActiveWorkout = false
        notifyInactivity = false
        notifyStreakAtRisk = false
        NotificationManager.cancelAll()
    }

    private func formatHour(_ hour: Int) -> String {
        let period = hour < 12 ? "AM" : "PM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return "\(displayHour):00 \(period)"
    }
}
