//
//  WorkoutDetailsInput.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/7/24.
//

import SwiftUI

struct WorkoutDetailInput {
    var name: String = ""
    var id: UUID? // Optional, as it might not exist for new details
    var exerciseName: String = ""
    var reps: String = ""
    var weight: String = ""
}

