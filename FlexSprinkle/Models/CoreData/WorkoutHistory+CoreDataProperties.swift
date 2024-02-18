//
//  WorkoutHistory+CoreDataProperties.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/17/24.
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
    @NSManaged public var totalDistance: Float
    @NSManaged public var workoutDate: Date?
    @NSManaged public var workoutTimeToComplete: String?
    @NSManaged public var details: NSSet?
    @NSManaged public var workoutR: Workouts?
    @NSManaged public var detailsTemp: TemporaryWorkoutDetail?

}

// MARK: Generated accessors for details
extension WorkoutHistory {

    @objc(addDetailsObject:)
    @NSManaged public func addToDetails(_ value: WorkoutDetail)

    @objc(removeDetailsObject:)
    @NSManaged public func removeFromDetails(_ value: WorkoutDetail)

    @objc(addDetails:)
    @NSManaged public func addToDetails(_ values: NSSet)

    @objc(removeDetails:)
    @NSManaged public func removeFromDetails(_ values: NSSet)

}

extension WorkoutHistory : Identifiable {

}
