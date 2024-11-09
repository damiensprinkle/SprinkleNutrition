//
//  CustomTabViews.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/10/24.
//

import SwiftUI

struct CustomTabView: View {
    @State private var selectedTab: Tab = .home
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var workoutManager = WorkoutManager()
    @EnvironmentObject var userManager: UserManager

    
    enum Tab: String {
        case home, workout, nutrition, settings
    }
    
    var body: some View {
        VStack(spacing: 0) {
            switch selectedTab {
            case .home:
                HomeContentView().navigationTitle("Home")
                    .environmentObject(workoutManager);
            case .workout:
                WorkoutContentMainView()
                    .environmentObject(workoutManager)

            case .nutrition:
                NutritionHelperMainView().navigationTitle("Nutrition Helper")
            case .settings:
                SettingsView()
                    .environmentObject(userManager)
            }
            
            Spacer()
            
            HStack {
                tabButton(for: .home, systemImage: "house.fill")
                
                Spacer()
                tabButton(for: .workout, systemImage: "dumbbell.fill")
                
                Spacer()
                tabButton(for: .nutrition, systemImage: "leaf.fill")
                
                Spacer()
                tabButton(for: .settings, systemImage :"gearshape")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .edgesIgnoringSafeArea(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private func tabButton(for tab: Tab, systemImage: String) -> some View {
        Button(action: {
            if selectedTab == tab && tab == .workout {
                appViewModel.resetToWorkoutMainView()
            } else {
                selectedTab = tab
                appViewModel.resetToWorkoutMainView() //
            }
        }) {
            Image(systemName: systemImage)
                .imageScale(.large)
                .foregroundColor(selectedTab == tab ? .blue : .gray)
        }
    }
}
