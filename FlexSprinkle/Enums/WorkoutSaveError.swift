//
//  WorkoutError.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 11/13/24.
//

enum WorkoutSaveError: Error {
    case emptyTitle, noExerciseDetails, titleExists
}
