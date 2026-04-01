import SwiftUI
import CoreData
import CloudKit

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
        if inMemory {
            container = NSPersistentContainer(name: "Model", managedObjectModel: Self.managedObjectModel)
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
            container.loadPersistentStores { _, error in
                if let error = error as NSError? {
                    AppLogger.coreData.error("CoreData in-memory error: \(error), \(error.userInfo)")
                }
            }
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            isLoaded = true
            return
        }

        let cloudContainer = NSPersistentCloudKitContainer(name: "Model", managedObjectModel: Self.managedObjectModel)
        container = cloudContainer

        // Configure automatic migration and CloudKit sync
        let description = cloudContainer.persistentStoreDescriptions.first
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true
        let cloudKitOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.com.damiensprinkle.Soleus"
        )
        description?.cloudKitContainerOptions = cloudKitOptions

        DispatchQueue.global(qos: .userInitiated).async {
            self.container.loadPersistentStores { (storeDescription, error) in
                DispatchQueue.main.async {
                    if let error = error as NSError? {
                        AppLogger.coreData.error("CoreData error: \(error), \(error.userInfo)")
                        self.loadError = error
                        // Still set isLoaded so app can show error UI instead of hanging
                        self.isLoaded = true
                    } else {
                        self.container.viewContext.automaticallyMergesChangesFromParent = true
                        AppLogger.coreData.info("CoreData loaded successfully")
                        self.isLoaded = true
                    }
                }
            }
        }
    }
    
    
    func loadPersistentStores(completion: @escaping (Bool) -> Void) {
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                AppLogger.coreData.error("Unresolved error \(error), \(error.userInfo)")
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
