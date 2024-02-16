//
//  ColorManager.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/6/24.
//

import SwiftUI

class ColorManager {
    private let colorNames: [String] = ["MyPurple", "MyOffPurple", "MyLightBlue", "MyBlue"]
    
    func getRandomColor() -> String {
        if let randomColorName = colorNames.randomElement() {
            return randomColorName
        } else {
            // Return a default color name if the array is unexpectedly empty
            return "MyBlue"
        }
    }
}
