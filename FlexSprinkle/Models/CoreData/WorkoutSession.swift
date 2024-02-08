//
//  WorkoutSession.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/8/24.
//

import Foundation
import CoreData

@objc(WorkoutSession)
public class WorkoutSession: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var workoutId: UUID  //id associated with WorkoutDetail.ID
    @NSManaged public var startTime: Date
    @NSManaged public var endTime: Date?
    @NSManaged public var isActive: Bool
    @NSManaged public var workoutDetails: NSSet? // relationship to workoutDetails

}
