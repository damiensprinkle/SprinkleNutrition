//
//  ContentView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/2/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    CustomTabView()
                        .environmentObject(appViewModel)
                }
                
                // Your other content here
            }
        }
    }
}


