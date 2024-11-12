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
    @Published var presentModal: ModalState? = nil // Controls modal presentation

    func navigateTo(_ view: ContentViewType) {
         DispatchQueue.main.async {
             self.currentView = view
         }
    }
    
    func resetToWorkoutMainView() {
        DispatchQueue.main.async {
            self.currentTab = .workout 
            self.currentView = .main
        }
    }

    // Update the navigation logic as needed to work with both views and tabs

    enum ContentViewType : Equatable {
        case main
        case workoutOverview(UUID)
        case workoutActiveView(UUID)
        case workoutHistoryView
    }
    
    enum Tab : Equatable {
         case home
         case workout
         case nutrition
    }
    
    enum ModalState: Identifiable {
        case add
        case edit(workoutId: UUID)
        
        var id: Int {
            switch self {
            case .add:
                return 0
            case .edit(_):
                return 1
            }
        }
    }
}
