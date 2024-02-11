//
//  DataCardView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/11/24.
//

import SwiftUI

struct DataCardView: View {
    let icon: Image 
    let number: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            icon
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24) // Adjust size as needed
                .padding(.top, 8)
                .padding(.leading, 8)

            Spacer()

            Text(number)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)

        }
        .frame(width: 160, height: 160) // Adjust card size as needed
        .background(Color.white) // Use any background color
        .cornerRadius(15)
        .shadow(radius: 5) // Optional shadow for depth
        .padding()
    }
}
