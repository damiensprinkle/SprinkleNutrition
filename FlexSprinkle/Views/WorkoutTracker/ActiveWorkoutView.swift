//
//  TempView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/7/24.
//


import SwiftUI
import Combine

struct ActiveWorkoutView: View {
    var workoutName: String
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var userInputs: [UUID: (reps: String, weight: String, exerciseTime: String)] = [:]
    @State private var fetchedWorkoutDetails: [WorkoutDetail] = []
    @State private var showingStartConfirmation = false
    @State private var workoutStarted = false
    @State private var elapsedTime = 0
    @State private var cancellableTimer: AnyCancellable?

    init(workoutName: String) {
        self.workoutName = workoutName
    }

    var body: some View {
        VStack {
            List {
                if hasLiftingExercises {
                    liftingExercisesSection
                }
                if hasCardioExercises {
                    cardioExercisesSection
                }
            }
            Spacer()
            startWorkoutButton
        }
        .navigationBarTitle(Text(workoutName), displayMode: .inline)
        .onAppear(perform: setupWorkoutDetails)
        .onDisappear {
            cancellableTimer?.cancel()
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }

    // MARK: - Private Methods

    private func startWorkout() {
        workoutStarted = true
        elapsedTime = 0
        cancellableTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { _ in
            self.elapsedTime += 1
        }
        
        userInputs = fetchedWorkoutDetails.reduce(into: [:]) { result, detail in
            result[detail.id] = ("", "", "")
        }
    }

    private func setupWorkoutDetails() {
        fetchedWorkoutDetails = workoutManager.fetchWorkoutDetails(for: workoutName)
    }

    // MARK: - Computed Properties

    private var hasLiftingExercises: Bool {
        fetchedWorkoutDetails.contains(where: { !$0.isCardio })
    }

    private var hasCardioExercises: Bool {
        fetchedWorkoutDetails.contains(where: { $0.isCardio })
    }

    // MARK: - Views

    private var startWorkoutButton: some View {
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

    private var liftingExercisesSection: some View {
        Section(header: headerRowNonCardio()) {
            ForEach(fetchedWorkoutDetails.filter { !$0.isCardio }, id: \.id) { detail in
                liftingExerciseRow(for: detail)
            }
        }
    }

    private var cardioExercisesSection: some View {
        Section(header: headerRowCardio()) {
            ForEach(fetchedWorkoutDetails.filter { $0.isCardio }, id: \.id) { detail in
                cardioExerciseRow(for: detail)
            }
        }
    }

    // MARK: - Row Views
    
    private func headerRowNonCardio() -> some View {
            HStack {
                Text("Exercise Name").bold().frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                Divider()
                Text("Reps").bold().frame(width: 80, alignment: .center)
                Divider()
                Text("Weight").bold().frame(width: 80, alignment: .center)
            }
        }
    
    
    private func headerRowCardio() -> some View {
            HStack {
                Text("Exercise Name").bold().frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .frame(minWidth: 0, maxWidth: .infinity)
                Divider()
                Text("Exercise Time").bold().frame(width: 160, alignment: .center)
            }
        }

    private func liftingExerciseRow(for detail: WorkoutDetail) -> some View {
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
            .disabled(!workoutStarted)
            Divider()
            TextField("\(detail.weight)", text: Binding(
                         get: { self.userInputs[detail.id]?.weight ?? "" },
                         set: { newValue in
                             self.userInputs[detail.id]?.weight = newValue
                         }
                     ))
            .keyboardType(.numberPad)
            .frame(width: 80)
            .disabled(!workoutStarted)
        }
    }

    private func cardioExerciseRow(for detail: WorkoutDetail) -> some View {
        HStack {
            Text(detail.exerciseName)
                .frame(minWidth: 0, maxWidth: .infinity)
            Divider()
            TextField("\(detail.exerciseTime)", text: Binding(
                         get: { self.userInputs[detail.id]?.exerciseTime ?? "" },
                         set: { newValue in
                             self.userInputs[detail.id]?.exerciseTime = newValue
                         }
                     ))
            .keyboardType(.numberPad)
            .frame(width: 160) // Adjusted for potentially longer input
            .disabled(!workoutStarted)
        }
    }


    private var elapsedTimeFormatted: String {
        let hours = elapsedTime / 3600
        let minutes = (elapsedTime % 3600) / 60
        let seconds = elapsedTime % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

}
