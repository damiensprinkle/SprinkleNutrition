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
        Group {
            if persistenceController.isLoaded {
                if let error = persistenceController.loadError {
                    // Show error if CoreData failed to load
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                        Text("Failed to Load Data")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("There was a problem loading your workout data. Try restarting the app.")
                            .multilineTextAlignment(.center)
                            .padding()
                        Text("Error: \(error.localizedDescription)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding()
                    }
                    .padding()
                } else {
                    if userManager.userDetails != nil {
                        VStack {
                            HStack {
                                CustomTabView()
                                    .environmentObject(appViewModel)
                                    .environmentObject(userManager)
                                    .environmentObject(workoutController)
                            }
                        }
                    } else {
                        // Show blank view while waiting for user details
                        Color(.systemGroupedBackground)
                            .ignoresSafeArea()
                    }
                }
            } else {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading...")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            userManager.context = persistenceController.container.viewContext
            // Don't show user form if there was a CoreData error
            if persistenceController.loadError == nil && userManager.userDetails == nil {
                showUserDetailsForm = true
            }
        }
        .overlay {
            if showUserDetailsForm {
                ZStack {
                    Color(.systemGroupedBackground)
                        .ignoresSafeArea()

                    UserDetailsFormView(isPresented: $showUserDetailsForm)
                        .environmentObject(userManager)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
