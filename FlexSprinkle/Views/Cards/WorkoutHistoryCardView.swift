//
//  WorkoutHistoryCardView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/17/24.
//

import SwiftUI

struct WorkoutHistoryCardView: View {
    var workoutId: UUID
    let history: WorkoutHistory
    var onDelete: (() -> Void)?
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var workoutTitle: String = ""
    @AppStorage("weightPreference") private var weightPreference: String = "Lbs"
    @AppStorage("distancePreference") private var distancePreference: String = "mile"

    @State private var isExpanded: Bool = false // Track whether the card is expanded
    @State private var showAlert: Bool = false // State to track alert visibility
    
    // Date formatter to display the date
    private var formattedDate: String {
        guard let date = history.workoutDate else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(workoutTitle)
                    .font(.title)
                    .lineLimit(1)
                
                Spacer()
                
                Image(systemName: "trash")
                    .resizable()
                    .frame(width: 18, height: 22) // Slightly smaller size
                    .padding(.trailing, 8)
                    .onTapGesture {
                        showAlert = true // Show alert on tap
                    }
            }
            
            Text("Completed: \(formattedDate)")
                .font(.headline)
            
            HStack {
                Image(systemName: "clock")
                Text("\(history.workoutTimeToComplete ?? "0") mins")
                    .font(.subheadline)
                
                Spacer()
                
                Image(systemName: "dumbbell.fill")
                Text("\(history.totalWeightLifted, specifier: "%.2f") \(weightPreference)")
                    .font(.subheadline)
            }
            
            // Exercise Name and Set Count headers with an icon to indicate expandability
            HStack {
                Text("Exercise")
                    .font(.headline)
                    .bold()
                Spacer()
                Text("Details")
                    .font(.headline)
                    .bold()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .onTapGesture {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }
            }
            
            // Display the first exercise, and if expanded, display the rest
            Group {
                Divider()
                if let exercises = history.details?.allObjects as? [WorkoutDetail], !exercises.isEmpty {
                    ForEach(isExpanded ? exercises : Array(exercises.prefix(0)), id: \.self) { detail in
                        exerciseDetailView(detail: detail)
                        Divider()
                    }
                } else {
                    Text("No Exercises Available")
                }
            }
        }
        .padding()
        .onAppear {
            workoutTitle = workoutManager.fetchWorkoutById(for: workoutId)?.name ?? "Workout"
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Confirm Deletion"),
                message: Text("Are you sure you want to delete this workout history?"),
                primaryButton: .destructive(Text("Delete")) {
                    onDelete?()
                },
                secondaryButton: .cancel()
            )
        }
        .frame(maxWidth: .infinity, maxHeight: isExpanded ? .infinity : 250)
        .background(Color.myWhite)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
        .animation(.easeInOut, value: isExpanded)
    }
    
    @ViewBuilder
    private func exerciseDetailView(detail: WorkoutDetail) -> some View {
        HStack {
            Text(detail.exerciseName ?? "Unknown Exercise")
            Spacer()
            if detail.isCardio {
                // Safely calculate totals for cardio exercises
                let totalDistance = (detail.sets?.allObjects as? [WorkoutSet])?.reduce(0.0) { $0 + ($1.distance) } ?? 0.0
                let totalTimeInMinutes = (detail.sets?.allObjects as? [WorkoutSet])?.reduce(0) { $0 + Int($1.time) } ?? 0
                let totalTime = totalTimeInMinutes / 60

                HStack {
                    VStack{
                        Text("Distance:")
                        Text("\(totalDistance, specifier: "%.2f") \(distancePreference)")
                    }
                    VStack{
                        Text("Time:")
                        Text("\(totalTime) mins")
                    }
                }
            } else {
                // Safely calculate totals for non-cardio exercises
                let totalWeight = (detail.sets?.allObjects as? [WorkoutSet])?.reduce(0) { $0 + (Float($1.weight) * Float($1.reps)) } ?? 0

                let totalReps = (detail.sets?.allObjects as? [WorkoutSet])?.reduce(0) { $0 + Int($1.reps) } ?? 0
                HStack {
                    VStack {
                        Text("Reps:")
                        Text("\(totalReps)")
                            .frame(width: 60, alignment: .center)
                    }
                    VStack {
                        Text("Weight:")
                        Text("\(totalWeight, specifier: "%.2f") \(weightPreference)")
                            .frame(width: 100, alignment: .trailing)
                    }
                }
            }
        }
    }

}
