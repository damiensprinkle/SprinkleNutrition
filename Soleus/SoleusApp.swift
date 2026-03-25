//
//  SoleusApp.swift
//  Soleus
//
//  Created by Damien Sprinkle on 2/2/24.
//

import SwiftUI
import CoreData
import Darwin
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct SoleusApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var persistenceController: PersistenceController
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var workoutManager = WorkoutManager()
    @StateObject private var controller: WorkoutTrackerController
    @StateObject private var errorHandler = ErrorHandler()
    @StateObject private var achievementManager = AchievementManager()
    @StateObject private var healthKitManager = HealthKitManager()


    init() {
        SoleusApp.installCrashHandlers()
        let isUITesting = CommandLine.arguments.contains("--uitesting")
        _persistenceController = StateObject(wrappedValue: isUITesting ? PersistenceController.forUITesting : PersistenceController.shared)

        if isUITesting {
            UserDefaults.standard.set(true, forKey: "hasSeenLongPressTooltip")
            let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            UserDefaults.standard.set(currentVersion, forKey: "lastSeenVersion")
        }

        // Initialize controller with the shared workoutManager instance
        let manager = WorkoutManager()
        let handler = ErrorHandler()
        manager.errorHandler = handler

        _controller = StateObject(wrappedValue: WorkoutTrackerController(workoutManager: manager))
        _workoutManager = StateObject(wrappedValue: manager)
        _errorHandler = StateObject(wrappedValue: handler)

        if let myBlackColor = UIColor(named: "MyBlack") {
            UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: myBlackColor]
            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: myBlackColor]
        }
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(persistenceController)
                .environmentObject(appViewModel)
                .environmentObject(workoutManager)
                .environmentObject(controller)
                .environmentObject(errorHandler)
                .environmentObject(achievementManager)
                .environmentObject(healthKitManager)
                .errorAlert(errorHandler)
                .onAppear() {
                    // Initialize CoreData context for managers
                    if workoutManager.context == nil {
                        workoutManager.context = persistenceController.container.viewContext
                    }
                    // Link achievement manager to workout manager
                    achievementManager.workoutManager = workoutManager
                    // Wire HealthKit manager to workout manager
                    workoutManager.healthKitManager = healthKitManager

                    #if DEBUG
                    // Inject a test workout for UI testing the import preview
                    if let jsonString = ProcessInfo.processInfo.environment["UI_TEST_IMPORT_WORKOUT"],
                       let data = jsonString.data(using: .utf8),
                       let workout = ShareableWorkout.import(from: data) {
                        appViewModel.pendingImport = workout
                    }

                    // Pre-create a named workout so duplicate-detection tests have something to conflict with
                    if let preCreateName = ProcessInfo.processInfo.environment["UI_TEST_PRE_CREATE_WORKOUT"] {
                        workoutManager.addWorkoutDetail(
                            id: UUID(),
                            workoutTitle: preCreateName,
                            exerciseName: "Placeholder",
                            color: "MyBlue",
                            orderIndex: 0,
                            sets: [SetInput(reps: 10, weight: 100, time: 0, distance: 0, setIndex: 0)],
                            exerciseMeasurement: "Weight",
                            exerciseQuantifier: "Reps",
                            notes: nil
                        )
                    }
                    #endif
                }
                .onOpenURL { url in
                    if url.scheme == "soleus" {
                        handleSoleusURL(url)
                    } else {
                        handleImportedFile(url)
                    }
                }
                .onChange(of: scenePhase) { _, newPhase in
                    switch newPhase {
                    case .background:
                        // App going to background — schedule streak reminder if applicable
                        let stats = achievementManager.getWorkoutStats()
                        let hour = UserDefaults.standard.integer(forKey: "streakReminderHour")
                        NotificationManager.scheduleStreakReminderIfNeeded(
                            streakCount: stats.currentStreak,
                            workedOutToday: stats.workedOutToday,
                            hour: hour > 0 ? hour : 20
                        )
                    default:
                        break
                    }
                }
        }
    }

    private func handleImportedFile(_ url: URL) {
        guard url.pathExtension == "soleus" else {
            AppLogger.lifecycle.warning("Invalid file type: \(url.pathExtension)")
            return
        }

        // startAccessingSecurityScopedResource returns false for URLs delivered via
        // file-association (iOS already grants access). Only call stop if it returned true.
        let isSecurityScoped = url.startAccessingSecurityScopedResource()
        defer {
            if isSecurityScoped { url.stopAccessingSecurityScopedResource() }
        }

        do {
            let data = try Data(contentsOf: url)
            if let workout = ShareableWorkout.import(from: data) {
                appViewModel.pendingImport = workout
                appViewModel.resetToWorkoutMainView()
            } else {
                AppLogger.lifecycle.error("Failed to decode workout data")
            }
        } catch {
            AppLogger.lifecycle.error("Error reading file: \(error.localizedDescription)")
        }
    }

    private func handleSoleusURL(_ url: URL) {
        guard url.host == "import",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let base64 = components.queryItems?.first(where: { $0.name == "data" })?.value else {
            AppLogger.lifecycle.warning("Unrecognised soleus:// URL: \(url)")
            return
        }

        // Restore standard base64 padding and character set before decoding.
        let padded = base64
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padLength = (4 - padded.count % 4) % 4
        let paddedBase64 = padded + String(repeating: "=", count: padLength)

        guard let data = Data(base64Encoded: paddedBase64),
              let workout = ShareableWorkout.import(from: data) else {
            AppLogger.lifecycle.error("Failed to decode workout from soleus:// URL")
            return
        }

        appViewModel.pendingImport = workout
        appViewModel.resetToWorkoutMainView()
    }

    // MARK: - Crash Handlers

    private static func installCrashHandlers() {
        // Catch Objective-C exceptions (e.g. NSRangeException, NSInvalidArgumentException)
        NSSetUncaughtExceptionHandler { exception in
            AppLogger.lifecycle.critical("Uncaught exception: \(exception.name.rawValue) — \(exception.reason ?? "no reason") | Stack: \(exception.callStackSymbols.prefix(10).joined(separator: ", "))")
        }

        // Catch Swift-level crashes (overflow, out of bounds, force-unwrap, etc.)
        let signals = [SIGABRT, SIGILL, SIGSEGV, SIGFPE, SIGBUS, SIGTRAP]
        signals.forEach { sig in
            signal(sig) { receivedSignal in
                let name: String
                switch receivedSignal {
                case SIGABRT:  name = "SIGABRT (abort/assertion)"
                case SIGILL:   name = "SIGILL (illegal instruction)"
                case SIGSEGV:  name = "SIGSEGV (bad memory access)"
                case SIGFPE:   name = "SIGFPE (arithmetic error/overflow)"
                case SIGBUS:   name = "SIGBUS (bus error)"
                case SIGTRAP:  name = "SIGTRAP (fatalError/precondition)"
                default:       name = "signal \(receivedSignal)"
                }
                let stack = Thread.callStackSymbols.prefix(20).joined(separator: "\n  ")
                AppLogger.lifecycle.critical("Fatal signal: \(name)\nStack:\n  \(stack)")
                // Re-raise so the OS can generate the standard crash report
                signal(receivedSignal, SIG_DFL)
                raise(receivedSignal)
            }
        }
    }
}
