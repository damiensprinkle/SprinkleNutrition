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
        
        for input in workoutDetailsInput {
            if let id = input.id {
                let request = fetchRequestForWorkoutDetail(withID: id)
                do {
                    let details = try context.fetch(request)
                    if let detail = details.first {
                        // Update the existing detail
                        detail.exerciseName = input.exerciseName
                        detail.reps = Int32(input.reps) ?? 0
                        detail.weight = Int32(input.weight) ?? 0
                    } else {
                        // Create a new detail if no ID or not found
                        let newDetail = WorkoutDetail(context: context)
                        newDetail.id = UUID()
                        newDetail.name = newTitle
                        newDetail.exerciseName = input.exerciseName
                        newDetail.reps = Int32(input.reps) ?? 0
                        newDetail.weight = Int32(input.weight) ?? 0
                    }
                } catch let error as NSError {
                    print("Error fetching workout detail with ID \(id): \(error), \(error.userInfo)")
                }
            } else {
                // Handle the case for adding new details
                let newDetail = WorkoutDetail(context: context)
                newDetail.id = UUID()
                newDetail.name = newTitle
                newDetail.exerciseName = input.exerciseName
                newDetail.reps = Int32(input.reps) ?? 0
                newDetail.weight = Int32(input.weight) ?? 0
            }
        }
        saveContext() // Save changes after all updates are made
    }
    
}

extension WorkoutManager {
    func fetchRequestForWorkoutDetail(withID id: UUID) -> NSFetchRequest<WorkoutDetail> {
        let request = NSFetchRequest<WorkoutDetail>(entityName: "WorkoutDetail")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return request
    }
}
