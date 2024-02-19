//
//  PersistenceController.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/18/24.
//

import SwiftUI
import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "Model")
    }
    
    func loadPersistentStores(completion: @escaping (Bool) -> Void) {
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            completion(true)
        }
    }
}
