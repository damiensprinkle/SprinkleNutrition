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
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var workoutController: WorkoutTrackerController

    
    enum Tab: String {
        case home, workout, settings
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                tabContent
                    .navigationTitle(navigationTitle)
                    .navigationBarTitleDisplayMode(.inline)
                    .id(selectedTab)

                Spacer(minLength: 0)

                Divider()

                HStack {
                    tabButton(for: .home, systemImage: "house.fill")

                    Spacer()
                    tabButton(for: .workout, systemImage: "dumbbell.fill")

                    Spacer()
                    tabButton(for: .settings, systemImage :"gearshape")
                }
                .padding()
                .background(
                    Color("MyGrey").opacity(0.1)
                        .ignoresSafeArea(.all, edges: .bottom)
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationViewStyle(.stack)
    }

    @ViewBuilder
    private var tabContent: some View {
        Group {
            switch selectedTab {
            case .home:
                HomeContentView()
                    .environmentObject(workoutController)
                    .transition(.opacity)
            case .workout:
                WorkoutContentMainView()
                    .environmentObject(workoutController)
                    .transition(.opacity)
            case .settings:
                SettingsView()
                    .environmentObject(userManager)
                    .transition(.opacity)
            }
        }
        .animation(.default, value: selectedTab)
    }

    private var navigationTitle: String {
        switch selectedTab {
        case .home:
            return "Home"
        case .workout:
            return ""
        case .settings:
            return "Settings"
        }
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
                .foregroundColor(selectedTab == tab ? Color("MyBlue") : Color("MyGrey"))
        }
    }
}
