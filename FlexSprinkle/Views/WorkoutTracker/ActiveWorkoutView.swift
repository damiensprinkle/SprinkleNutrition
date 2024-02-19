//
//  NewWorkoutView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/4/24.
//

import SwiftUI

import SwiftUI

import SwiftUI
import Combine


struct ActiveWorkoutView: View {
    var workoutId: UUID
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var workoutManager: WorkoutManager
    
    @State private var workoutTitle: String = ""
        
    @State private var workoutDetails: [WorkoutDetailInput] = []
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @StateObject private var focusManager = FocusManager()
    
    
    @State private var showingAddExerciseDialog = false
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var workoutStarted = false
    @State private var elapsedTime = 0
    @State private var cancellableTimer: AnyCancellable?
    @State private var showingStartConfirmation = false
    @State private var showEndWorkoutOption = false
    @State private var endWorkoutConfirmationShown = false

    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    Form {
                        displayExerciseDetailsAndSets
                    }
                    .onTapGesture {
                        if focusManager.isAnyTextFieldFocused {
                            focusManager.isAnyTextFieldFocused = false
                           // hideKeyboard()
                        }
                    }
                    
                    Spacer()
                    
                    startWorkoutButton
                }
                
                if showingAddExerciseDialog {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showingAddExerciseDialog = false
                        }
                    
                    AddExerciseDialog(workoutDetails: $workoutDetails, showingDialog: $showingAddExerciseDialog)
                        .background(Color.staticWhite)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .transition(.scale)
                }
            }
            .navigationBarTitle(workoutTitle)
            .navigationBarItems(
                leading: Button("Back") {
                    appViewModel.resetToWorkoutMainView()
                }
            )
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .id(workoutId) // Use workoutId as a unique identifier for the view
            .onAppear {
                print(workoutId)

                if(workoutManager.fetchWorkoutById(for: workoutId) != nil){
                    loadWorkoutDetails()
                    
                    initSession()
                }
            }
        }
    }
    
    private func loadTemporaryData() {
        let temporaryDetails = workoutManager.loadTemporaryWorkoutData(for: workoutId)
        
        // Update existing workoutDetails with temporaryDetails
        for tempDetail in temporaryDetails {
            if let index = workoutDetails.firstIndex(where: { $0.exerciseId == tempDetail.exerciseId }) {
                // Exercise exists, update its sets
                let updatedSets = tempDetail.sets.map { SetInput(id: $0.id, reps: $0.reps, weight: $0.weight, time: $0.time, distance: $0.distance) }
                workoutDetails[index].sets = updatedSets
            } else {
                // New exercise found in temporary data, add it to workoutDetails
                workoutDetails.append(tempDetail)
            }
        }
        workoutDetails.sort { $0.orderIndex > $1.orderIndex } // make sure workouts are sorted in correct order
        
    }
    
    
    private var displayExerciseDetailsAndSets: some View {
        ForEach($workoutDetails.indices, id: \.self) { index in
            Section(header: HStack {
                Text(workoutDetails[index].exerciseName).font(.title2)
                Spacer()
                
            })
            {
                if !workoutDetails[index].sets.isEmpty {
                    SetHeaders(isCardio: workoutDetails[index].isCardio)
                }
                
                ForEach($workoutDetails[index].sets.indices, id: \.self) { setIndex in
                    if workoutDetails[index].isCardio {
                        CardioSetRowActive(setIndex: setIndex + 1, setInput: $workoutDetails[index].sets[setIndex], workoutDetails: workoutDetails[index], workoutId: workoutId, workoutStarted: workoutStarted)
                            .environmentObject(workoutManager)
                            .environmentObject(focusManager)
                        
                    } else {
                        LiftingSetRowActive(setIndex: setIndex + 1, setInput: $workoutDetails[index].sets[setIndex], workoutDetails: workoutDetails[index], workoutId: workoutId, workoutStarted: workoutStarted)
                            .environmentObject(workoutManager)
                            .environmentObject(focusManager)
                    }
                }
                
            }
        }
    }
    
    private func initSession() {
        let sessionsWorkoutId = workoutManager.getWorkoutIdOfActiveSession()
        if sessionsWorkoutId == workoutId {
            self.workoutStarted = true
            let activeSession = workoutManager.getSessions().first!
            if let startTime = activeSession.startTime {
                self.elapsedTime = Int(Date().timeIntervalSince(startTime))
                // Start or resume the timer
                self.cancellableTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { _ in
                    self.elapsedTime += 1
                }
            }
            loadTemporaryData()
        }
    }
    
    private func loadWorkoutDetails() {
        guard let workout = workoutManager.fetchWorkoutById(for: workoutId) else {
            print("Could not find workout with ID \(workoutId)")
            return
        }
        
        self.workoutTitle = workout.name ?? ""
        
        // Assuming 'workout.details' can be cast to Set<WorkoutDetail>
        if let detailsSet = workout.details as? Set<WorkoutDetail> {
            let details = detailsSet.sorted { $0.orderIndex < $1.orderIndex }
            self.workoutDetails = details.map { detail in
                // Correctly apply map to convert [WorkoutSet] to [SetInput]
                let setInputs = (detail.sets?.allObjects as? [WorkoutSet])?.map { ws in
                    SetInput(id: ws.id, reps: ws.reps, weight: ws.weight, time: ws.time, distance: ws.distance)
                } ?? []
                
                return WorkoutDetailInput(
                    id: detail.id,
                    exerciseId: detail.exerciseId,
                    exerciseName: detail.exerciseName!,
                    isCardio: detail.isCardio,
                    orderIndex: detail.orderIndex,
                    sets: setInputs // Now correctly typed as [SetInput]
                )
            }
        }
    }
    
    
    // * Start Workout Button Logic * //
    
    private func startWorkout() {
        workoutStarted = true
        elapsedTime = 0
        cancellableTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { _ in
            self.elapsedTime += 1
        }
        
        
        workoutManager.setSessionStatus(workoutId: workoutId, isActive: true)
    }
    
    private func buttonAction() {
        if workoutStarted {
            if showEndWorkoutOption {
                // Show confirmation to end workout
                endWorkoutConfirmationShown = true
            } else {
                // Show "End Workout" option for 5 seconds
                focusManager.clearFocus()
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
    
    
    private func endWorkout() {
        // Logic to end the workout
        workoutStarted = false
        showEndWorkoutOption = false
        
        // Calculate total weight lifted
        let totalWeightLifted = workoutDetails.reduce(0) { detailSum, detail in
            detailSum + detail.sets.reduce(0) { setSum, setInput in
                setSum + Int(setInput.weight) * Int(setInput.reps)
            }
        }
        
        // Calculate total reps
        let totalReps = workoutDetails.reduce(0) { detailSum, detail in
            detailSum + detail.sets.reduce(0) { setSum, setInput in
                setSum + Int(setInput.reps)
            }
        }
        
        let workoutTimeToComplete = elapsedTimeFormatted
        
        // Calculate total cardio time
        // Assuming 'time' in SetInput is the duration in minutes for cardio exercises
        let totalCardioTime = workoutDetails.filter { $0.isCardio }.reduce(0) { detailSum, detail in
            detailSum + detail.sets.reduce(0) { setSum, setInput in
                setSum + Int(setInput.time) // Summing up the cardio time
            }
        }
        
        let totalDistance = workoutDetails.filter { $0.isCardio }.reduce(0) { detailSum, detail in
            detailSum + detail.sets.reduce(0) { setSum, setInput in
                setSum + Float(setInput.distance) // Summing up the distance
            }
        }

        
        workoutManager.setSessionStatus(workoutId: workoutId, isActive: false)
        
        // Save the workout history
        workoutManager.saveWorkoutHistory(
            workoutId: workoutId,
            dateCompleted: Date(),
            totalWeightLifted: Int32(totalWeightLifted),
            repsCompleted: Int32(totalReps),
            workoutTimeToComplete: workoutTimeToComplete,
            totalCardioTime: "\(totalCardioTime)",
            totalDistance: Float(totalDistance),
            workoutDetailsInput: workoutDetails
        )
        
        workoutManager.deleteAllTemporaryWorkoutDetails()
        
        appViewModel.navigateTo(.workoutOverview(workoutId))
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
    
    private var elapsedTimeFormatted: String {
        let hours = elapsedTime / 3600
        let minutes = (elapsedTime % 3600) / 60
        let seconds = elapsedTime % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private var startWorkoutButton: some View {
        Button(action: buttonAction) {
            Text(workoutButtonText)
                .font(.title2)
                .foregroundColor(Color.staticWhite)
                .padding() // Apply padding to the content inside the button
                .frame(maxWidth: .infinity) // Ensure the button expands to the maximum width available
                .background(Color.myBlue) // Apply the background color to the button
                .cornerRadius(10) // Apply corner radius to the button's background
        }
        .padding(.horizontal) // Apply horizontal padding outside the button to maintain some space from the screen edges
        .disabled(!workoutStarted && showEndWorkoutOption || isAnyOtherSessionActive())
        .confirmationDialog("Are you sure you want to end this workout?", isPresented: $endWorkoutConfirmationShown, titleVisibility: .visible) {
            Button("End Workout", action: endWorkout)
            Button("Cancel", role: .cancel) {
                self.showEndWorkoutOption = false
            }
        }
        .confirmationDialog("Are you sure you want to start this workout?", isPresented: $showingStartConfirmation, titleVisibility: .visible) {
            Button("Start", action: startWorkout)
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private var workoutButtonText: String {
        if workoutStarted {
            return showEndWorkoutOption ? "End Workout" : elapsedTimeFormatted
        } else {
            return "Start Workout"
        }
    }
}
