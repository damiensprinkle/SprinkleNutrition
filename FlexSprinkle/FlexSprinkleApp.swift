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
    let persistenceContainer = NSPersistentContainer(name: "Model")
    @StateObject private var appViewModel = AppViewModel()


    init() {
            if let myBlackColor = UIColor(named: "MyBlack") {
                UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: myBlackColor]
                UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: myBlackColor]
            }

        persistenceContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            HomeView().environment(\.managedObjectContext, persistenceContainer.viewContext)
                .environmentObject(appViewModel)

        }
    }
}
