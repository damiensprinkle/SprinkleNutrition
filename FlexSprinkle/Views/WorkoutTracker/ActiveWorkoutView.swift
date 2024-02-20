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
    
    @State private var showUpdateDialog = false
    @State private var originalWorkoutDetails: [WorkoutDetailInput] = []
    
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var workoutStarted = false
    @State private var elapsedTime = 0
    @State private var cancellableTimer: AnyCancellable?
    @State private var showingStartConfirmation = false
    @State private var showEndWorkoutOption = false
    @State private var endWorkoutConfirmationShown = false
    
    @State private var foregroundObserver: Any?
    @State private var backgroundObserver: Any?
    
    
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
                NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { _ in
                    self.updateTimerForForeground()
                }
                
                NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { _ in
                    self.handleAppBackgrounding()
                }
                if(workoutManager.fetchWorkoutById(for: workoutId) != nil){
                    loadWorkoutDetails()
                    originalWorkoutDetails = workoutDetails
                    
                    initSession()
                }
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
                NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
            }
            .alert(isPresented: $showUpdateDialog) {
                Alert(
                    title: Text("Update Workout"),
                    message: Text("You've made changes from your original workout, would you like to update it?"),
                    primaryButton: .default(Text("Update Values"), action: {
                        updateWorkoutValues()
                    }),
                    secondaryButton: .cancel(Text("Keep Original Values"), action: {
                        completeEndWorkoutSequence()
                    })                        )
            }
        }
    }
    
    
    
    private func updateTimerForForeground() {
        if workoutStarted {
            let now = Date()
            if let startTime = workoutManager.getSessions().first?.startTime {
                self.elapsedTime = Int(now.timeIntervalSince(startTime))
            }
        }
    }
    
    private func handleAppBackgrounding() {
        //not needed?
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
        workoutDetails.sort { $0.orderIndex < $1.orderIndex } // make sure workouts are sorted in correct order
        
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
        if hasWorkoutChanged(original: originalWorkoutDetails, updated: workoutDetails) {
            // If there are changes, show the dialog and do not proceed further until resolved
            showUpdateDialog = true
        } else {
            // If there are no changes, proceed with the usual workflow
            completeEndWorkoutSequence()
        }
    }
    
    
    
    private func completeEndWorkoutSequence() {
        // Logic to end the workout
        workoutStarted = false
        showEndWorkoutOption = false
        
        // Proceed with any cleanup or state reset that needs to happen regardless of update
        workoutManager.setSessionStatus(workoutId: workoutId, isActive: false)
        saveWorkoutHistory()
        
        workoutManager.deleteAllTemporaryWorkoutDetails()
        
        // Navigation or other actions that should occur after workout ends
        appViewModel.navigateTo(.workoutOverview(workoutId))
        
    }
    
    func hasWorkoutChanged(original: [WorkoutDetailInput], updated: [WorkoutDetailInput]) -> Bool {
        guard original.count == updated.count else { return true }
        
        for (index, originalDetail) in original.enumerated() {
            let updatedDetail = updated[index]
            
            // Compare all properties of WorkoutDetailInput that are relevant
            if originalDetail.exerciseId != updatedDetail.exerciseId ||
                originalDetail.exerciseName != updatedDetail.exerciseName ||
                originalDetail.isCardio != updatedDetail.isCardio ||
                originalDetail.orderIndex != updatedDetail.orderIndex ||
                originalDetail.sets.count != updatedDetail.sets.count {
                return true
            }
            
            // If you have more properties to compare, continue the pattern here
            
            // If the sets array is not Equatable, you'll have to compare it manually as well
            for (setIndex, originalSet) in originalDetail.sets.enumerated() {
                let updatedSet = updatedDetail.sets[setIndex]
                
                // Assuming you have properties like 'reps' and 'weight' in your SetInput
                if originalSet.reps != updatedSet.reps ||
                    originalSet.weight != updatedSet.weight ||
                    originalSet.time != updatedSet.time ||
                    originalSet.distance != updatedSet.distance {
                    return true
                }
                
                // Continue with all other properties in SetInput that should be compared
            }
        }
        
        // If no differences are found, return false
        return false
    }
    
    
    func updateWorkoutValues() {
        workoutManager.updateWorkoutDetails(workoutId: workoutId, workoutDetailsInput: workoutDetails)
        completeEndWorkoutSequence()
    }
    
    private func saveWorkoutHistory(){
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
