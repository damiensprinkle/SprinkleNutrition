//
//  PersistenceController.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/18/24.
//

import SwiftUI
import CoreData

class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    @Published var isLoaded = false

    private init() {
        container = NSPersistentContainer(name: "Model")
        // Move the Core Data loading completely to a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            self.container.loadPersistentStores { (storeDescription, error) in
                if let error = error as NSError? {
                    // Handle error - Consider how to report back
                    print("Unresolved error \(error), \(error.userInfo)")
                    return
                }
                // Mark as loaded or update any state on the main thread
                DispatchQueue.main.async {
                    self.isLoaded = true
                }
            }
        }
    }

    
    func loadPersistentStores(completion: @escaping (Bool) -> Void) {
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // Proper error handling instead of fatalError in production
                print("Unresolved error \(error), \(error.userInfo)")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
}
