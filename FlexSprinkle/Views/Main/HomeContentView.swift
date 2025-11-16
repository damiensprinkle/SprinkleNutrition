//
//  HomeContentView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/10/24.
//

import SwiftUI

// Placeholder views for tab content
struct HomeContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var workoutController: WorkoutTrackerController

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Divider()
                // View Achievements Card
                Button(action: {
                    appViewModel.navigateTo(.achievementsView)
                }) {
                    HStack(spacing: 16) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.staticWhite)
                            .padding(.leading, 8)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Achievements")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.staticWhite)

                            Text("View your progress")
                                .font(.subheadline)
                                .foregroundColor(.staticWhite.opacity(0.9))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.body)
                            .foregroundColor(.staticWhite.opacity(0.7))
                            .padding(.trailing, 8)
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.myTan, Color.myLightBrown]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(15)
                    .shadow(color: Color.myTan.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                Spacer()
            }
        }
        .background(Color.myWhite.ignoresSafeArea())
    }
}
