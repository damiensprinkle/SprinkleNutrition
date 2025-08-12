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
    
    func updateUserNameAndUnit(name: String, unit: String) {
        guard let context = self.context else { return }
        
        if let user = userDetails {
            user.name = name
        } else {
            let newUser = UserInfo(context: context)
            newUser.name = name
            userDetails = newUser
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
