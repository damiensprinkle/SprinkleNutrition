//
//  WorkoutTrackerMainController.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 11/12/24.
//

import Foundation
import SwiftUI

class WorkoutTrackerController: ObservableObject {
    @Published var workouts: [WorkoutInfo] = []
    @Published var hasActiveSession = false
    @Published var activeWorkoutName: String?
    @Published var activeWorkoutId: UUID?
    @Published var activeSessionId : UUID?
    @Published var workoutDetails: [WorkoutDetailInput] = []
    @Published var selectedWorkoutName: String?
    private let colorManager = ColorManager()
    
    var workoutManager: WorkoutManager

    init(workoutManager: WorkoutManager) {
        self.workoutManager = workoutManager
    }
    
    func loadWorkouts() {
        workoutManager.loadWorkoutsWithId()
        workouts = workoutManager.workouts
        updateActiveSession()
    }
    
    func moveExercise(from source: Int, to destination: Int) {
        guard source >= 0, destination >= 0, source < workoutDetails.count, destination < workoutDetails.count else { return }
        
        let item = workoutDetails.remove(at: source)
        workoutDetails.insert(item, at: destination)
        
        for (index, _) in workoutDetails.enumerated() {
            workoutDetails[index].orderIndex = Int32(index)
        }
    }
    
    func deleteExercise(at index: Int) {
        guard index >= 0, index < workoutDetails.count else { return }
        workoutDetails.remove(at: index)
    }
    
    func renameExercise(at index: Int, to newName: String) {
        guard index >= 0, index < workoutDetails.count else { return }
        workoutDetails[index].exerciseName = newName
    }
    
    func saveWorkout(title: String, update: Bool, workoutId: UUID) -> Result<Void, WorkoutSaveError> {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .failure(.emptyTitle)
        }
        guard !workoutDetails.isEmpty else {
            return .failure(.noExerciseDetails)
        }
        if workoutManager.titleExists(title) && !update {
            return .failure(.titleExists)
        }

        if update {
            updateWorkoutDetails(for: workoutId, for: title)
        } else {
            workoutDetails.forEach { detail in
                workoutManager.addWorkoutDetail(
                    id: detail.id!,
                    workoutTitle: title,
                    exerciseName: detail.exerciseName,
                    color: colorManager.getRandomColor(),
                    orderIndex: Int32(detail.orderIndex),
                    sets: detail.sets,
                    exerciseMeasurement: detail.exerciseMeasurement,
                    exerciseQuantifier: detail.exerciseQuantifier
                )
            }
        }
        loadWorkouts()

        return .success(())
    }

    
    func loadWorkoutDetails(for workoutId: UUID) {
        guard let workout = workoutManager.fetchWorkoutById(for: workoutId) else {
            print("Could not find workout with ID \(workoutId)")
            return
        }

        selectedWorkoutName = workout.name ?? ""
        var workoutDetailsList: [WorkoutDetailInput] = []

        if let detailsSet = workout.details as? Set<WorkoutDetail> {
            let details = detailsSet.sorted { $0.orderIndex < $1.orderIndex }
            workoutDetailsList = details.map { detail in
                let sortedSets = (detail.sets?.allObjects as? [WorkoutSet])?.sorted(by: { $0.setIndex < $1.setIndex }) ?? []
                let setInputs = sortedSets.map { ws in
                    SetInput(id: ws.id, reps: ws.reps, weight: ws.weight, time: ws.time, distance: ws.distance, isCompleted: ws.isCompleted, setIndex: ws.setIndex)
                }

                return WorkoutDetailInput(
                    id: detail.id,
                    exerciseId: detail.exerciseId,
                    exerciseName: detail.exerciseName!,
                    orderIndex: detail.orderIndex,
                    sets: setInputs,
                    exerciseQuantifier: detail.exerciseQuantifier!,
                    exerciseMeasurement: detail.exerciseMeasurement!
                )
            }
        }

        self.workoutDetails = workoutDetailsList
    }
    
    func addSet(for workoutIndex: Int) {
        guard workoutIndex < workoutDetails.count else { return }

        let maxSetIndex = workoutDetails[workoutIndex].sets.max(by: { $0.setIndex < $1.setIndex })?.setIndex ?? 0
        let newSetIndex = maxSetIndex + 1

        let newSet = workoutDetails[workoutIndex].sets.last.map {
            SetInput(reps: $0.reps, weight: $0.weight, time: $0.time, distance: $0.distance, setIndex: newSetIndex)
        } ?? SetInput(reps: 0, weight: 0, time: 0, distance: 0, setIndex: newSetIndex)

        self.workoutDetails[workoutIndex].sets.append(newSet)
    }
    
    func deleteSet(for workoutIndex: Int, setIndex: Int32) {
        guard workoutIndex < workoutDetails.count else { return }
        
        if let setIndexToDelete = workoutDetails[workoutIndex].sets.firstIndex(where: { $0.setIndex == setIndex }) {
            workoutDetails[workoutIndex].sets.remove(at: setIndexToDelete)
        }
    }

    private func updateActiveSession() {
        guard let activeSession = workoutManager.getSessions().first(where: { $0.isActive }) else {
            hasActiveSession = false
            return
        }
        
        hasActiveSession = true
        activeWorkoutId = activeSession.workoutsR?.id
        activeWorkoutName = activeSession.workoutsR?.name
    }
    
    func updateWorkoutDetails(for workoutId: UUID, for workoutTitle: String){
        let filledDetails = workoutDetails.filter { detail in
            guard !detail.exerciseName.isEmpty else { return false }
            guard !detail.exerciseName.isEmpty else { return false }
            
            return !detail.sets.isEmpty
        }
        workoutManager.updateWorkoutDetails(workoutId: workoutId, workoutDetailsInput: filledDetails)
        workoutManager.updateWorkoutTitle(workoutId: workoutId, to: workoutTitle)
    }
    
    func deleteWorkout(_ workoutId: UUID) {
        workoutManager.deleteWorkout(for: workoutId)
        loadWorkouts()
    }
    

    func duplicateWorkout(_ workoutId: UUID) {
        workoutManager.duplicateWorkout(originalWorkoutId: workoutId)
        loadWorkouts()
    }
}
