//
//  NewWorkoutView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/4/24.
//

import SwiftUI
import Combine


struct ActiveWorkoutView: View {
    var workoutId: UUID
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var appViewModel: AppViewModel

    @StateObject private var focusManager = FocusManager()
    @State private var workoutTitle: String = ""
    @State private var workoutDetails: [WorkoutDetailInput] = []
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var showUpdateDialog = false
    @State private var originalWorkoutDetails: [WorkoutDetailInput] = []
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
                            focusManager.currentlyFocusedField = nil
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
            .id(workoutId)
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
                let sortedSets = tempDetail.sets.sorted(by: { $0.setIndex < $1.setIndex })
                let updatedSets = sortedSets.map { SetInput(
                    id: $0.id,
                    reps: $0.reps,
                    weight: $0.weight,
                    time: $0.time,
                    distance: $0.distance,
                    isCompleted: $0.isCompleted,
                    setIndex: $0.setIndex
                )}
                workoutDetails[index].sets = updatedSets
            } else {
                let sortedSets = tempDetail.sets.sorted(by: { $0.setIndex < $1.setIndex })
                var newTempDetail = tempDetail
                newTempDetail.sets = sortedSets
                workoutDetails.append(newTempDetail)
            }
        }
        workoutDetails.sort { $0.orderIndex < $1.orderIndex }
    }
    
    
    
    private var displayExerciseDetailsAndSets: some View {
        ForEach(workoutDetails.indices, id: \.self) { index in
            Section(header: HStack {
                Text(workoutDetails[index].exerciseName).font(.title2)
                Spacer()
            }) {
                if !workoutDetails[index].sets.isEmpty {
                    SetHeaders(exerciseQuantifier: workoutDetails[index].exerciseQuantifier, exerciseMeasurement: workoutDetails[index].exerciseMeasurement, active: true)
                }
                
                ForEach(workoutDetails[index].sets.indices, id: \.self) { setIndex in
                    ExerciseRowActive(
                        setInput: $workoutDetails[index].sets[setIndex],
                        setIndex: setIndex + 1,
                        workoutDetails: workoutDetails[index],
                        workoutId: workoutId,
                        workoutStarted: workoutStarted,
                        exerciseQuantifier: workoutDetails[index].exerciseQuantifier,
                        exerciseMeasurement: workoutDetails[index].exerciseMeasurement
                    )
                    .environmentObject(workoutManager)
                    .environmentObject(focusManager)
                    .listRowInsets(EdgeInsets())
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
        
        if let detailsSet = workout.details as? Set<WorkoutDetail> {
            let details = detailsSet.sorted { $0.orderIndex < $1.orderIndex }
            self.workoutDetails = details.map { detail in
                let sortedSets = (detail.sets?.allObjects as? [WorkoutSet])?.sorted(by: { $0.setIndex < $1.setIndex }) ?? []
                let setInputs = sortedSets.map { ws in
                    SetInput(
                        id: ws.id,
                        reps: ws.reps,
                        weight: ws.weight,
                        time: ws.time,
                        distance: ws.distance,
                        isCompleted: ws.isCompleted,
                        setIndex: ws.setIndex
                    )
                }
                
                return WorkoutDetailInput(
                    id: detail.id,
                    exerciseId: detail.exerciseId,
                    exerciseName: detail.exerciseName!,
                    orderIndex: detail.orderIndex,
                    sets: setInputs,
                    exerciseQuantifier: detail.exerciseQuantifier!,
                    exerciseMeasurement: detail.exerciseMeasurement!
                )
            }
        }
    }
    
    
        
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
                endWorkoutConfirmationShown = true
            } else {
                focusManager.clearFocus()
                showEndWorkoutOption = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.showEndWorkoutOption = false
                }
            }
        } else {
            showingStartConfirmation = true
        }
    }
    
    
    private func endWorkout() {
        if hasWorkoutChanged(original: originalWorkoutDetails, updated: workoutDetails) {
            showUpdateDialog = true
        } else {
            completeEndWorkoutSequence()
        }
    }
    
    private func completeEndWorkoutSequence() {
        workoutStarted = false
        showEndWorkoutOption = false
        workoutManager.setSessionStatus(workoutId: workoutId, isActive: false)
        saveWorkoutHistory()
        
        workoutManager.deleteAllTemporaryWorkoutDetails()
        
        appViewModel.navigateTo(.workoutOverview(workoutId))
    }
    
    func hasWorkoutChanged(original: [WorkoutDetailInput], updated: [WorkoutDetailInput]) -> Bool {
        guard original.count == updated.count else { return true }
        
        for (index, originalDetail) in original.enumerated() {
            let updatedDetail = updated[index]
            
            if originalDetail.exerciseId != updatedDetail.exerciseId ||
                originalDetail.exerciseName != updatedDetail.exerciseName ||
                originalDetail.orderIndex != updatedDetail.orderIndex ||
                originalDetail.sets.count != updatedDetail.sets.count {
                return true
            }
            
            
            for (setIndex, originalSet) in originalDetail.sets.enumerated() {
                let updatedSet = updatedDetail.sets[setIndex]
                
                if originalSet.reps != updatedSet.reps ||
                    originalSet.weight != updatedSet.weight ||
                    originalSet.time != updatedSet.time ||
                    originalSet.distance != updatedSet.distance {
                    return true
                }
            }
        }
        
        return false
    }
    
    
    func updateWorkoutValues() {
        workoutManager.updateWorkoutDetails(workoutId: workoutId, workoutDetailsInput: workoutDetails)
        completeEndWorkoutSequence()
    }
    
    private func saveWorkoutHistory(){
        let totalWeightLifted = workoutDetails.reduce(0) { detailSum, detail in
            detailSum + detail.sets.reduce(0) { setSum, setInput in
                let reps = setInput.reps > 0 ? Float(setInput.reps) : 1
                return setSum + (Float(setInput.weight) * reps)
            }
        }

        
        let totalReps = workoutDetails.reduce(0) { detailSum, detail in
            detailSum + detail.sets.reduce(0) { setSum, setInput in
                setSum + Int(setInput.reps)
            }
        }
        
        let workoutTimeToComplete = elapsedTimeFormatted
        
        let totalCardioTime = workoutDetails.reduce(0) { detailSum, detail in
            detailSum + detail.sets.reduce(0) { setSum, setInput in
                setSum + Int(setInput.time)
            }
        }
        
        let totalDistance = workoutDetails.reduce(0) { detailSum, detail in
            detailSum + detail.sets.reduce(0) { setSum, setInput in
                setSum + Float(setInput.distance)
            }
        }
        
        workoutManager.saveWorkoutHistory(
            workoutId: workoutId,
            dateCompleted: Date(),
            totalWeightLifted: Float(totalWeightLifted),
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
            return true
        }
        else{
            return false
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
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.myBlue)
                .cornerRadius(10)
        }
        .padding(.horizontal)
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
