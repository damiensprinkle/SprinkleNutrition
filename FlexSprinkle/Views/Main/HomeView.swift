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
                    if userManager.userDetails == nil {
                        showUserDetailsForm = true
                    }
                }
            } else {
                Text("That was quick! Getting things ready...")
            }
        }
        .overlay {
            if showUserDetailsForm {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    UserDetailsFormView(isPresented: $showUserDetailsForm)
                        .environmentObject(userManager)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground))
                        .ignoresSafeArea()
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }

        .onChange(of: userManager.userDetails) {
            if userManager.userDetails != nil  {
                showUserDetailsForm = false
            }
        }
    }
}
