//
//  SetHeaders.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/13/24.
//

import SwiftUI

struct SetHeaders: View {
    let exerciseQuantifier: String
    let exerciseMeasurement: String
    let active: Bool
    @AppStorage("weightPreference") private var weightPreference: String = "Lbs"
    @AppStorage("distancePreference") private var distancePreference: String = "Mile"
    
    
    var body: some View {
        HStack {
            Text("Set").frame(width: 50, alignment: .leading)
            Spacer()
            if(exerciseQuantifier == "Reps") {
                Text("Reps").frame(width: 100)
                Spacer()
            }
            if(exerciseQuantifier == "Distance"){
                Text(distancePreference).frame(width: 100)
                Spacer()
            }
            if(exerciseMeasurement == "Weight"){
                Text(weightPreference).frame(width: 100)

            }
            if(exerciseMeasurement == "Time"){
                Text("Time").frame(width: 100)
            }
            if(active){
                Spacer()
            }
        }
        .font(.headline)
        .padding(.vertical, 5)
    }
}
