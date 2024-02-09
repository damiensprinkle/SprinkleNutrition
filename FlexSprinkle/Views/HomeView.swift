//
//  ContentView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/2/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            NavigationStack {
                Text("Home Content Goes Here")
                    .navigationTitle("Home")
                    .navigationBarItems(trailing: NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .resizable()
                            .imageScale(.large)
                            .foregroundColor(Color.blue)
                    })
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            
            NavigationStack {
                WorkoutTrackerMainView()
                    .navigationTitle("Workout Tracker")
                    .navigationBarItems(trailing: NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .resizable()
                            .imageScale(.large)
                            .foregroundColor(Color.blue)
                    })
            }
            .tabItem {
                Label("Workout", systemImage: "dumbbell.fill")
            }
            
            NavigationStack {
                NutritionHelperMainView()
                    .navigationTitle("Nutrition Helper")
                    .navigationBarItems(trailing: NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .resizable()
                            .imageScale(.large)
                            .foregroundColor(Color.blue)
                    })
            }
            .tabItem {
                Label("Nutrition", systemImage: "leaf.fill")
            }
            
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
