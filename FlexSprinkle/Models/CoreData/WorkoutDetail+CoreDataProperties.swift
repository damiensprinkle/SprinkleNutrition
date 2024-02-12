//
//  WorkoutDetail+CoreDataProperties.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/12/24.
//
//

import Foundation
import CoreData


extension WorkoutDetail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutDetail> {
        return NSFetchRequest<WorkoutDetail>(entityName: "WorkoutDetail")
    }

    @NSManaged public var color: String?
    @NSManaged public var exerciseId: UUID?
    @NSManaged public var exerciseName: String?
    @NSManaged public var exerciseTime: String?
    @NSManaged public var id: UUID?
    @NSManaged public var isCardio: Bool
    @NSManaged public var orderIndex: Int32

    @NSManaged public var reps: Int32
    @NSManaged public var weight: Int32
    @NSManaged public var history: WorkoutHistory?
    @NSManaged public var sessions: WorkoutSession?
    @NSManaged public var workoutR: Workouts?

}

extension WorkoutDetail : Identifiable {

}
