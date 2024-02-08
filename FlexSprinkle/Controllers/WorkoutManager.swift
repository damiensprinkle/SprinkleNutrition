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
                loadWorkouts()
            }
        }
    }
    
    @Published var workouts: [String] = []
    
    // MARK: Core Data Operations
    
    func addWorkoutDetail(workoutTitle: String, exerciseName: String, reps: Int32, weight: Int32, color: String, isCardio: Bool, exerciseTime: String) {
        guard let context = self.context else { return }
        print("Adding workout detail: \(workoutTitle), Exercise: \(exerciseName), Reps: \(reps), Weight: \(weight), IsCardio: \(isCardio), ExerciseTime: \(exerciseTime)")
        
        let newDetail = WorkoutDetail(context: context)
        newDetail.id = UUID()
        newDetail.name = workoutTitle
        newDetail.exerciseName = exerciseName
        newDetail.reps = reps
        newDetail.weight = weight
        newDetail.color = color
        newDetail.isCardio = isCardio
        newDetail.exerciseTime = exerciseTime
        
        saveContext()
    }
    
    func loadWorkouts() {
        guard let context = self.context else {
            print("Context is nil in loadWorkouts")
            return
        }
        
        let request = NSFetchRequest<WorkoutDetail>(entityName: "WorkoutDetail")
        do {
            let results = try context.fetch(request)
            self.workouts = Set(results.map { $0.name }).sorted()
            print("Loaded workouts: \(self.workouts)")
        } catch {
            print("Failed to fetch workouts: \(error)")
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

    
    
    func deleteWorkoutDetails(for title: String) {
        guard let context = self.context else { return }
        
        let detailsToDelete = fetchWorkoutDetails(for: title)
        for detail in detailsToDelete {
            context.delete(detail)
        }
        saveContext()
    }
    
    private func saveContext() {
        guard let context = self.context else { return }
        
        do {
            try context.save()
            loadWorkouts()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    func updateWorkoutTitle(from originalTitle: String, to newTitle: String) {
        guard let context = self.context else { return }
        
        let request = NSFetchRequest<WorkoutDetail>(entityName: "WorkoutDetail")
        request.predicate = NSPredicate(format: "name == %@", originalTitle)
        do {
            let results = try context.fetch(request)
            results.forEach { detail in
                detail.name = newTitle
            }
            
            try context.save()
            
            // Update the local workouts array if necessary
            if let index = workouts.firstIndex(of: originalTitle) {
                workouts[index] = newTitle
            } else {
                workouts.append(newTitle)
            }
        } catch let error as NSError {
            print("Error updating workout title: \(error), \(error.userInfo)")
        }
        saveContext()
        
    }
    
    
    func updateWorkoutDetails(for originalTitle: String, withNewTitle newTitle: String, workoutDetailsInput: [WorkoutDetailInput]) {
        guard let context = self.context else {
            print("Context is nil, unable to update workout details.")
            return
        }

        // If the workout title has changed, update all associated workout details
        if originalTitle != newTitle {
            let request = NSFetchRequest<WorkoutDetail>(entityName: "WorkoutDetail")
            request.predicate = NSPredicate(format: "name == %@", originalTitle)
            do {
                let existingDetails = try context.fetch(request)
                for detail in existingDetails {
                    detail.name = newTitle // Update the name of existing details
                }
            } catch let error as NSError {
                print("Error updating workout names: \(error), \(error.userInfo)")
            }
        }
        
        // Process input details for updates or new additions
        for input in workoutDetailsInput {
            // Assuming you have a way to fetch a specific WorkoutDetail by ID
            let detail: WorkoutDetail
            if let id = input.id, let fetchedDetail = try? context.fetch(fetchRequestForWorkoutDetail(withID: id)).first {
                detail = fetchedDetail // Found existing detail, prepare it for update
            } else {
                detail = WorkoutDetail(context: context) // No ID or detail not found, create new
                detail.id = UUID() // Assign a new ID if creating a new detail
            }
            detail.name = newTitle
            detail.exerciseName = input.exerciseName
            detail.reps = Int32(input.reps) ?? 0
            detail.weight = Int32(input.weight) ?? 0
            detail.exerciseTime = input.exerciseTime
            detail.isCardio = input.isCardio
            // Assign additional properties as necessary
        }

        // Attempt to save context after all updates
        saveContext()
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
    
    func saveOrUpdateWorkoutHistory(workoutId: UUID, exerciseName: String, reps: String?, weight: String?, exerciseTime: String?) {
        guard let context = self.context else { return }
        
        // Fetch request for an ongoing WorkoutHistory for the given workoutId
        let fetchRequest = NSFetchRequest<WorkoutHistory>(entityName: "WorkoutHistory")
        fetchRequest.predicate = NSPredicate(format: "workoutId == %@ AND workoutCompleted == NO", workoutId as CVarArg)
        
        do {
            let history = try context.fetch(fetchRequest).first ?? WorkoutHistory(context: context)
            history.workoutId = workoutId
            history.id = UUID()
            history.exerciseName = exerciseName  // Assume exerciseName is provided for each TextField update
            history.repsCompleted = Int32(reps ?? "0") ?? 0
            history.totalWeightLifted = Int32(weight ?? "0") ?? 0
            history.exerciseTime = exerciseTime ?? ""
            history.workoutDate = Date()  // Set or update the date to the current session's date
            history.workoutCompleted = false  // Ensure the session is marked as ongoing

            try context.save()
            print("saved successfully")
        } catch {
            print("Failed to save or update workout history: \(error.localizedDescription)")
        }
    }


    
    func completeWorkoutForId(workoutId: UUID) {
        guard let context = self.context else { return }
        
        let fetchRequest = NSFetchRequest<WorkoutHistory>(entityName: "WorkoutHistory")
        fetchRequest.predicate = NSPredicate(format: "workoutId == %@ AND workoutCompleted == NO", workoutId as CVarArg)
        
        do {
            let histories = try context.fetch(fetchRequest)
            histories.forEach { $0.workoutCompleted = true }
            try context.save()
        } catch {
            print("Error marking workout as completed: \(error)")
        }
    }
    
    func loadTemporaryWorkoutData(for workoutId: UUID) -> [String: (reps: String, weight: String, exerciseTime: String)] {
        guard let context = self.context else { return [:] }
        var temporaryData: [String: (reps: String, weight: String, exerciseTime: String)] = [:]
        
        let historyRequest = NSFetchRequest<WorkoutHistory>(entityName: "WorkoutHistory")
        historyRequest.predicate = NSPredicate(format: "workoutId == %@ AND workoutCompleted == NO", workoutId as CVarArg)
        
        do {
            let histories = try context.fetch(historyRequest)
            for history in histories {
                // Use exerciseName as the key instead of detailId
                temporaryData[history.exerciseName] = (reps: String(history.reps), weight: String(history.weight), exerciseTime: history.exerciseTime)
            }
        } catch {
            print("Error loading temporary workout data: \(error)")
        }
        
        return temporaryData
    }




    
    func getWorkoutNameOfActiveSession() -> String {
        guard let context = self.context else { return "" }
        let request = NSFetchRequest<WorkoutSession>(entityName: "WorkoutSession")
        
        request.predicate = NSPredicate(format: "isActive == %@", NSNumber(value: true))
        
        do {
            let details = try context.fetch(request)
            let workoutId = details.first!.workoutId
            let requestName = NSFetchRequest<WorkoutDetail>(entityName: "WorkoutDetail")
            requestName.predicate = NSPredicate(format: "id == %@", workoutId as CVarArg)
            return try context.fetch(requestName).first!.name
        } catch {
            print("Error fetching active sessions: \(error)")
            return ""
        }
    }

    func setSessionStatus(workoutId: UUID, isActive: Bool) {
        guard let context = self.context else { return }

        if isActive {
            // Starting a new session
            let newSession = WorkoutSession(context: context)
            newSession.id = UUID()
            newSession.workoutId = workoutId
            newSession.startTime = Date()
            newSession.isActive = true
            newSession.endTime = nil // Explicitly setting to nil for clarity
        } else {
            // Ending an existing session
            let request = NSFetchRequest<WorkoutSession>(entityName: "WorkoutSession")
            request.predicate = NSPredicate(format: "workoutId == %@ AND isActive == YES", workoutId as CVarArg)
            
            do {
                let sessions = try context.fetch(request)
                if let existingSession = sessions.first {
                    existingSession.isActive = false
                    existingSession.endTime = Date()
                }
            } catch {
                // Handle fetch error
                print("Failed to fetch active session for workoutId: \(workoutId), error: \(error)")
            }
        }

        do {
            try context.save()
        } catch {
            // Handle save error
            print("Failed to save context: \(error)")
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
