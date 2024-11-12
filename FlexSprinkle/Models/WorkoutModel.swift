//
//  Workout.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 11/12/24.
//

import Foundation

struct WorkoutModel : Identifiable, Equatable {
    var id: UUID
    var name: String
    var isActive: Bool
}
