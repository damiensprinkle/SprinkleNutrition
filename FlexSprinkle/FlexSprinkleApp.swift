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
    @StateObject private var controller = WorkoutTrackerController(workoutManager: WorkoutManager())

    init() {
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
                .onAppear(){
                    controller.workoutManager.context = persistenceController.container.viewContext
                }
        }
    }
}
