//
//  WorkoutSession+CoreDataProperties.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/10/24.
//
//

import Foundation
import CoreData


extension WorkoutSession {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutSession> {
        return NSFetchRequest<WorkoutSession>(entityName: "WorkoutSession")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var isActive: Bool
    @NSManaged public var startTime: Date?
    @NSManaged public var endTime: Date?
    @NSManaged public var workoutsR: Workouts?
    @NSManaged public var workoutDetails: NSSet?

}

// MARK: Generated accessors for workoutDetails
extension WorkoutSession {

    @objc(addWorkoutDetailsObject:)
    @NSManaged public func addToWorkoutDetails(_ value: WorkoutDetail)

    @objc(removeWorkoutDetailsObject:)
    @NSManaged public func removeFromWorkoutDetails(_ value: WorkoutDetail)

    @objc(addWorkoutDetails:)
    @NSManaged public func addToWorkoutDetails(_ values: NSSet)

    @objc(removeWorkoutDetails:)
    @NSManaged public func removeFromWorkoutDetails(_ values: NSSet)

}

extension WorkoutSession : Identifiable {

}
