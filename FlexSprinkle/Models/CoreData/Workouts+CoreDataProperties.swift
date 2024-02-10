//
//  Workouts+CoreDataProperties.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/10/24.
//
//

import Foundation
import CoreData


extension Workouts {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Workouts> {
        return NSFetchRequest<Workouts>(entityName: "Workouts")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var color: String?
    @NSManaged public var details: NSSet?
    @NSManaged public var sessions: WorkoutSession?
    @NSManaged public var history: NSSet?

}

// MARK: Generated accessors for details
extension Workouts {

    @objc(addDetailsObject:)
    @NSManaged public func addToDetails(_ value: WorkoutDetail)

    @objc(removeDetailsObject:)
    @NSManaged public func removeFromDetails(_ value: WorkoutDetail)

    @objc(addDetails:)
    @NSManaged public func addToDetails(_ values: NSSet)

    @objc(removeDetails:)
    @NSManaged public func removeFromDetails(_ values: NSSet)

}

// MARK: Generated accessors for history
extension Workouts {

    @objc(addHistoryObject:)
    @NSManaged public func addToHistory(_ value: WorkoutHistory)

    @objc(removeHistoryObject:)
    @NSManaged public func removeFromHistory(_ value: WorkoutHistory)

    @objc(addHistory:)
    @NSManaged public func addToHistory(_ values: NSSet)

    @objc(removeHistory:)
    @NSManaged public func removeFromHistory(_ values: NSSet)

}

extension Workouts : Identifiable {

}
