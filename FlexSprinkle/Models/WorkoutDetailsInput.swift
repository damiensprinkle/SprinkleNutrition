//
//  WorkoutDetailsInput.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/7/24.
//

import SwiftUI

struct WorkoutDetailInput {
    var id: UUID?
    var exerciseId: UUID?
    var exerciseName: String = ""
    var orderIndex: Int32 = 0
    var sets: [SetInput] = []
    var exerciseQuantifier: String = ""
    var exerciseMeasurement: String = ""
}

struct SetInput: Identifiable, Equatable {
    var id: UUID?
    var reps: Int32
    var weight: Float
    var time: Int32
    var distance: Float
    var isCompleted: Bool
    var setIndex: Int32
    var exerciseQuantifier: String
    var exerciseMeasurement: String
    
    // Initialize with default values
    init(id: UUID? = nil, reps: Int32 = 0, weight: Float = 0, time: Int32 = 0, distance: Float = 0, isCompleted: Bool = false, setIndex: Int32 = 0, exerciseQuantifier: String = "", exerciseMeasurement: String = "")
    {
        self.id = id
        self.reps = reps
        self.weight = weight
        self.time = time
        self.distance = distance
        self.isCompleted = isCompleted
        self.setIndex = setIndex
        self.exerciseQuantifier = exerciseQuantifier
        self.exerciseMeasurement = exerciseMeasurement
    }
    
    static func ==(lhs: SetInput, rhs: SetInput) -> Bool {
         return lhs.id == rhs.id
     }
}
