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
