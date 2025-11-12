//
//  WorkoutManager.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/5/24.
//

import Foundation
import CoreData

class WorkoutManager: ObservableObject, WorkoutManaging {
    var context: NSManagedObjectContext? {
        didSet {
            print("Context set in WorkoutManager")
            if let context = context {
                loadWorkoutsWithId()
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                // Automatically merge changes from background contexts
                context.automaticallyMergesChangesFromParent = true
            }
        }
    }

    @Published var workouts: [WorkoutInfo] = []
    var errorHandler: ErrorHandler?

    // MARK: - Background Context Helpers

    /// Creates a background context for performing heavy operations off the main thread
    private func createBackgroundContext() -> NSManagedObjectContext? {
        guard let context = self.context else { return nil }

        let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = context
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return backgroundContext
    }

    /// Saves a background context and propagates changes to parent context
    private func saveBackgroundContext(_ backgroundContext: NSManagedObjectContext, completion: @escaping (Result<Void, CoreDataError>) -> Void) {
        backgroundContext.perform {
            do {
                if backgroundContext.hasChanges {
                    try backgroundContext.save()
                }

                // Save parent context on main thread
                DispatchQueue.main.async { [weak self] in
                    guard let self = self, let mainContext = self.context else {
                        completion(.failure(.contextNotAvailable))
                        return
                    }

                    do {
                        if mainContext.hasChanges {
                            try mainContext.save()
                        }
                        completion(.success(()))
                    } catch {
                        completion(.failure(.saveFailed(error)))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.saveFailed(error)))
                }
            }
        }
    }
    
    
    // MARK: Core Data Operations
    
    func addWorkoutDetail(id: UUID, workoutTitle: String, exerciseName: String, color: String , orderIndex: Int32, sets: [SetInput], exerciseMeasurement: String, exerciseQuantifier: String) {
        guard let context = self.context else { return }

        let workout = findOrCreateWorkout(withTitle: workoutTitle, color: color)

        // Create and configure a new WorkoutDetail instance
        let newExerciseDetail = WorkoutDetail(context: context)
        newExerciseDetail.id = id
        newExerciseDetail.exerciseId = UUID()
        newExerciseDetail.exerciseName = exerciseName
        newExerciseDetail.orderIndex = orderIndex
        newExerciseDetail.exerciseQuantifier = exerciseQuantifier
        newExerciseDetail.exerciseMeasurement = exerciseMeasurement
        print("\(exerciseName):  \(orderIndex)")
        // Add sets to the exercise detail
        for setInput in sets {
            let newSet = WorkoutSet(context: context)
            newSet.id = UUID()
            newSet.reps = setInput.reps
            newSet.weight = setInput.weight
            newSet.time = setInput.time
            newSet.distance = setInput.distance
            newSet.setIndex = setInput.setIndex
            newExerciseDetail.addToSets(newSet)
        }

        workout.addToDetails(newExerciseDetail)

        let result = saveContext()
        switch result {
        case .success:
            print("Workout ID: \(String(describing: workout.id)), Exercise Created with ID: \(String(describing: newExerciseDetail.exerciseId))")
        case .failure(let error):
            print("Error saving workout: \(error.localizedDescription)")
            errorHandler?.handle(error)
        }
    }
    
    func saveOrUpdateSetsDuringActiveWorkout(workoutId: UUID, exerciseId: UUID, exerciseName: String, setsInput: [SetInput], orderIndex: Int32) {
        guard let context = self.context else {
            errorHandler?.handle(.contextNotAvailable)
            return
        }

        // Fetch the Workout entity directly
        let workoutRequest: NSFetchRequest<Workouts> = Workouts.fetchRequest()
        workoutRequest.predicate = NSPredicate(format: "id == %@", workoutId as CVarArg)

        do {
            guard let workout = try context.fetch(workoutRequest).first else {
                print("No workout found with ID: \(workoutId)")
                errorHandler?.handle(.workoutNotFound(workoutId))
                return
            }

            if let tempDetails = workout.detailsTemp as? Set<TemporaryWorkoutDetail> {
                // Check if there's an existing detail for this exercise

                let detailToUpdate: TemporaryWorkoutDetail
                if let existingDetail = tempDetails.first(where: { $0.exerciseId == exerciseId }) {
                    context.refresh(existingDetail, mergeChanges: true) // Refresh the object
                    detailToUpdate = existingDetail
                } else {
                    // Create a new TemporaryWorkoutDetail
                    detailToUpdate = TemporaryWorkoutDetail(context: context)
                    detailToUpdate.id = UUID()
                    detailToUpdate.exerciseId = exerciseId
                    detailToUpdate.exerciseName = exerciseName
                    detailToUpdate.orderIndex = orderIndex
                    workout.addToDetailsTemp(detailToUpdate)
                }

                // Update or add sets to the detail
                updateOrAddSetsForTempDetail(forDetail: detailToUpdate, withSetsInput: setsInput, inContext: context)

                if context.hasChanges {
                    try context.save()
                }
            }
        } catch {
            print("Failed to save or update temporary workout details: \(error)")
            errorHandler?.handle(.saveFailed(error))
        }
    }
    
    private func updateOrAddSetsForTempDetail(forDetail tempDetail: TemporaryWorkoutDetail, withSetsInput setsInput: [SetInput], inContext context: NSManagedObjectContext) {
        let existingSets = tempDetail.sets as? Set<WorkoutSet> ?? Set()
        
        setsInput.forEach { setInput in
            let set: WorkoutSet
            if let existingSet = existingSets.first(where: { $0.id == setInput.id }) {
                set = existingSet
            } else {
                set = WorkoutSet(context: context)
                tempDetail.addToSets(set)
            }
            
            set.id = setInput.id ?? UUID()
            set.reps = setInput.reps
            set.weight = setInput.weight
            set.time = setInput.time
            set.distance = setInput.distance
            set.isCompleted = setInput.isCompleted
            set.setIndex = setInput.setIndex
        }
    }
    
    func deleteAllTemporaryWorkoutDetails() {
        guard let context = self.context else {
            errorHandler?.handle(.contextNotAvailable)
            return
        }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TemporaryWorkoutDetail.fetchRequest()

        // Create a batch delete request using the fetch request
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs

        do {
            let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
            let objectIDArray = result?.result as? [NSManagedObjectID]
            let changes = [NSDeletedObjectsKey: objectIDArray]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes as [AnyHashable : Any], into: [context])

            context.refreshAllObjects()
        } catch let error as NSError {
            print("Error deleting all TemporaryWorkoutDetail entities: \(error), \(error.userInfo)")
            errorHandler?.handle(.deleteFailed(error))
        }
    }
    
    private func saveContext() -> Result<Void, CoreDataError> {
        guard let context = self.context else {
            return .failure(.contextNotAvailable)
        }

        guard context.hasChanges else {
            return .success(()) // No changes to save
        }

        do {
            try context.save()
            loadWorkoutsWithId()
            return .success(())
        } catch {
            return .failure(.saveFailed(error))
        }
    }
    
    //good
    private func findOrCreateWorkout(withTitle title: String, color: String) -> Workouts {
        guard let context = self.context else {
            preconditionFailure("CoreData context must be available when creating workouts")
        }

        let request = NSFetchRequest<Workouts>(entityName: "Workouts")
        request.predicate = NSPredicate(format: "name == %@", title)

        if let existingWorkout = (try? context.fetch(request))?.first {
            return existingWorkout
        } else {
            let newWorkout = Workouts(context: context)
            newWorkout.id = UUID()
            newWorkout.name = title
            newWorkout.color = color
            return newWorkout
        }
    }
    
    func fetchWorkoutById(for workoutId: UUID) -> Workouts? {
        guard let context = self.context else {
            return nil
        }
        let request = NSFetchRequest<Workouts>(entityName: "Workouts")
        request.predicate = NSPredicate(format: "id == %@", workoutId as CVarArg)
        do {
            let result = try context.fetch(request)
            return result.first
        } catch {
            print("Error fetching workout by ID: \(error)")
            return nil
        }
    }
    
    func duplicateWorkout(originalWorkoutId: UUID, completion: (() -> Void)? = nil) {
        guard let backgroundContext = createBackgroundContext() else {
            print("Failed to create background context")
            errorHandler?.handle(.contextNotAvailable)
            completion?()
            return
        }

        // Perform heavy duplication on background thread
        backgroundContext.perform { [weak self] in
            // Fetch original workout in background context
            let fetchRequest: NSFetchRequest<Workouts> = Workouts.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", originalWorkoutId as CVarArg)

            do {
                guard let originalWorkout = try backgroundContext.fetch(fetchRequest).first else {
                    DispatchQueue.main.async {
                        print("Failed to fetch original workout with ID \(originalWorkoutId)")
                        self?.errorHandler?.handle(.workoutNotFound(originalWorkoutId))
                        completion?()
                    }
                    return
                }

                let newWorkout = Workouts(context: backgroundContext)
                newWorkout.id = UUID()
                newWorkout.name = "\(originalWorkout.name ?? "")-copy"
                newWorkout.color = originalWorkout.color

                // Copy all details from the original workout to the new workout
                if let originalDetails = originalWorkout.details as? Set<WorkoutDetail> {
                    for originalDetail in originalDetails {
                        let newDetail = WorkoutDetail(context: backgroundContext)
                        newDetail.id = UUID()
                        newDetail.exerciseId = UUID()
                        newDetail.exerciseName = originalDetail.exerciseName
                        newDetail.orderIndex = originalDetail.orderIndex
                        newDetail.exerciseQuantifier = originalDetail.exerciseQuantifier
                        newDetail.exerciseMeasurement = originalDetail.exerciseMeasurement

                        // Copy all sets from the original detail to the new detail
                        if let originalSets = originalDetail.sets as? Set<WorkoutSet> {
                            for originalSet in originalSets {
                                let newSet = WorkoutSet(context: backgroundContext)
                                newSet.id = UUID()
                                newSet.reps = originalSet.reps
                                newSet.weight = originalSet.weight
                                newSet.time = originalSet.time
                                newSet.distance = originalSet.distance
                                newSet.setIndex = originalSet.setIndex
                                newDetail.addToSets(newSet)
                            }
                        }

                        newWorkout.addToDetails(newDetail)
                    }
                }

                // Save background context
                try backgroundContext.save()

                // Save parent context on main thread
                DispatchQueue.main.async {
                    guard let mainContext = self?.context else {
                        completion?()
                        return
                    }
                    do {
                        if mainContext.hasChanges {
                            try mainContext.save()
                        }
                        print("Successfully duplicated workout with ID: \(originalWorkoutId)")
                        completion?()
                    } catch {
                        print("Error saving main context: \(error.localizedDescription)")
                        self?.errorHandler?.handle(.saveFailed(error))
                        completion?()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("Error duplicating workout: \(error.localizedDescription)")
                    self?.errorHandler?.handle(.saveFailed(error))
                    completion?()
                }
            }
        }
    }
    
    
    
    func loadWorkoutsWithId() {
        guard let context = self.context else {
            print("Context is nil in loadWorkoutsWithId")
            errorHandler?.handle(.contextNotAvailable)
            return
        }

        let request = NSFetchRequest<Workouts>(entityName: "Workouts")
        do {
            let results = try context.fetch(request)
            self.workouts = results.compactMap { workout in
                guard let id = workout.id, let name = workout.name else {
                    print("Warning: Skipping workout with missing id or name")
                    return nil
                }
                return WorkoutInfo(id: id, name: name)
            }

            for workout in self.workouts {
                print("Workout ID: \(workout.id), Name: \(workout.name)")

            }

            print("Total Loaded workouts: \(self.workouts.count)")
        } catch {
            print("Failed to fetch workouts: \(error)")
            errorHandler?.handle(.fetchFailed(error))
        }
    }
    
    
    func deleteWorkout(for workoutId: UUID) {
        guard let backgroundContext = createBackgroundContext() else {
            errorHandler?.handle(.contextNotAvailable)
            return
        }

        // Perform heavy delete operation on background thread
        backgroundContext.perform { [weak self] in
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Workouts")
            fetchRequest.predicate = NSPredicate(format: "id == %@", workoutId as CVarArg)

            do {
                let workoutsToDelete = try backgroundContext.fetch(fetchRequest) as? [Workouts] ?? []

                guard !workoutsToDelete.isEmpty else {
                    DispatchQueue.main.async {
                        self?.errorHandler?.handle(.workoutNotFound(workoutId))
                    }
                    return
                }

                for workout in workoutsToDelete {
                    // Cascade delete rules will automatically handle:
                    // - WorkoutHistory (history relationship)
                    // - WorkoutDetail (details relationship) and their WorkoutSets
                    // - TemporaryWorkoutDetail (detailsTemp relationship) and their WorkoutSets
                    // - WorkoutSession (sessions relationship)
                    backgroundContext.delete(workout)
                }

                // Save background context
                try backgroundContext.save()

                // Save parent context on main thread
                DispatchQueue.main.async {
                    guard let mainContext = self?.context else { return }
                    do {
                        if mainContext.hasChanges {
                            try mainContext.save()
                        }
                        print("Workout and its associated entities deleted successfully (cascade)")
                    } catch {
                        print("Error saving main context: \(error)")
                        self?.errorHandler?.handle(.deleteFailed(error))
                    }
                }
            } catch let error as NSError {
                DispatchQueue.main.async {
                    print("Error deleting workout: \(error), \(error.userInfo)")
                    self?.errorHandler?.handle(.deleteFailed(error))
                }
            }
        }
    }
    
    
    func deleteWorkoutHistory(for historyId: UUID) {
        guard let context = self.context else {
            errorHandler?.handle(.contextNotAvailable)
            return
        }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "WorkoutHistory")
        fetchRequest.predicate = NSPredicate(format: "id == %@", historyId as CVarArg)

        do {
            let workoutsToDelete = try context.fetch(fetchRequest) as? [WorkoutHistory] ?? []

            for workout in workoutsToDelete {
                context.delete(workout)
            }

            try context.save()
            print("Workout history deleted successfully")
        } catch let error as NSError {
            print("Error deleting workout history: \(error), \(error.userInfo)")
            errorHandler?.handle(.deleteFailed(error))
        }
    }
    
    func updateWorkoutTitle(workoutId: UUID, to newTitle: String) {
        guard let context = self.context else {
            errorHandler?.handle(.contextNotAvailable)
            return
        }

        // Fetch WorkoutDetail by ID
        let request = NSFetchRequest<Workouts>(entityName: "Workouts")
        request.predicate = NSPredicate(format: "id == %@", workoutId as CVarArg)
        do {
            let results = try context.fetch(request)

            guard !results.isEmpty else {
                errorHandler?.handle(.workoutNotFound(workoutId))
                return
            }

            results.forEach { detail in
                detail.name = newTitle
            }

            try context.save()

            // Update the local workouts array
            if let index = workouts.firstIndex(where: { $0.id == workoutId }) {
                workouts[index].name = newTitle
            }

            // Notify observers of the change
            objectWillChange.send()
        } catch {
            print("Error updating workout title: \(error)")
            errorHandler?.handle(.saveFailed(error))
        }
    }
    
    
    func updateWorkoutColor(workoutId: UUID, color: String) {
        guard let context = self.context else {
            errorHandler?.handle(.contextNotAvailable)
            return
        }

        guard let workout = fetchWorkoutById(for: workoutId) else {
            print("Failed to fetch workout for ID \(workoutId)")
            errorHandler?.handle(.workoutNotFound(workoutId))
            return
        }

        workout.color = color
        do {
            try context.save()
        } catch {
            print("Error saving context after updating workout color: \(error)")
            errorHandler?.handle(.saveFailed(error))
        }
    }
    
    
    
    
    func updateWorkoutDetails(workoutId: UUID, workoutDetailsInput: [WorkoutDetailInput]) {
        guard let context = self.context else {
            errorHandler?.handle(.contextNotAvailable)
            return
        }

        guard let workout = fetchWorkoutById(for: workoutId) else {
            print("Failed to fetch workout for ID \(workoutId)")
            errorHandler?.handle(.workoutNotFound(workoutId))
            return
        }

        let existingDetails = workout.details as? Set<WorkoutDetail> ?? Set()
        let existingDetailsMap = existingDetails.reduce(into: [UUID: WorkoutDetail]()) { result, detail in
            if let exerciseId = detail.exerciseId {
                result[exerciseId] = detail
            }
        }

        workoutDetailsInput.forEach { inputDetail in
            let detail: WorkoutDetail
            if let exerciseId = inputDetail.exerciseId, let existingDetail = existingDetailsMap[exerciseId] {
                detail = existingDetail
            } else {
                detail = WorkoutDetail(context: context)
                workout.addToDetails(detail)
                detail.exerciseId = inputDetail.exerciseId ?? UUID()
            }

            detail.exerciseName = inputDetail.exerciseName
            detail.orderIndex = inputDetail.orderIndex
            detail.exerciseQuantifier = inputDetail.exerciseQuantifier
            detail.exerciseMeasurement = inputDetail.exerciseMeasurement
            updateOrAddSets(forDetail: detail, withSetsInput: inputDetail.sets, inContext: context)
        }

        existingDetails.forEach { existingDetail in
            if !workoutDetailsInput.contains(where: { $0.exerciseId == existingDetail.exerciseId }) {
                if let sets = existingDetail.sets as? Set<WorkoutSet> {
                    sets.forEach { context.delete($0) }
                }
                context.delete(existingDetail)
            }
        }

        do {
            try context.save()
        } catch {
            print("Error saving context after updating workout details: \(error)")
            errorHandler?.handle(.saveFailed(error))
        }
    }
    
    private func updateOrAddSets(forDetail detail: WorkoutDetail, withSetsInput setsInput: [SetInput], inContext context: NSManagedObjectContext) {
        let existingSets = detail.sets as? Set<WorkoutSet> ?? Set()
        
        setsInput.forEach { setInput in
            let set: WorkoutSet
            if let existingSet = existingSets.first(where: { $0.id == setInput.id }) {
                set = existingSet
            } else {
                set = WorkoutSet(context: context)
                detail.addToSets(set)
            }
            
            set.id = setInput.id ?? UUID()
            set.reps = setInput.reps
            set.weight = setInput.weight
            set.time = setInput.time
            set.distance = setInput.distance
            set.setIndex = setInput.setIndex
        }
        
        existingSets.forEach { existingSet in
            if !setsInput.contains(where: { $0.id == existingSet.id }) {
                context.delete(existingSet)
            }
        }
    }
}

extension WorkoutManager {
    
    func titleExists(_ title: String) -> Bool {
        guard let context = self.context else { return false }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Workouts")
        request.predicate = NSPredicate(format: "name ==[c] %@", title)
        request.includesSubentities = false
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("Error checking title existence: \(error)")
            return false
        }
    }
    
    func getSessions() -> [WorkoutSession] {
        guard let context = self.context else { return [] }
        let request = NSFetchRequest<WorkoutSession>(entityName: "WorkoutSession")
        request.predicate = NSPredicate(format: "isActive == %@", NSNumber(value: true))
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching active sessions: \(error)")
            return []
        }
    }
    
    func getWorkoutIdOfActiveSession() -> UUID? {
        guard let context = self.context else { return nil }
        let request = NSFetchRequest<WorkoutSession>(entityName: "WorkoutSession")
        
        request.predicate = NSPredicate(format: "isActive == %@", NSNumber(value: true))
        
        do {
            if let activeSession = try context.fetch(request).first {
                return activeSession.workoutsR?.id
            }
        } catch {
            print("Error fetching active sessions: \(error)")
        }
        
        return nil
    }
    
    func loadTemporaryWorkoutData(for workoutId: UUID) -> [WorkoutDetailInput] {
        guard let context = self.context else { return [] }
        
        let workoutRequest: NSFetchRequest<Workouts> = Workouts.fetchRequest()
        workoutRequest.predicate = NSPredicate(format: "id == %@", workoutId as CVarArg)
        
        do {
            guard let workout = try context.fetch(workoutRequest).first else {
                print("No workout found with ID: \(workoutId)")
                return []
            }
            
            if let tempDetails = workout.detailsTemp as? Set<TemporaryWorkoutDetail> {
                return tempDetails.sorted(by: { $0.orderIndex < $1.orderIndex }).map { tempDetail in
                    let sets = tempDetail.sets?.allObjects as? [WorkoutSet] ?? []
                    return WorkoutDetailInput(
                        id: tempDetail.id,
                        exerciseId: tempDetail.exerciseId,
                        exerciseName: tempDetail.exerciseName ?? "",
                        orderIndex: tempDetail.orderIndex,
                        sets: sets.map { SetInput(id: $0.id, reps: $0.reps, weight: $0.weight, time: $0.time, distance: $0.distance, isCompleted: $0.isCompleted, setIndex: $0.setIndex) }
                    )
                }
            }
        } catch {
            print("Failed to load temporary workout data: \(error)")
        }
        
        return []
    }
    
    func saveWorkoutHistory(workoutId: UUID, dateCompleted: Date, totalWeightLifted: Float, repsCompleted: Int32, workoutTimeToComplete: String, totalCardioTime: String, totalDistance: Float, workoutDetailsInput: [WorkoutDetailInput], completion: (() -> Void)? = nil) {
        guard let backgroundContext = createBackgroundContext() else {
            errorHandler?.handle(.contextNotAvailable)
            completion?()
            return
        }

        // Perform heavy save operation on background thread
        backgroundContext.perform { [weak self] in
            // Fetch workout in background context
            let fetchRequest: NSFetchRequest<Workouts> = Workouts.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", workoutId as CVarArg)

            do {
                guard let workout = try backgroundContext.fetch(fetchRequest).first else {
                    DispatchQueue.main.async {
                        self?.errorHandler?.handle(.workoutNotFound(workoutId))
                        completion?()
                    }
                    return
                }

                let history = WorkoutHistory(context: backgroundContext)
                history.id = UUID()
                history.workoutDate = dateCompleted
                history.totalWeightLifted = totalWeightLifted
                history.repsCompleted = repsCompleted
                history.workoutTimeToComplete = workoutTimeToComplete
                history.totalDistance = totalDistance
                history.timeDoingCardio = totalCardioTime
                history.workoutR = workout

                for detailInput in workoutDetailsInput {
                    let detail = WorkoutDetail(context: backgroundContext)
                    detail.id = detailInput.id ?? UUID()
                    detail.exerciseId = detailInput.exerciseId
                    detail.exerciseName = detailInput.exerciseName
                    detail.orderIndex = detailInput.orderIndex
                    detail.history = history
                    detail.exerciseQuantifier = detailInput.exerciseQuantifier
                    detail.exerciseMeasurement = detailInput.exerciseMeasurement

                    for setInput in detailInput.sets {
                        let set = WorkoutSet(context: backgroundContext)
                        set.id = setInput.id ?? UUID()
                        set.reps = setInput.reps
                        set.weight = setInput.weight
                        set.time = setInput.time
                        set.distance = setInput.distance
                        set.details = detail
                    }
                }

                // Save background context
                try backgroundContext.save()

                // Save parent context on main thread
                DispatchQueue.main.async {
                    guard let mainContext = self?.context else {
                        completion?()
                        return
                    }
                    do {
                        if mainContext.hasChanges {
                            try mainContext.save()
                        }
                        print("Workout history saved successfully")
                        completion?()
                    } catch {
                        print("Failed to save main context: \(error)")
                        self?.errorHandler?.handle(.saveFailed(error))
                        completion?()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("Failed to save workout history: \(error)")
                    self?.errorHandler?.handle(.saveFailed(error))
                    completion?()
                }
            }
        }
    }
    
    func fetchLatestWorkoutHistory(for workoutId: UUID) -> WorkoutHistory? {
        guard let context = self.context else { return nil }
        
        let fetchRequest: NSFetchRequest<WorkoutHistory> = WorkoutHistory.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "workoutR.id == %@", workoutId as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "workoutDate", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            let histories = try context.fetch(fetchRequest)
            return histories.first
        } catch {
            print("Failed to fetch latest workout history: \(error)")
            return nil
        }
    }
    
    func fetchAllWorkoutHistory(for date: Date) -> [WorkoutHistory]? {
        guard let context = self.context else { return nil }
        // Calculate the start and end of the month for the provided date
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: date)))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, second: -1), to: startOfMonth)!
        print(startOfMonth)
        print(endOfMonth)
        let fetchRequest: NSFetchRequest<WorkoutHistory> = WorkoutHistory.fetchRequest()
        // Create a predicate to filter workouts within the start and end of the month
        fetchRequest.predicate = NSPredicate(format: "(workoutDate >= %@) AND (workoutDate <= %@)", argumentArray: [startOfMonth, endOfMonth])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "workoutDate", ascending: true)]
        
        do {
            let histories = try context.fetch(fetchRequest)
            return histories
        } catch {
            print("Failed to fetch workout history: \(error)")
            return nil
        }
    }
    
    func setSessionStatus(workoutId: UUID, isActive: Bool) {
        guard let context = self.context else { return }
        
        let workoutRequest = NSFetchRequest<Workouts>(entityName: "Workouts")
        workoutRequest.predicate = NSPredicate(format: "id == %@", workoutId as CVarArg)
        
        do {
            if let workout = try context.fetch(workoutRequest).first {
                context.refresh(workout, mergeChanges: true)
                if isActive {
                    let newSession = WorkoutSession(context: context)
                    newSession.id = UUID()
                    newSession.workoutsR = workout
                    newSession.startTime = Date()
                    newSession.isActive = true
                    workout.sessions = newSession
                } else {
                    if let existingSession = workout.sessions, existingSession.isActive {
                        existingSession.isActive = false
                        existingSession.endTime = Date()
                    }
                }
                
                try context.save()
            }
        } catch {
            print("Error setting session status: \(error)")
        }
    }
}
