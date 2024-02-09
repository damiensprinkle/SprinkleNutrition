//
//  WorkoutDetail+CoreDataProperties.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/9/24.
//
//

import Foundation
import CoreData


extension WorkoutDetail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutDetail> {
        return NSFetchRequest<WorkoutDetail>(entityName: "WorkoutDetail")
    }

    @NSManaged public var color: String?
    @NSManaged public var exerciseName: String?
    @NSManaged public var id: UUID?
    @NSManaged public var reps: Int32
    @NSManaged public var weight: Int32
    @NSManaged public var isCardio: Bool
    @NSManaged public var exerciseTime: String?
    @NSManaged public var exerciseId: UUID?
    @NSManaged public var workoutR: Workouts?
    @NSManaged public var sessions: WorkoutSession?

}

extension WorkoutDetail : Identifiable {

}
