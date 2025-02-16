//
//  WorkoutManager.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/5/24.
//

import Foundation
import CoreData

class WorkoutManager: ObservableObject {
    var context: NSManagedObjectContext? {
        didSet {
            print("Context set in WorkoutManager")
            if context != nil {
                loadWorkoutsWithId()
                context!.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
            }
        }
    }
    
    @Published var workouts: [WorkoutInfo] = []
    
    
    // MARK: Core Data Operations
    
    //good
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
        
        saveContext()
        print("Workout ID: \(String(describing: workout.id)), Exercise Created with ID: \(String(describing: newExerciseDetail.exerciseId))")
    }
    
    func saveOrUpdateSetsDuringActiveWorkout(workoutId: UUID, exerciseId: UUID, exerciseName: String, setsInput: [SetInput], orderIndex: Int32) {
        guard let context = self.context else { return }
        
        // Fetch the Workout entity directly
        let workoutRequest: NSFetchRequest<Workouts> = Workouts.fetchRequest()
        workoutRequest.predicate = NSPredicate(format: "id == %@", workoutId as CVarArg)
        
        do {
            guard let workout = try context.fetch(workoutRequest).first else {
                print("No workout found with ID: \(workoutId)")
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
        guard let context = self.context else { return }
        
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
        }
    }
    
    private func saveContext() {
        guard let context = self.context else { return }
        
        do {
            try context.save()
            loadWorkoutsWithId()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    //good
    private func findOrCreateWorkout(withTitle title: String, color: String) -> Workouts {
        let request = NSFetchRequest<Workouts>(entityName: "Workouts")
        request.predicate = NSPredicate(format: "name == %@", title)
        
        if let existingWorkout = (try? context?.fetch(request))?.first {
            return existingWorkout
        } else {
            let newWorkout = Workouts(context: context!)
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
    
    func duplicateWorkout(originalWorkoutId: UUID) {
        guard let context = self.context,
              let originalWorkout = fetchWorkoutById(for: originalWorkoutId) else {
            print("Failed to fetch or context is nil for workout ID \(originalWorkoutId)")
            return
        }
        
        let newWorkout = Workouts(context: context)
        newWorkout.id = UUID()
        newWorkout.name = "\(originalWorkout.name ?? "")-copy"
        newWorkout.color = originalWorkout.color
        
        // Copy all details from the original workout to the new workout
        if let originalDetails = originalWorkout.details as? Set<WorkoutDetail> {
            for originalDetail in originalDetails {
                let newDetail = WorkoutDetail(context: context)
                newDetail.exerciseId = UUID()
                newDetail.exerciseName = originalDetail.exerciseName
                newDetail.orderIndex = originalDetail.orderIndex
                newDetail.exerciseQuantifier = originalDetail.exerciseQuantifier
                newDetail.exerciseMeasurement = originalDetail.exerciseMeasurement
                
                // Copy all sets from the original detail to the new detail
                if let originalSets = originalDetail.sets as? Set<WorkoutSet> {
                    for originalSet in originalSets {
                        let newSet = WorkoutSet(context: context)
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
        
        do {
            try context.save()
            print("Successfully duplicated workout with ID: \(originalWorkoutId)")
        } catch {
            print("Error saving context after duplicating workout: \(error)")
        }
    }
    
    
    
    func loadWorkoutsWithId() {
        guard let context = self.context else {
            print("Context is nil in loadWorkoutsWithId")
            return
        }
        
        let request = NSFetchRequest<Workouts>(entityName: "Workouts")
        do {
            let results = try context.fetch(request)
            self.workouts = results.map { WorkoutInfo(id: $0.id!, name: $0.name!) }
            
            for workout in self.workouts {
                print("Workout ID: \(workout.id), Name: \(workout.name)")
                
            }
            
            print("Total Loaded workouts: \(self.workouts.count)")
        } catch {
            print("Failed to fetch workouts: \(error)")
        }
    }
    
    
    func deleteWorkout(for workoutId: UUID) {
        guard let context = self.context else { return }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Workouts")
        fetchRequest.predicate = NSPredicate(format: "id == %@", workoutId as CVarArg)
        
        do {
            let workoutsToDelete = try context.fetch(fetchRequest) as? [Workouts] ?? []
            
            for workout in workoutsToDelete {
                if let workoutHistory = workout.history as? Set<WorkoutHistory> {
                    for history in workoutHistory {
                        context.delete(history)
                    }
                }
                
                if let workoutDetails = workout.details as? Set<WorkoutDetail> {
                    for detail in workoutDetails {
                        context.delete(detail)
                    }
                }
                
                if let tempDetails = workout.detailsTemp as? Set<TemporaryWorkoutDetail> {
                    for tempDetail in tempDetails {
                        context.delete(tempDetail)
                    }
                }
                
                context.delete(workout)
            }
            
            try context.save()
            print("Workout and its associated history, details, and temporary details deleted successfully")
        } catch let error as NSError {
            print("Error deleting workout and its associated entities: \(error), \(error.userInfo)")
        }
    }
    
    
    func deleteWorkoutHistory(for historyId: UUID) {
        guard let context = self.context else { return }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "WorkoutHistory")
        fetchRequest.predicate = NSPredicate(format: "id == %@", historyId as CVarArg)
        
        do {
            let workoutsToDelete = try context.fetch(fetchRequest) as? [WorkoutHistory] ?? []
            
            for workout in workoutsToDelete {
                context.delete(workout)
            }
            
            try context.save()
            print("Workout and its details deleted successfully")
        } catch let error as NSError {
            print("Error deleting workout: \(error), \(error.userInfo)")
        }
    }
    
    func updateWorkoutTitle(workoutId: UUID, to newTitle: String) {
        guard let context = self.context else { return }
        
        // Fetch WorkoutDetail by ID
        let request = NSFetchRequest<Workouts>(entityName: "Workouts")
        request.predicate = NSPredicate(format: "id == %@", workoutId as CVarArg)
        do {
            let results = try context.fetch(request)
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
        }
    }
    
    
    func updateWorkoutColor(workoutId: UUID, color: String) {
        guard let context = self.context, let workout = fetchWorkoutById(for: workoutId) else {
            print("Failed to fetch or context is nil for workout ID \(workoutId)")
            return
        }
        
        workout.color = color
        do {
            try context.save()
        } catch {
            print("Error saving context after updating workout details: \(error)")
        }
    }
    
    
    
    
    func updateWorkoutDetails(workoutId: UUID, workoutDetailsInput: [WorkoutDetailInput]) {
        guard let context = self.context, let workout = fetchWorkoutById(for: workoutId) else {
            print("Failed to fetch or context is nil for workout ID \(workoutId)")
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
                existingDetail.sets?.forEach { context.delete($0 as! NSManagedObject) }
                context.delete(existingDetail)
            }
        }
        
        do {
            try context.save()
        } catch {
            print("Error saving context after updating workout details: \(error)")
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
    
    func saveWorkoutHistory(workoutId: UUID, dateCompleted: Date, totalWeightLifted: Float, repsCompleted: Int32, workoutTimeToComplete: String, totalCardioTime: String, totalDistance: Float, workoutDetailsInput: [WorkoutDetailInput]) {
        guard let context = self.context, let workout = fetchWorkoutById(for: workoutId) else { return }
        
        let history = WorkoutHistory(context: context)
        history.id = UUID()
        history.workoutDate = dateCompleted
        history.totalWeightLifted = totalWeightLifted
        history.repsCompleted = repsCompleted
        history.workoutTimeToComplete = workoutTimeToComplete
        history.totalDistance = totalDistance
        history.timeDoingCardio = totalCardioTime
        history.workoutR = workout
        
        for detailInput in workoutDetailsInput {
            let detail = WorkoutDetail(context: context)
            detail.id = detailInput.id ?? UUID()
            detail.exerciseId = detailInput.exerciseId
            detail.exerciseName = detailInput.exerciseName
            detail.orderIndex = detailInput.orderIndex
            detail.history = history
            detail.exerciseQuantifier = detailInput.exerciseQuantifier
            detail.exerciseMeasurement = detailInput.exerciseMeasurement
            
            for setInput in detailInput.sets {
                let set = WorkoutSet(context: context)
                set.id = setInput.id ?? UUID()
                set.reps = setInput.reps
                set.weight = setInput.weight
                set.time = setInput.time
                set.distance = setInput.distance
                set.details = detail
            }
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save workout history: \(error)")
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
