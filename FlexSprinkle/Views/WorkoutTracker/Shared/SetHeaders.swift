//
//  SetHeaders.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/13/24.
//

import SwiftUI

struct SetHeaders: View {
    let isCardio: Bool
    @AppStorage("weightPreference") private var weightPreference: String = "Lbs"
    @AppStorage("distancePreference") private var distancePreference: String = "Mile"
    
    
    var body: some View {
        HStack {
            Text("Set").frame(width: 50, alignment: .leading)
            Spacer()
            if isCardio {
                Text(distancePreference).frame(width: 100)
                Spacer()
                Text("Time").frame(width: 100)
            } else {
                Text("Reps").frame(width: 100)
                Spacer()
                Text(weightPreference).frame(width: 100)
            }
        }
        .font(.headline)
        .padding(.vertical, 5)
    }
}
