//
//  WorkoutTrackerMainView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/3/24.
//

import SwiftUI

struct WorkoutTrackerMainView: View {
    @State private var selectedDate = Date()
    @ObservedObject private var workoutManager = WorkoutManager()
    @State private var isEditWorkoutPresented = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Divider()
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                        CardView(
                            title: "Add",
                            isDefault: true,
                            workoutManager: workoutManager
                        )
                        
                        ForEach(workoutManager.workouts, id: \.self) { workout in
                            let color = workoutManager.fetchWorkoutDetails(for: workout).first?.color
                            CardView(
                                title: workout,
                                isDefault: false,
                                workoutManager: workoutManager,
                                onDelete: {
                                    workoutManager.deleteWorkout(withTitle: workout)
                                },
                                color: color
                            )
                        }
                    }
                    .padding()
                }
            }
            .environmentObject(workoutManager)
        }
    }
}


struct WorkoutTrackerMainView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
        WorkoutTrackerMainView()
    }
}


