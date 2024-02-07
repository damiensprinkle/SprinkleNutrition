//
//  ActiveWorkout.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/5/24.
//

import SwiftUI

import Combine

struct ActiveWorkoutView: View {
    var workoutName: String
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var userInputs: [UUID: (reps: String, weight: String)] = [:]
    @State private var fetchedWorkoutDetails: [WorkoutDetail] = []
    @State private var showingStartConfirmation = false
    @State private var workoutStarted = false
    @State private var elapsedTime = 0
    @State private var cancellableTimer: AnyCancellable?

    init(workoutName: String) {
        self.workoutName = workoutName
    }

    private var elapsedTimeFormatted: String {
        let hours = elapsedTime / 3600
        let minutes = (elapsedTime % 3600) / 60
        let seconds = elapsedTime % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    var body: some View {
        VStack {
            List {
                headerRow()
                
                ForEach(fetchedWorkoutDetails, id: \.id) { detail in
                    exerciseRow(for: detail)
                }
            }
            Spacer()
            Button(action: { showingStartConfirmation = true }) {
                Text(workoutStarted ? elapsedTimeFormatted : "Start Workout")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
            }
            .padding()
            .confirmationDialog("Are you sure you want to start this workout?", isPresented: $showingStartConfirmation, titleVisibility: .visible) {
                Button("Start", action: startWorkout)
                Button("Cancel", role: .cancel) {}
            }
            .disabled(workoutStarted)
        }
        .navigationBarTitle(Text(workoutName), displayMode: .inline)
        .onAppear {
            setupWorkoutDetails()
        }
        .onDisappear {
            cancellableTimer?.cancel()
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }

    private func startWorkout() {
        workoutStarted = true
        elapsedTime = 0
        cancellableTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { _ in
            self.elapsedTime += 1
        }
        
        // Reset the userInputs to clear all text fields
        userInputs = fetchedWorkoutDetails.reduce(into: [:]) { result, detail in
            result[detail.id] = ("", "") // Reset to empty strings
        }
    }


    private func setupWorkoutDetails() {
        fetchedWorkoutDetails = workoutManager.fetchWorkoutDetails(for: workoutName)
        userInputs = fetchedWorkoutDetails.reduce(into: [:]) { result, detail in
            result[detail.id] = (String(detail.reps), String(detail.weight))
        }
    }

    private func headerRow() -> some View {
        HStack {
            Text("Exercise Name").bold().frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            Divider()
            Text("Reps").bold().frame(width: 80, alignment: .center)
            Divider()
            Text("Weight").bold().frame(width: 80, alignment: .center)
        }
    }

    private func exerciseRow(for detail: WorkoutDetail) -> some View {
        HStack {
            Text(detail.exerciseName)
                .frame(minWidth: 0, maxWidth: .infinity)
            Divider()
            TextField("\(detail.reps)", text: Binding(
                get: { self.userInputs[detail.id]?.reps ?? "" },
                set: { newValue in
                    self.userInputs[detail.id]?.reps = newValue
                }
            ))
            .keyboardType(.numberPad)
            .frame(width: 80)
            .disabled(!workoutStarted) // Disable until workout is started
            Divider()
            TextField("\(detail.weight)", text: Binding(
                get: { self.userInputs[detail.id]?.weight ?? "" },
                set: { newValue in
                    self.userInputs[detail.id]?.weight = newValue
                }
            ))
            .keyboardType(.numberPad)
            .frame(width: 80)
            .disabled(!workoutStarted) // Disable until workout is started
        }
    }

}
