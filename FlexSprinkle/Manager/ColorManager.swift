//
//  ColorManager.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/6/24.
//

import SwiftUI

class ColorManager {
    
    public let colorNames: [String] = ["MyBabyBlue", "MyLightBlue",  "MyBlue", "MyOrchid", "MyPurple", "MyTan", "MyGreyBlue", "MyLightBrown", "MyBrown"]
    
    func getRandomColor() -> String {
        if let randomColorName = colorNames.randomElement() {
            return randomColorName
        } else {
            return "MyBlue"
        }
    }
}
