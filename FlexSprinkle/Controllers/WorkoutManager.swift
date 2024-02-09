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
            }
        }
    }
    
    @Published var workouts: [WorkoutInfo] = []
    
    
    // MARK: Core Data Operations
    
    //good
    func addWorkoutDetail(workoutTitle: String, exerciseName: String, reps: Int32, weight: Int32, color: String, isCardio: Bool, exerciseTime: String) {
        guard let context = self.context else { return }
        
        let workout = findOrCreateWorkout(withTitle: workoutTitle, color: color)
        
        // Create and configure a new WorkoutDetail instance
        let newExerciseDetail = WorkoutDetail(context: context)
        newExerciseDetail.exerciseId = UUID()
        newExerciseDetail.exerciseName = exerciseName
        newExerciseDetail.reps = reps
        newExerciseDetail.weight = weight
        newExerciseDetail.isCardio = isCardio
        newExerciseDetail.exerciseTime = exerciseTime
        
        // Associate the new exercise detail with the workout
        workout.addToDetails(newExerciseDetail)
        
        
        saveContext()
        print("Workout ID: \(String(describing: workout.id)), Exercise Created with ID: \(String(describing: newExerciseDetail.exerciseId))")
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
    
    
    
    //good?
    func loadWorkoutsWithId() {
        guard let context = self.context else {
            print("Context is nil in loadWorkoutsWithId")
            return
        }
        
        let request = NSFetchRequest<Workouts>(entityName: "Workouts")
        do {
            let results = try context.fetch(request)
            // Assuming WorkoutDetail has a unique id and a name property. Adjust as necessary.
            self.workouts = results.map { WorkoutInfo(id: $0.id!, name: $0.name!) } // Make sure to safely unwrap optionals as needed
            
            // Log each loaded workout for more insights
            for workout in self.workouts {
                print("Workout ID: \(workout.id), Name: \(workout.name)")
                
            }
            
            print("Total Loaded workouts: \(self.workouts.count)")
        } catch {
            print("Failed to fetch workouts: \(error)")
        }
    }
    
    func fetchWorkoutColor(for title: String) -> [Workouts] {
        guard let context = self.context else { return [] }
        
        let request = NSFetchRequest<Workouts>(entityName: "Workouts")
        request.predicate = NSPredicate(format: "name == %@", title)
        do {
            
            return try context.fetch(request)
        } catch {
            print("Failed to fetch workout details: \(error)")
            return []
        }
    }
    
    
    
    
    
    func fetchWorkoutDetails(for title: String) -> [WorkoutDetail] {
        guard let context = self.context else { return [] }
        
        let request = NSFetchRequest<WorkoutDetail>(entityName: "WorkoutDetail")
        request.predicate = NSPredicate(format: "name == %@", title)
        do {
            
            return try context.fetch(request)
        } catch {
            print("Failed to fetch workout details: \(error)")
            return []
        }
    }
    
    func fetchWorkoutDetailsByWorkoutId(for workoutID: UUID) -> [WorkoutDetail] {
        guard let context = self.context else {
            print("Context is nil")
            return []
        }
        
        // Assuming 'WorkoutDetail' has a relationship to 'Workouts' entity named 'workout'
        // And 'Workouts' entity has an 'id' attribute
        let request = NSFetchRequest<WorkoutDetail>(entityName: "WorkoutDetail")
        request.predicate = NSPredicate(format: "workout.id == %@", workoutID as CVarArg)
        
        do {
            let details = try context.fetch(request)
            print("Fetched \(details.count) workout details for workoutID \(workoutID)")
            // Log each fetched detail for more insights
            details.forEach { detail in
                print("Exercise ID: \(String(describing: detail.exerciseId)), Name: \(detail.exerciseName ?? ""), Reps: \(detail.reps), Weight: \(detail.weight), IsCardio: \(detail.isCardio), ExerciseTime: \(detail.exerciseTime ?? "")")
            }
            return details
        } catch {
            print("Failed to fetch workout details: \(error)")
            return []
        }
    }
    
    
    
    
    
    func deleteWorkout(for workoutId: UUID) {
        guard let context = self.context else { return }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Workouts")
        fetchRequest.predicate = NSPredicate(format: "id == %@", workoutId as CVarArg)
        
        do {
            let workoutsToDelete = try context.fetch(fetchRequest) as? [Workouts] ?? []
            
            for workout in workoutsToDelete {
                context.delete(workout)
            }
            
            try context.save()
            print("Workout and its details deleted successfully")
        } catch let error as NSError {
            print("Error deleting workout: \(error), \(error.userInfo)")
        }
    }
    
    
    
    func saveOrUpdateWorkoutHistory(workoutId: UUID, exerciseId: UUID, exerciseName: String, reps: String?, weight: String?, exerciseTime: String?) {
        guard let context = self.context else { return }

        // Fetch the active session for the given workout
        let sessionRequest: NSFetchRequest<WorkoutSession> = WorkoutSession.fetchRequest()
        sessionRequest.predicate = NSPredicate(format: "isActive == %@ AND workoutsR.id == %@", NSNumber(value: true), workoutId as CVarArg)

        do {
            if let activeSession = try context.fetch(sessionRequest).first {
                // Now find the WorkoutDetail within this session that matches the exerciseId
                if let details = activeSession.workoutDetails as? Set<WorkoutDetail>,
                   let detailToUpdate = details.first(where: { $0.exerciseId == exerciseId }) {
                    
                    // Update the WorkoutDetail with the new values
                    detailToUpdate.reps = Int32(reps ?? "") ?? 0
                    detailToUpdate.weight = Int32(weight ?? "") ?? 0
                    detailToUpdate.exerciseTime = exerciseTime
                    
                    // Save the context if there are changes
                    if context.hasChanges {
                        try context.save()
                    }
                } else {
                    // If no existing detail matches, create a new WorkoutDetail and associate it with the session
                    let newDetail = WorkoutDetail(context: context)
                    newDetail.id = UUID()
                    newDetail.exerciseId = exerciseId
                    newDetail.exerciseName = exerciseName
                    newDetail.reps = Int32(reps ?? "") ?? 0
                    newDetail.weight = Int32(weight ?? "") ?? 0
                    newDetail.isCardio = !(exerciseTime?.isEmpty ?? true) // Assuming cardio if exerciseTime is set
                    newDetail.exerciseTime = exerciseTime
                    newDetail.sessions = activeSession // Associate the new detail with the session
                    
                    try context.save()
                }
            }
        } catch {
            print("Failed to save or update workout history: \(error)")
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
    
    func loadTemporaryWorkoutData(for workoutId: UUID, exerciseId: UUID) -> (reps: String, weight: String, exerciseTime: String) {
        guard let context = self.context else { return ("", "", "") }

        let sessionRequest: NSFetchRequest<WorkoutSession> = WorkoutSession.fetchRequest()
        sessionRequest.predicate = NSPredicate(format: "isActive == %@ AND workoutsR.id == %@", NSNumber(value: true), workoutId as CVarArg)

        do {
            if let activeSession = try context.fetch(sessionRequest).first {
                // Fetch the WorkoutDetail that matches the given exerciseId within the active session
                if let details = activeSession.workoutDetails as? Set<WorkoutDetail>,
                   let matchingDetail = details.first(where: { $0.exerciseId == exerciseId }) {
                    // Return the existing values from the matching detail
                    return (String(matchingDetail.reps), String(matchingDetail.weight), matchingDetail.exerciseTime ?? "")
                }
            }
        } catch {
            print("Failed to load temporary workout history: \(error)")
        }
        
        // Return default empty values if no matching detail is found or in case of an error
        return ("", "", "")
    }

    
    
    func updateWorkoutDetails(workoutId: UUID, workoutDetailsInput: [WorkoutDetailInput]) {
        guard let context = self.context else { return }
        guard let workout = fetchWorkoutById(for: workoutId) else {
            print("Failed to fetch workout with ID \(workoutId)")
            return
        }
        
        // Assuming `fetchWorkoutById` returns a `Workout?`
        let existingDetails = workout.details as? Set<WorkoutDetail> ?? []
        let existingDetailsMap = existingDetails.reduce(into: [UUID: WorkoutDetail]()) { result, detail in
            if let exerciseId = detail.exerciseId {
                result[exerciseId] = detail
            }
        }
        
        var newDetails: [WorkoutDetail] = []
        
        for input in workoutDetailsInput {
            if let detail = existingDetailsMap[input.exerciseId ?? UUID()] {
                // Update existing detail
                detail.exerciseName = input.exerciseName
                detail.reps = Int32(input.reps) ?? 0
                detail.weight = Int32(input.weight) ?? 0
                detail.isCardio = input.isCardio
                detail.exerciseTime = input.exerciseTime
            } else {
                // Add new detail
                let newDetail = WorkoutDetail(context: context)
                newDetail.exerciseId = input.exerciseId ?? UUID()
                newDetail.exerciseName = input.exerciseName
                newDetail.reps = Int32(input.reps) ?? 0
                newDetail.weight = Int32(input.weight) ?? 0
                newDetail.isCardio = input.isCardio
                newDetail.exerciseTime = input.exerciseTime
                newDetail.workoutR = workout
                newDetails.append(newDetail)
            }
        }
        
        // Remove details not present in input
        let inputIds = Set(workoutDetailsInput.compactMap { $0.exerciseId })
        existingDetails.forEach { detail in
            if let id = detail.exerciseId, !inputIds.contains(id) {
                context.delete(detail)
            }
        }
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Error updating workout details: \(error), \(error.userInfo)")
        }
    }
}


extension WorkoutManager {
    func fetchRequestForWorkoutDetail(withID id: UUID) -> NSFetchRequest<WorkoutDetail> {
        let request = NSFetchRequest<WorkoutDetail>(entityName: "WorkoutDetail")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return request
    }
    
    func titleExists(_ title: String) -> Bool {
        guard let context = self.context else { return false }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "WorkoutDetail")
        // Update predicate to compare names case-insensitively
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
    
    // Checks if there are any active sessions
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
            // Fetch the active session
            if let activeSession = try context.fetch(request).first {
                // Directly access the related workout entity to fetch the workout ID
                return activeSession.workoutsR?.id
            }
        } catch {
            print("Error fetching active sessions: \(error)")
        }
        
        return nil
    }
    
    func getWorkoutNameOfActiveSession() -> String? {
        guard let context = self.context else { return "" }
        let request = NSFetchRequest<WorkoutSession>(entityName: "WorkoutSession")
        
        request.predicate = NSPredicate(format: "isActive == %@", NSNumber(value: true))
        
        do {
            // Fetch the active session
            if let activeSession = try context.fetch(request).first {
                // Directly access the related workout entity to fetch the workout ID
                return activeSession.workoutsR?.name
            }
        } catch {
            print("Error fetching active sessions: \(error)")
        }
        
        return ""
    }


    func setSessionStatus(workoutId: UUID, isActive: Bool) {
        guard let context = self.context else { return }
        
        let workoutRequest = NSFetchRequest<Workouts>(entityName: "Workouts")
        workoutRequest.predicate = NSPredicate(format: "id == %@", workoutId as CVarArg)

        do {
            if let workout = try context.fetch(workoutRequest).first {
                if isActive {
                    // Starting a new session
                    let newSession = WorkoutSession(context: context)
                    newSession.id = UUID()
                    newSession.workoutsR = workout // Link the session to the workout
                    newSession.startTime = Date()
                    newSession.isActive = true
                    workout.sessions = newSession // Ensure the workout points to this new session
                } else {
                    // Ending the existing session associated with the workout
                    if let existingSession = workout.sessions, existingSession.isActive {
                        existingSession.isActive = false
                        existingSession.endTime = Date()
                    }
                }
                
                try context.save()
            }
        } catch {
            // Handle errors
            print("Error setting session status: \(error)")
        }
    }



     // Gets details for a specific session
     func getSessionDetails(for sessionId: UUID) -> WorkoutSession? {
         guard let context = self.context else { return nil }
         let request = NSFetchRequest<WorkoutSession>(entityName: "WorkoutSession")
         request.predicate = NSPredicate(format: "id == %@", sessionId as CVarArg)
         
         do {
             return try context.fetch(request).first
         } catch {
             print("Error fetching session details: \(error)")
             return nil
         }
     }

}
