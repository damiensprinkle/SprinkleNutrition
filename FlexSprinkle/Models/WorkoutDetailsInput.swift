//
//  WorkoutDetailsInput.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/7/24.
//

import SwiftUI

struct WorkoutDetailInput {
    var name: String = "" // name of the workout plan
    var id: UUID? // Optional, as it might not exist for new details
    var exerciseName: String = "" //name of the exericse
    var reps: String = "" //reps for exercise if isCardio = false
    var weight: String = "" //reps for exercise if isCardio = false
    var isCardio: Bool = false  //boolean to determine if exercise is cardio
    var exerciseTime: String = "" //time used if isCardio = true
}
