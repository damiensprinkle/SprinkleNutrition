//
//  File.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/5/24.
//

import Foundation

import Foundation
import SwiftUI

class WorkoutDetail: Identifiable, NSCoding {
    var id = UUID()
    var name: String = ""
    var reps: String = ""
    var weight: String = ""
    var color: String = ""

    // MARK: - NSCoding

    init() {
    }

    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as? UUID ?? UUID()
        name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        reps = aDecoder.decodeObject(forKey: "reps") as? String ?? ""
        weight = aDecoder.decodeObject(forKey: "weight") as? String ?? ""
        color = aDecoder.decodeObject(forKey: "color") as? String ?? "MyBlue"
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(reps, forKey: "reps")
        aCoder.encode(weight, forKey: "weight")
        aCoder.encode(color, forKey: "color")
    }
}

