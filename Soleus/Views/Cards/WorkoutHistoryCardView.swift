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
    @EnvironmentObject var workoutController: WorkoutTrackerController
    @State private var workoutTitle: String = ""
    @AppStorage("weightPreference") private var weightPreference: String = "Lbs"
    @AppStorage("distancePreference") private var distancePreference: String = "mile"
    
    @State private var isExpanded: Bool = false
    @State private var showAlert: Bool = false
    
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
                    .frame(width: 18, height: 22)
                    .padding(.trailing, 8)
                    .onTapGesture {
                        showAlert = true
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
            workoutTitle = workoutController.selectedWorkoutName ?? ""
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
        .padding(.horizontal, 8)
        .animation(.easeInOut, value: isExpanded)
    }
    
    @ViewBuilder
    private func exerciseDetailView(detail: WorkoutDetail) -> some View {
        HStack(spacing: 12) {
            Text(detail.exerciseName ?? "Unknown Exercise")
                .frame(minWidth: 120, alignment: .leading)
                .lineLimit(2)
                .truncationMode(.tail)

            Spacer()

            HStack(spacing: 16) {
                if detail.exerciseQuantifier == "Reps" {
                    let totalReps = (detail.sets?.allObjects as? [WorkoutSet])?.reduce(0) { $0 + Int($1.reps) } ?? 0
                    VStack(spacing: 4) {
                        Text("Reps")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(totalReps)")
                            .font(.subheadline)
                            .bold()
                    }
                    .frame(minWidth: 60)
                }
                if detail.exerciseQuantifier == "Distance" {
                    let totalDistance = (detail.sets?.allObjects as? [WorkoutSet])?.reduce(0.0) { $0 + ($1.distance) } ?? 0.0
                    VStack(spacing: 4) {
                        Text("Distance")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(totalDistance, specifier: "%.2f") \(distancePreference)")
                            .font(.subheadline)
                            .bold()
                    }
                    .frame(minWidth: 80)
                }
                if detail.exerciseMeasurement == "Weight" {
                    let totalWeight = calculateTotalWeight(for: detail)
                    VStack(spacing: 4) {
                        Text("Weight")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(totalWeight, specifier: "%.2f") \(weightPreference)")
                            .font(.subheadline)
                            .bold()
                    }
                    .frame(minWidth: 80)
                }

                if detail.exerciseMeasurement == "Time"{
                    let totalTimeInMinutes = calculateTotalTime(for: detail)
                    let totalTime = totalTimeInMinutes / 60
                    VStack(spacing: 4) {
                        Text("Time")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(totalTime) mins")
                            .font(.subheadline)
                            .bold()
                    }
                    .frame(minWidth: 70)
                }
            }
        }
        .padding(.vertical, 4)
    }
 
    private func calculateTotalWeight(for detail: WorkoutDetail) -> Float {
        guard let sets = detail.sets?.allObjects as? [WorkoutSet] else {
            return 0
        }
        var totalWeight: Float = 0
        for set in sets {
            let reps = set.reps > 0 ? Float(set.reps) : 1
            let weight = Float(set.weight)
            totalWeight += weight * reps
        }
        
        return totalWeight
    }
    
    private func calculateTotalTime(for detail: WorkoutDetail) -> Int {
        guard let sets = detail.sets?.allObjects as? [WorkoutSet] else {
            print("No sets found for exercise \(detail.exerciseName ?? "Unknown Exercise")")
            return 0
        }
        
        var totalTimeInMinutes: Int = 0
        for set in sets {

            if set.time > 0 {
                totalTimeInMinutes += Int(set.time)
                if set.reps > 0 {
                    totalTimeInMinutes += Int(set.time) * Int(set.reps)
                }
            } else {
                print("Invalid or missing time for set: \(set)")
            }
        }
        
        print("Total time calculated: \(totalTimeInMinutes) minutes")
        
        return totalTimeInMinutes
    }




}
