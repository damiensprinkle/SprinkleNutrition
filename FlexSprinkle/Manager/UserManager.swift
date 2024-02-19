//
//  UserManager.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/19/24.
//

import Foundation
import CoreData

class UserManager: ObservableObject {
    var context: NSManagedObjectContext? {
        didSet {
            print("Context set in UserManager")
            if context != nil {
                loadUserDetails()
                context!.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
            }
        }
    }
    
    @Published var userDetails: UserInfo?
    
    func loadUserDetails() {
        guard let context = self.context else { return }

        let request: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
        
        do {
            let results = try context.fetch(request)
            if let firstUser = results.first {
                DispatchQueue.main.async {
                    self.userDetails = firstUser
                }
            } else {
                print("No User Details found.")
            }
        } catch {
            print("Failed to fetch User Details: \(error.localizedDescription)")
        }
    }
    
    func addUser(weight: Int32, height: Int32, age: Int32, gender: String) {
        guard let context = self.context else { return }

        // If a user already exists, update their details
        if let user = userDetails {
            user.weight = weight
            user.height = height
            user.age = age
            user.gender = gender
        } else {
            // No user exists, create a new one
            let newUser = UserInfo(context: context)
            newUser.weight = weight
            newUser.height = height
            newUser.age = age
            newUser.gender = gender
            userDetails = newUser
        }
        
        saveContext()
    }
    
    func editUser(weight: Int32?, height: Int32?, age: Int32?, gender: String?) {

        guard let user = userDetails else { return }
        
        if let weight = weight {
            user.weight = weight
        }
        if let height = height {
            user.height = height
        }
        if let age = age {
            user.age = age
        }
        if let gender = gender {
            user.gender = gender
        }
        
        saveContext()
    }
    
    private func saveContext() {
        guard let context = self.context else { return }
        
        do {
            try context.save()
            loadUserDetails()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

