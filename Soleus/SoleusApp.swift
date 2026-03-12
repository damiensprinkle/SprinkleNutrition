//
//  SoleusApp.swift
//  Soleus
//
//  Created by Damien Sprinkle on 2/2/24.
//

import SwiftUI
import CoreData

@main
struct SoleusApp: App {
    @StateObject private var persistenceController: PersistenceController
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var workoutManager = WorkoutManager()
    @StateObject private var controller: WorkoutTrackerController
    @StateObject private var errorHandler = ErrorHandler()
    @StateObject private var achievementManager = AchievementManager()
    @State private var importedWorkout: ShareableWorkout?
    @State private var showImportPreview = false


    init() {
        let isUITesting = CommandLine.arguments.contains("--uitesting")
        _persistenceController = StateObject(wrappedValue: isUITesting ? PersistenceController.forUITesting : PersistenceController.shared)

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
                .errorAlert(errorHandler)
                .onAppear() {
                    // Initialize CoreData context for managers
                    if workoutManager.context == nil {
                        workoutManager.context = persistenceController.container.viewContext
                    }
                    // Link achievement manager to workout manager
                    achievementManager.workoutManager = workoutManager

                    #if DEBUG
                    // Inject a test workout for UI testing the import preview
                    if let jsonString = ProcessInfo.processInfo.environment["UI_TEST_IMPORT_WORKOUT"],
                       let data = jsonString.data(using: .utf8),
                       let workout = ShareableWorkout.import(from: data) {
                        importedWorkout = workout
                        showImportPreview = true
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
                    handleImportedFile(url)
                }
                .sheet(isPresented: $showImportPreview) {
                    if let workout = importedWorkout {
                        ImportWorkoutPreviewView(shareableWorkout: workout, isPresented: $showImportPreview)
                            .environmentObject(controller)
                    }
                }
        }
    }

    private func handleImportedFile(_ url: URL) {
        // Ensure the file is a .soleus file
        guard url.pathExtension == "soleus" else {
            AppLogger.lifecycle.warning("Invalid file type: \(url.pathExtension)")
            return
        }

        // Access security-scoped resource
        guard url.startAccessingSecurityScopedResource() else {
            AppLogger.lifecycle.error("Failed to access security-scoped resource")
            return
        }

        defer {
            url.stopAccessingSecurityScopedResource()
        }

        do {
            let data = try Data(contentsOf: url)

            if let workout = ShareableWorkout.import(from: data) {
                importedWorkout = workout
                showImportPreview = true
            } else {
                AppLogger.lifecycle.error("Failed to decode workout data")
            }
        } catch {
            AppLogger.lifecycle.error("Error reading file: \(error.localizedDescription)")
        }
    }
}
