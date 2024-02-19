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
    var body: some View {
        NavigationStack {
            if persistenceController.isLoaded {
                VStack {
                    HStack {
                        CustomTabView()
                            .environmentObject(appViewModel)
                    }
                }
            }
            else{
                Text("loading content")
            }
            
        }
    }
}
