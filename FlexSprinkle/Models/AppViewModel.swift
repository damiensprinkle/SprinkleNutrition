//
//  AppViewModel.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/10/24.
//

import SwiftUI

class AppViewModel: ObservableObject {
    @Published var currentView: ContentViewType = .main
    @Published var currentTab: Tab = .home // Add this line

    func navigateTo(_ view: ContentViewType) {
         DispatchQueue.main.async {
             self.currentView = view
         }
    }
    
    func resetToWorkoutMainView() {
        DispatchQueue.main.async {
            self.currentTab = .workout 
            self.currentView = .main// Use this to reset tab if needed
        }
    }

    // Update the navigation logic as needed to work with both views and tabs

    enum ContentViewType {
        case main
        case workoutOverview(UUID)
        case workoutActiveView(UUID)
        // Define other views as needed
    }
    
    enum Tab {
         case home
         case workout
         case nutrition
    }
}
