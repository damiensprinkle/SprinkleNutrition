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
    @StateObject var userManager = UserManager()
    
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
                    }
                }
                .onAppear {
                    // Set the context for userManager here
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
        // Use .onChange of userManager.userDetails to hide the form when userDetails are set
        .onChange(of: userManager.userDetails) {
            if userManager.userDetails != nil || optOut {
                showUserDetailsForm = false
            }
        }
    }
}
