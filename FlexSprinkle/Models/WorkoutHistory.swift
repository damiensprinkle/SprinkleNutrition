//
//  WorkoutHistory.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/7/24.
//

import Foundation
import CoreData

@objc(WorkoutHistory)
public class WorkoutHistory: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var workoutId: UUID  //id associated with WorkoutDetail.ID
    @NSManaged public var repsCompleted: Int32  //reps completed for all exercises combined
    @NSManaged public var workoutDate: Date //date completed
    @NSManaged public var workoutTimeToComplete: String // timer that will track how long workout takes
    @NSManaged public var totalWeightLifted: Int32 // weight * reps
    @NSManaged public var reps: Int32 //reps  tracked per exercise
    @NSManaged public var weight: Int32 //weight tracker per exercise
    @NSManaged public var exerciseName: String //weight tracker per exercise
    @NSManaged public var detail: WorkoutDetail? // For inverse relationship
    @NSManaged public var workoutCompleted: Bool
    @NSManaged public var exerciseTime: String

}
