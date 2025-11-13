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
    @Published var loadError: Error?

    private init() {
        container = NSPersistentContainer(name: "Model")

        // Configure automatic migration
        let description = container.persistentStoreDescriptions.first
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true

        DispatchQueue.global(qos: .userInitiated).async {
            self.container.loadPersistentStores { (storeDescription, error) in
                DispatchQueue.main.async {
                    if let error = error as NSError? {
                        print("CoreData error: \(error), \(error.userInfo)")
                        self.loadError = error
                        // Still set isLoaded so app can show error UI instead of hanging
                        self.isLoaded = true
                    } else {
                        print("CoreData loaded successfully")
                        self.isLoaded = true
                    }
                }
            }
        }
    }
    
    
    func loadPersistentStores(completion: @escaping (Bool) -> Void) {
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
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
