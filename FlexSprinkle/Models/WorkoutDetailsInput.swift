//
//  WorkoutDetailsInput.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/7/24.
//

import SwiftUI

struct WorkoutDetailInput {
    var id: UUID? // Optional, as it might not exist for new details
    var exerciseId: UUID? // required, as it might not exist for new details
    var exerciseName: String = "" //name of the exericse
    var isCardio: Bool = false  //boolean to determine if exercise is cardio
    var orderIndex: Int32 = 0 // order of exercise
    var sets: [SetInput] = []
}

struct SetInput: Identifiable {
    var id: UUID? // Make sure this property exists to match your function's expectations
    var reps: Int32
    var weight: Int32
    var time: Int32
    var distance: Float
    
    // Initialize with default values
    init(id: UUID? = nil, reps: Int32 = 0, weight: Int32 = 0, time: Int32 = 0, distance: Float = 0) {
        self.id = id
        self.reps = reps
        self.weight = weight
        self.time = time
        self.distance = distance
    }
}
