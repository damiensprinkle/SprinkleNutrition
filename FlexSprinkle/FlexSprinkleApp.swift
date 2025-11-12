//
//  FlexSprinkleApp.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/2/24.
//

import SwiftUI
import CoreData

@main
struct FlexSprinkleApp: App {
    @StateObject private var persistenceController = PersistenceController.shared
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var workoutManager = WorkoutManager()
    @StateObject private var userManager = UserManager()
    @StateObject private var controller: WorkoutTrackerController
    @StateObject private var errorHandler = ErrorHandler()


    init() {
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
                .environmentObject(userManager)
                .environmentObject(errorHandler)
                .errorAlert(errorHandler)
                .onAppear() {
                    // Initialize CoreData context for managers
                    if workoutManager.context == nil {
                        workoutManager.context = persistenceController.container.viewContext
                    }
                    if userManager.context == nil {
                        userManager.context = persistenceController.container.viewContext
                    }
                }
        }
    }
}
