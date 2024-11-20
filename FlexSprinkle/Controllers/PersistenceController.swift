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
        DispatchQueue.global(qos: .userInitiated).async {
            self.container.loadPersistentStores { (storeDescription, error) in
                if let error = error as NSError? {
                    print("Unresolved error \(error), \(error.userInfo)")
                    return
                }
                DispatchQueue.main.async {
                    self.isLoaded = true
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
