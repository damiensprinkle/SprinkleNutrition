//
//  WorkoutTrackerMainView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/3/24.
//

import SwiftUI
import SwiftData

struct WorkoutTrackerMainView: View {
    @State private var selectedDate = Date()
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var workoutManager = WorkoutManager() // Initialize without context first

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Divider()
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                        CardView(
                            title: "Add",
                            isDefault: true
                        )
                        ForEach(workoutManager.workouts, id: \.self) { workout in
                            CardView(
                                title: workout,
                                isDefault: false,
                                onDelete: {
                                    workoutManager.deleteWorkoutDetails(for: workout)
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
            .onAppear {
                // This ensures the workoutManager is only setup once the viewContext is available.
                if workoutManager.context == nil {
                    workoutManager.context = viewContext
                    workoutManager.loadWorkouts()
                }
            }
        }
         .environmentObject(workoutManager)
    }
}



struct WorkoutTrackerMainView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
        WorkoutTrackerMainView()
    }
}


