//
//  WorkoutHistory.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/7/24.
//

import Foundation
import CoreData

@objc(WorkoutDetail)
public class WorkoutHistory: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var workoutId: UUID
    @NSManaged public var repsCompleted: Int32
    @NSManaged public var workoutDate: Date
    @NSManaged public var workoutTimeToComplete: String
    @NSManaged public var totalWeightLifted: Int32
    @NSManaged public var detail: WorkoutDetail? // For inverse relationship

}
