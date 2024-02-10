//
//  CustomTABVIEW.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/10/24.
//

import SwiftUI

struct CustomTabView: View {
    @State private var selectedTab: Tab = .home
    @EnvironmentObject var appViewModel: AppViewModel

    enum Tab: String {
        case home, workout, nutrition
    }

    var body: some View {
        VStack(spacing: 0) { // Ensure there's no spacing between content and the tab bar
            // Content based on selected tab
            switch selectedTab {
            case .home:
                HomeContentView().navigationTitle("Home")
            case .workout:
                WorkoutContentMainView().navigationTitle("Workout Tracker")
            case .nutrition:
                NutritionHelperMainView().navigationTitle("Nutrition Helper")
            }

            Spacer() // Pushes the tab bar to the bottom

            // Custom Tab Bar
            HStack {
                // Home Tab Button
                tabButton(for: .home, systemImage: "house.fill")
                
                Spacer()
                
                // Workout Tab Button
                tabButton(for: .workout, systemImage: "dumbbell.fill")
                
                Spacer()
                
                // Nutrition Tab Button
                tabButton(for: .nutrition, systemImage: "leaf.fill")
            }
            .padding()
            .background(Color.gray.opacity(0.1)) // Customize as needed
            .edgesIgnoringSafeArea(.bottom) // Ensure it extends into the safe area
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure VStack takes full screen size
    }

    @ViewBuilder
    private func tabButton(for tab: Tab, systemImage: String) -> some View {
        Button(action: {
            if selectedTab == tab && tab == .workout {
                // Reset workout view if workout tab is re-selected
                appViewModel.resetToWorkoutMainView()
            } else {
                selectedTab = tab
                appViewModel.resetToWorkoutMainView()
            }
        }) {
            Image(systemName: systemImage)
                .imageScale(.large)
                .foregroundColor(selectedTab == tab ? .blue : .gray)
        }
    }
}
