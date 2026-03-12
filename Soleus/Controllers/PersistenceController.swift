import SwiftUI
import CoreData

class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    @Published var isLoaded = false
    @Published var loadError: Error?

    static let forUITesting: PersistenceController = PersistenceController(inMemory: true)

    /// Single model instance shared across all containers to prevent the
    /// "Failed to find a unique match for NSEntityDescription" error in tests.
    private static let managedObjectModel: NSManagedObjectModel = {
        let bundles = [Bundle(for: PersistenceController.self)]
        guard let model = NSManagedObjectModel.mergedModel(from: bundles) else {
            fatalError("Failed to load CoreData model")
        }
        return model
    }()

    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model", managedObjectModel: Self.managedObjectModel)

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
            container.loadPersistentStores { _, error in
                if let error = error as NSError? {
                    print("CoreData in-memory error: \(error), \(error.userInfo)")
                }
            }
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            isLoaded = true
            return
        }

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
