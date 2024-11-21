//
//  ContentView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/2/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var persistenceController: PersistenceController
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var workoutController: WorkoutTrackerController

    @State private var showUserDetailsForm = false
    @AppStorage("optOut") private var optOut: Bool = false

    var body: some View {
        NavigationStack {
            if persistenceController.isLoaded {
                VStack {
                    HStack {
                        CustomTabView()
                            .environmentObject(appViewModel)
                            .environmentObject(userManager)
                            .environmentObject(workoutController)
                    }
                }
                .onAppear {
                    userManager.context = persistenceController.container.viewContext
                    if userManager.userDetails == nil && !optOut {
                        showUserDetailsForm = true
                    }
                }
                .overlay {
                    if showUserDetailsForm && !optOut {
                        UserDetailsFormView(isPresented: $showUserDetailsForm)
                            .environmentObject(userManager)
                    }
                }
            } else {
                Text("Loading content...")
            }
        }
        .onChange(of: userManager.userDetails) {
            if userManager.userDetails != nil || optOut {
                showUserDetailsForm = false
            }
        }
    }
}
