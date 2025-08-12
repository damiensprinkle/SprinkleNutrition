//
//  UserInfo+CoreDataProperties.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 8/12/25.
//
//

import Foundation
import CoreData


extension UserInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserInfo> {
        return NSFetchRequest<UserInfo>(entityName: "UserInfo")
    }

    @NSManaged public var name: String?

}

extension UserInfo : Identifiable {

}
