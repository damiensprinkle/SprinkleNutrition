//
//  WorkoutHistory+CoreDataProperties.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/10/24.
//
//

import Foundation
import CoreData


extension WorkoutHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutHistory> {
        return NSFetchRequest<WorkoutHistory>(entityName: "WorkoutHistory")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var workoutDate: Date? // date complted
    @NSManaged public var totalWeightLifted: Int32 //all reps * weight
    @NSManaged public var repsCompleted: Int32 // all reps added together
    @NSManaged public var workoutTimeToComplete: String? // time it took to complet workout
    @NSManaged public var timeDoingCardio: String? // all exercise time added together, will have to convert to int and convert back to string
    @NSManaged public var workoutR: Workouts? //relationship to workouts
    @NSManaged public var details: WorkoutDetail? //relationship to workoutDetail

}

extension WorkoutHistory : Identifiable {

}
