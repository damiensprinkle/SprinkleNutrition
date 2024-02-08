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
    
    @State private var showEndWorkoutOption = false
    @State private var endWorkoutConfirmationShown = false
    @State private var completedExercises: Set<UUID> = []


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
        .onAppear{
            setupWorkoutDetails()
            
            let activeSessions = workoutManager.getSessions().filter { $0.workoutId == self.fetchedWorkoutDetails.first?.id && $0.isActive }
                if !activeSessions.isEmpty {
                    self.workoutStarted = true
                    
                    if let workoutId = fetchedWorkoutDetails.first?.id {
                        let tempData = workoutManager.loadTemporaryWorkoutData(for: workoutId)
                        for detail in fetchedWorkoutDetails {
                            if let temp = tempData[detail.exerciseName] {
                                userInputs[detail.id] = temp
                            }
                        }
                    }

                   // Optional: Initialize elapsedTime based on the session's start time
                   if let startTime = activeSessions.first?.startTime {
                       self.elapsedTime = Int(Date().timeIntervalSince(startTime))
                       // Start the timer
                                  self.cancellableTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { _ in
                                      self.elapsedTime += 1
                                  }
                   }
               }
            
            
        }
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
        
          if let workoutId = fetchedWorkoutDetails.first?.id {
              workoutManager.setSessionStatus(workoutId: workoutId, isActive: true)
          }
                
        userInputs = fetchedWorkoutDetails.reduce(into: [:]) { result, detail in
            result[detail.id] = ("", "", "")
        }
    }
    
    private func endWorkout() {
         // Logic to end the workout
         workoutStarted = false
         showEndWorkoutOption = false
        
        // get session id before ending the session
        
        let sessionId = workoutManager.getSessions().first!.id
        
        // End Current Sesion
        if let workoutId = fetchedWorkoutDetails.first?.id {
            workoutManager.setSessionStatus(workoutId: workoutId, isActive: false)
            workoutManager.completeWorkoutForId(workoutId: workoutId) // TODO To Change
        }
        
        // Get Session Details
        let sessionDetails = workoutManager.getSessionDetails(for: sessionId)
        
     }
    
    private func buttonAction() {
           if workoutStarted {
               if showEndWorkoutOption {
                   // Show confirmation to end workout
                   endWorkoutConfirmationShown = true
               } else {
                   // Show "End Workout" option for 5 seconds
                   showEndWorkoutOption = true
                   DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                       // If no action taken, revert to showing the timer
                       self.showEndWorkoutOption = false
                   }
               }
           } else {
               showingStartConfirmation = true
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
        Button(action: buttonAction) {
            if workoutStarted {
                if showEndWorkoutOption {
                    Text("End Workout")
                } else {
                    Text(elapsedTimeFormatted)
                }
            } else {
                Text("Start Workout")
            }
        }
        .font(.title2)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue)
        .foregroundColor(Color.white)
        .cornerRadius(10)
        .padding()
        .disabled(!workoutStarted && showEndWorkoutOption || isAnyOtherSessionActive())
        .confirmationDialog("Are you sure you want to end this workout?", isPresented: $endWorkoutConfirmationShown, titleVisibility: .visible) {
            Button("End Workout", action: endWorkout)
            Button("Cancel", role: .cancel) {
                // If cancel, go back to showing the timer
                self.showEndWorkoutOption = false
            }
        }

        // Handle the start confirmation dialog
        .confirmationDialog("Are you sure you want to start this workout?", isPresented: $showingStartConfirmation, titleVisibility: .visible) {
            Button("Start", action: startWorkout)
            Button("Cancel", role: .cancel) {}
        }
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
    
    private func isAnyOtherSessionActive() -> Bool {
        // Fetch all active sessions
        let activeSessions = workoutManager.getSessions().filter { $0.isActive }
        let workoutId = fetchedWorkoutDetails.first?.id
        
        
        
        // Check if there are any active sessions excluding the current workout session
        let activeOtherSessions = activeSessions.filter { $0.workoutId != workoutId }
        
        return !activeOtherSessions.isEmpty
    }

    
    private func liftingExerciseRow(for detail: WorkoutDetail) -> some View {
        HStack {
            Text(detail.exerciseName)
                .frame(minWidth: 0, maxWidth: .infinity)
                .onTapGesture {
                    toggleCompletion(for: detail)
                }
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
        .listRowBackground(completedExercises.contains(detail.id) ? Color.green.opacity(0.2) : Color.white)
        .disabled(!workoutStarted)

    }

    private func cardioExerciseRow(for detail: WorkoutDetail) -> some View {
        HStack {
            Text(detail.exerciseName)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .onTapGesture {
                    toggleCompletion(for: detail)
                }
            
            Divider()
            
            TextField("\(detail.exerciseTime)", text: Binding(
                                  get: { self.userInputs[detail.id]?.exerciseTime ?? "" },
                                  set: { newValue in
                                      self.userInputs[detail.id]?.exerciseTime = newValue
                                      DispatchQueue.main.async {
                                                 workoutManager.saveOrUpdateWorkoutHistory(
                                                     workoutId: detail.id,
                                                     exerciseName: detail.exerciseName,
                                                     reps: newValue,
                                                     weight: self.userInputs[detail.id]?.weight,
                                                     exerciseTime: self.userInputs[detail.id]?.exerciseTime
                                                 )
                                             }
                                  }
                              ))
            .keyboardType(.numberPad)
            .frame(width: 150) // Adjusted for potentially longer input
            .disabled(!workoutStarted)
        }
        .padding()
        .listRowBackground(completedExercises.contains(detail.id) ? Color.green.opacity(0.2) : Color.white)
        .cornerRadius(5)
        .disabled(!workoutStarted)
    }

    private func toggleCompletion(for detail: WorkoutDetail) {
        if completedExercises.contains(detail.id) {
            completedExercises.remove(detail.id)
        } else {
            completedExercises.insert(detail.id)
            // Populate with placeholder values only if no user input exists
            if detail.isCardio {
                if (self.userInputs[detail.id]?.exerciseTime.isEmpty ?? true) {
                    userInputs[detail.id]?.exerciseTime = detail.exerciseTime
                }
            } else {
                if (self.userInputs[detail.id]?.reps.isEmpty ?? true) {
                    userInputs[detail.id]?.reps = String(detail.reps)
                }
                if (self.userInputs[detail.id]?.weight.isEmpty ?? true) {
                    userInputs[detail.id]?.weight = String(detail.weight)
                }
            }
        }
    }




    private var elapsedTimeFormatted: String {
        let hours = elapsedTime / 3600
        let minutes = (elapsedTime % 3600) / 60
        let seconds = elapsedTime % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

}
