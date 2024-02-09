//
//  TempView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/7/24.
//


import SwiftUI
import Combine

struct ActiveWorkoutView: View {
    var workoutId: UUID
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var userInputs: [UUID: (reps: String, weight: String, exerciseTime: String)] = [:]
    @State private var fetchedWorkoutDetails: [WorkoutDetail] = []
    @State private var showingStartConfirmation = false
    @State private var workoutStarted = false
    @State private var elapsedTime = 0
    @State private var cancellableTimer: AnyCancellable?
    
    @State private var showEndWorkoutOption = false
    @State private var workoutName = ""

    @State private var endWorkoutConfirmationShown = false
    @State private var completedExercises: Set<UUID> = []

    init(workoutId: UUID) {
        self.workoutId = workoutId

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
        .onAppear {
            setupWorkoutDetails()
            let sessionsWorkoutId = workoutManager.getWorkoutIdOfActiveSession()
            if sessionsWorkoutId == workoutId {
                self.workoutStarted = true
                let activeSession = workoutManager.getSessions().first!

                // Ensure userInputs is initialized with empty values for all exercises
                userInputs = fetchedWorkoutDetails.reduce(into: [:]) { result, detail in
                    result[detail.exerciseId!] = ("", "", "")
                }
                
                // Load temporary data for each exercise using its exerciseId
                fetchedWorkoutDetails.forEach { detail in
                    let temporaryData = workoutManager.loadTemporaryWorkoutData(for: workoutId, exerciseId: detail.exerciseId!)
                    // Update userInputs with the loaded temporary data
                    userInputs[detail.exerciseId!] = (reps: temporaryData.reps, weight: temporaryData.weight, exerciseTime: temporaryData.exerciseTime)
                }
                
                if let startTime = activeSession.startTime {
                    self.elapsedTime = Int(Date().timeIntervalSince(startTime))
                    // Start or resume the timer
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
        
          
          workoutManager.setSessionStatus(workoutId: workoutId, isActive: true)
          
                
        userInputs = fetchedWorkoutDetails.reduce(into: [:]) { result, detail in
            result[detail.exerciseId!] = ("", "", "")
        }
    }
    
    private func endWorkout() {
         // Logic to end the workout
         workoutStarted = false
         showEndWorkoutOption = false
                
        workoutManager.setSessionStatus(workoutId: workoutId, isActive: false)
        
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
        guard let workout = workoutManager.fetchWorkoutById(for: workoutId) else {
            print("Workout not found")
            return
        }
        workoutName = workout.name!
        
        // Assuming `details` is now a Set<WorkoutDetail> due to the relationship
        if let detailsSet = workout.details as? Set<WorkoutDetail> {
            fetchedWorkoutDetails = detailsSet.sorted { $0.exerciseName! < $1.exerciseName! }
        }

        userInputs = fetchedWorkoutDetails.reduce(into: [:]) { result, detail in
            result[detail.exerciseId!] = (reps: "", weight: "", exerciseTime: "")
        }
        print(fetchedWorkoutDetails.map { "\($0.exerciseName ?? "Unknown") - ID: \($0.exerciseId ?? UUID())" })

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
            ForEach(fetchedWorkoutDetails.filter { !$0.isCardio }, id: \.exerciseId) { detail in
                liftingExerciseRow(for: detail)
            }
        }
    }

    private var cardioExercisesSection: some View {
        Section(header: headerRowCardio()) {
            ForEach(fetchedWorkoutDetails.filter { $0.isCardio }, id: \.exerciseId) { detail in
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
        
        let sessionsWorkoutId = workoutManager.getWorkoutIdOfActiveSession()
        if sessionsWorkoutId != workoutId {
            if sessionsWorkoutId == nil {
                return false
            }
            return true // a different session is active
        }
        else{
            return false // this session or no sessions are active
        }
    }

    
    private func liftingExerciseRow(for detail: WorkoutDetail) -> some View {
        HStack {
            Text(detail.exerciseName!)
                .frame(minWidth: 0, maxWidth: .infinity)
                .onTapGesture {
                    toggleCompletion(for: detail)
                }
            Divider()
            TextField("\(detail.reps)", text: Binding(
                get: { self.userInputs[detail.exerciseId!]?.reps ?? "" },
                         set: { newValue in
                             self.userInputs[detail.exerciseId!]?.reps = newValue
                             DispatchQueue.main.async {
                                        workoutManager.saveOrUpdateWorkoutHistory(
                                            workoutId: workoutId,
                                            exerciseId: detail.exerciseId!,
                                            exerciseName: detail.exerciseName!,
                                            reps: newValue,
                                            weight: self.userInputs[detail.exerciseId!]?.weight,
                                            exerciseTime: self.userInputs[detail.exerciseId!]?.exerciseTime
                                        )
                                    }
                         }
                     ))
            .keyboardType(.numberPad)
            .frame(width: 80)
            .disabled(!workoutStarted)
            Divider()
            TextField("\(detail.weight)", text: Binding(
                get: { self.userInputs[detail.exerciseId!]?.weight ?? "" },
                         set: { newValue in
                             self.userInputs[detail.exerciseId!]?.weight = newValue
                             DispatchQueue.main.async {
                                        workoutManager.saveOrUpdateWorkoutHistory(
                                            workoutId: workoutId,
                                            exerciseId: detail.exerciseId!,
                                            exerciseName: detail.exerciseName!,
                                            reps: self.userInputs[detail.exerciseId!]?.reps,
                                            weight: newValue,
                                            exerciseTime: self.userInputs[detail.exerciseId!]?.exerciseTime
                                        )
                                    }
                         }
                     ))
            .keyboardType(.numberPad)
            .frame(width: 80)
            .disabled(!workoutStarted)
        }
        .listRowBackground(completedExercises.contains(detail.exerciseId!) ? Color.green.opacity(0.2) : Color.white)
        .disabled(!workoutStarted)

    }

    private func cardioExerciseRow(for detail: WorkoutDetail) -> some View {
        HStack {
            Text(detail.exerciseName!)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .onTapGesture {
                    toggleCompletion(for: detail)
                }
            
            Divider()
            
            TextField("\(detail.exerciseTime!)", text: Binding<String>(
                get: {
                    self.userInputs[detail.exerciseId!]?.exerciseTime ?? detail.exerciseTime ?? "0" // Providing a default format
                },
                set: { newValue in
                    self.userInputs[detail.exerciseId!]?.exerciseTime = newValue
                    DispatchQueue.main.async {
                        workoutManager.saveOrUpdateWorkoutHistory(
                            workoutId: workoutId,
                            exerciseId: detail.exerciseId!,
                            exerciseName: detail.exerciseName!,
                            reps: self.userInputs[detail.exerciseId!]?.reps,
                            weight: self.userInputs[detail.exerciseId!]?.weight,
                            exerciseTime: newValue
                        )
                    }
                }
            ))
            .keyboardType(.default) // This allows for non-numeric input, adjust as necessary for your input format
            .frame(width: 150) // Adjust the frame as needed
            .disabled(!workoutStarted)

            .keyboardType(.numberPad) // Check if appropriate for your use case
            .frame(width: 150)
            .disabled(!workoutStarted)

            .frame(width: 150) // Adjusted for potentially longer input
            .disabled(!workoutStarted)
        }
        .padding()
        .listRowBackground(completedExercises.contains(detail.exerciseId!) ? Color.green.opacity(0.2) : Color.white)
        .cornerRadius(5)
        .disabled(!workoutStarted)
    }

    private func toggleCompletion(for detail: WorkoutDetail) {
        if completedExercises.contains(detail.exerciseId!) {
            completedExercises.remove(detail.exerciseId!)
        } else {
            completedExercises.insert(detail.exerciseId!)
            // Populate with placeholder values only if no user input exists
            if detail.isCardio {
                if (self.userInputs[detail.exerciseId!]?.exerciseTime.isEmpty ?? true) {
                    userInputs[detail.exerciseId!]?.exerciseTime = detail.exerciseTime!
                }
            } else {
                if (self.userInputs[detail.exerciseId!]?.reps.isEmpty ?? true) {
                    userInputs[detail.exerciseId!]?.reps = String(detail.reps)
                }
                if (self.userInputs[detail.exerciseId!]?.weight.isEmpty ?? true) {
                    userInputs[detail.exerciseId!]?.weight = String(detail.weight)
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


