//
//  WorkoutHistory+CoreDataProperties.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/14/24.
//
//

import Foundation
import CoreData


extension WorkoutHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutHistory> {
        return NSFetchRequest<WorkoutHistory>(entityName: "WorkoutHistory")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var repsCompleted: Int32
    @NSManaged public var timeDoingCardio: String?
    @NSManaged public var totalWeightLifted: Int32
    @NSManaged public var workoutDate: Date?
    @NSManaged public var workoutTimeToComplete: String?
    @NSManaged public var details: WorkoutDetail?
    @NSManaged public var workoutR: Workouts?
    @NSManaged public var detailsTemp: TemporaryWorkoutDetail?

}

extension WorkoutHistory : Identifiable {

}
