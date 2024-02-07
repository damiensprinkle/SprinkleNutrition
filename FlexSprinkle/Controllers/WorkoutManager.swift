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
    
    func addWorkoutDetail(workoutTitle: String, exerciseName: String, reps: Int32, weight: Int32, color: String) {
        guard let context = self.context else { return }
        print("Adding workout detail: \(workoutTitle), Exercise: \(exerciseName), Reps: \(reps), Weight: \(weight)")
        
        let newDetail = WorkoutDetail(context: context)
        newDetail.id = UUID()
        newDetail.name = workoutTitle
        newDetail.exerciseName = exerciseName
        newDetail.reps = reps
        newDetail.weight = weight
        newDetail.color = color
        
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
}
