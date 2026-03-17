import SwiftUI

struct CustomTabView: View {
    @State private var selectedTab: Tab = .workout
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var workoutController: WorkoutTrackerController


    enum Tab: String {
        case dashboard, workout, settings
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                tabContent
                    .navigationTitle(navigationTitle)
                    .navigationBarTitleDisplayMode(.inline)
                    .id(selectedTab)

                Divider()

                HStack {
                    tabButton(for: .workout, systemImage: "dumbbell.fill")
                        .accessibilityIdentifier(AccessibilityID.tabWorkout)

                    Spacer()
                    tabButton(for: .dashboard, systemImage: "chart.bar.fill")
                        .accessibilityIdentifier(AccessibilityID.tabDashboard)

                    Spacer()
                    tabButton(for: .settings, systemImage :"gearshape")
                        .accessibilityIdentifier(AccessibilityID.tabSettings)
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
        // Prevent the NavigationView from resizing when the keyboard appears.
        // Without this, keyboard dismissal can leave the tab bar stranded mid-screen.
        .ignoresSafeArea(.keyboard)
    }

    @ViewBuilder
    private var tabContent: some View {
        Group {
            switch selectedTab {
            case .workout:
                WorkoutContentMainView()
                    .environmentObject(workoutController)
                    .transition(.opacity)
            case .dashboard:
                dashboardContent
                    .environmentObject(workoutController)
                    .transition(.opacity)
            case .settings:
                SettingsView()
                    .transition(.opacity)
            }
        }
        .animation(.default, value: selectedTab)
    }

    @ViewBuilder
    private var dashboardContent: some View {
        Group {
            switch appViewModel.currentView {
            case .achievementsView:
                AchievementsView()
                    .environmentObject(appViewModel)
                    .transition(.opacity)
            default:
                DashboardView()
                    .environmentObject(appViewModel)
                    .transition(.opacity)
            }
        }
        .animation(.default, value: appViewModel.currentView)
    }

    private var navigationTitle: String {
        switch selectedTab {
        case .workout:
            return ""
        case .dashboard:
            if appViewModel.currentView == .achievementsView {
                return "Achievements"
            }
            return "Dashboard"
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
