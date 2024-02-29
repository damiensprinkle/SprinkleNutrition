//
//  UserInfo+CoreDataProperties.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/19/24.
//
//

import Foundation
import CoreData


extension UserInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserInfo> {
        return NSFetchRequest<UserInfo>(entityName: "UserInfo")
    }

    @NSManaged public var weight: Int32
    @NSManaged public var height: Int32
    @NSManaged public var gender: String?
    @NSManaged public var age: Int32
    @NSManaged public var activityLevel: String?
    @NSManaged public var bmr: Int32

}

extension UserInfo : Identifiable {

}
