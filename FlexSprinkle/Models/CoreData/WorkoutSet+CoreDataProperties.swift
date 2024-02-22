//
//  WorkoutSet+CoreDataProperties.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/14/24.
//
//

import Foundation
import CoreData


extension WorkoutSet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutSet> {
        return NSFetchRequest<WorkoutSet>(entityName: "WorkoutSet")
    }

    @NSManaged public var distance: Float
    @NSManaged public var id: UUID?
    @NSManaged public var reps: Int32
    @NSManaged public var setNumber: Int32
    @NSManaged public var time: Int32
    @NSManaged public var weight: Int32
    @NSManaged public var isCompleted: Bool
    @NSManaged public var details: WorkoutDetail?
    @NSManaged public var detailsTemp: TemporaryWorkoutDetail?

}

extension WorkoutSet : Identifiable {

}
