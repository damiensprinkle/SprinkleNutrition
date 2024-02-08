//
//  File.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/5/24.
//

import Foundation
import CoreData

@objc(WorkoutDetail)
public class WorkoutDetail: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var exerciseName: String
    @NSManaged public var reps: Int32
    @NSManaged public var weight: Int32
    @NSManaged public var color: String
    @NSManaged public var histories: NSSet? // For one-to-many relationship
    @NSManaged public var isCardio: Bool
    @NSManaged public var exerciseTime: String
}
