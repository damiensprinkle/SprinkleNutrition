//
//  WorkoutDetail+CoreDataProperties.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/14/24.
//
//

import Foundation
import CoreData


extension WorkoutDetail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutDetail> {
        return NSFetchRequest<WorkoutDetail>(entityName: "WorkoutDetail")
    }

    @NSManaged public var exerciseId: UUID?
    @NSManaged public var exerciseName: String?
    @NSManaged public var id: UUID?
    @NSManaged public var isCardio: Bool
    @NSManaged public var orderIndex: Int32
    @NSManaged public var history: WorkoutHistory?
    @NSManaged public var sessions: WorkoutSession?
    @NSManaged public var sets: NSSet?
    @NSManaged public var workoutR: Workouts?

}

// MARK: Generated accessors for sets
extension WorkoutDetail {

    @objc(addSetsObject:)
    @NSManaged public func addToSets(_ value: WorkoutSet)

    @objc(removeSetsObject:)
    @NSManaged public func removeFromSets(_ value: WorkoutSet)

    @objc(addSets:)
    @NSManaged public func addToSets(_ values: NSSet)

    @objc(removeSets:)
    @NSManaged public func removeFromSets(_ values: NSSet)

}

extension WorkoutDetail : Identifiable {

}
