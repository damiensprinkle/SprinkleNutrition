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
    @Published var showAlert = false
    
    var workoutManager: WorkoutManager
    var appViewModel: AppViewModel

    init(workoutManager: WorkoutManager, appViewModel: AppViewModel) {
        self.workoutManager = workoutManager
        self.appViewModel = appViewModel
    }
    
    func loadWorkouts() {
        workoutManager.loadWorkoutsWithId()
        workouts = workoutManager.workouts
        
        updateActiveSession()
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

    func deleteWorkout(_ workoutId: UUID) {
        workoutManager.deleteWorkout(for: workoutId)
        loadWorkouts()
    }

    func duplicateWorkout(_ workoutId: UUID) {
        workoutManager.duplicateWorkout(originalWorkoutId: workoutId)
        loadWorkouts()
    }
}
