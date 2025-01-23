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
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var workoutController: WorkoutTrackerController
    
    @StateObject private var focusManager = FocusManager()
    @State private var workoutTitle: String = ""
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var showUpdateDialog = false
    @State private var workoutStarted = false
    @State private var elapsedTime = 0
    @State private var cancellableTimer: AnyCancellable?
    @State private var showingStartConfirmation = false
    @State private var showEndWorkoutOption = false
    @State private var showCancelWorkoutOption = false
    @State private var activeAlert: ActiveWorkoutAlert = .updateValues
    @State private var endWorkoutConfirmationShown = false
    @State private var foregroundObserver: Any?
    @State private var backgroundObserver: Any?
    @State private var isLoading: Bool = true
    @State private var showTimer: Bool = false
    @State private var workoutCancelled: Bool = false

    
    var body: some View {
        NavigationView {
            ZStack {
                if isLoading {
                    ProgressView("Loading workout...")
                        .font(.title)
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                }
                else{
                    VStack(spacing: 0) {
                        if showTimer {
                            TimerHeaderView(showTimer: $showTimer)
                                .frame(height: 80) // Fixed height for the timer view
                                .background(Color.black.opacity(0.8))
                                .foregroundColor(Color.myBlack)
                                .zIndex(1) // Ensure it stays above the scrollable content
                        }
                        Form {
                            displayExerciseDetailsAndSets
                        }
                        .onTapGesture {
                            if focusManager.isAnyTextFieldFocused {
                                focusManager.isAnyTextFieldFocused = false
                                focusManager.currentlyFocusedField = nil
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                        }
                        
                        Spacer()
                        
                        startWorkoutButton
                    }
                }
            }
            .navigationBarTitle(workoutTitle)
            .navigationBarItems(
                leading: Button("Back") {
                    appViewModel.resetToWorkoutMainView()
                },
                trailing: workoutStarted ? Menu {
                    Button(action: {
                        activeAlert = .cancelWorkout
                        showAlert = true
                    }) {
                        Label("Cancel Workout", systemImage: "xmark.circle")
                    }
                    Button(action: {
                        if(showTimer){
                            showTimer = false
                        }
                        else{
                            showTimer = true
                        }
                    }) {
                        Label("Timer", systemImage: "timer")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title2)
                        .foregroundColor(.primary)
                } : nil
            )
            .alert(isPresented: $showAlert) {
                switch(activeAlert) {
                case .cancelWorkout:
                    return  Alert(
                        title: Text("Cancel Workout"),
                        message: Text("Are you sure you want to cancel the workout? This will discard all progress."),
                        primaryButton: .destructive(Text("Cancel Workout"), action: {
                            workoutStarted = false
                            showEndWorkoutOption = false
                            workoutController.setSessionStatus(workoutId: workoutId, isActive: false)
                            workoutController.workoutManager.deleteAllTemporaryWorkoutDetails()
                            workoutController.loadWorkoutDetails(for: workoutId)
                            workoutCancelled = true
                        }),
                        secondaryButton: .cancel(Text("Keep Going"), action: {
                            showEndWorkoutOption = false
                        })
                    )
                    
                case .updateValues:
                    return Alert(
                        title: Text("Update Workout"),
                        message: Text("You've made changes from your original workout, would you like to update it?"),
                        primaryButton: .default(Text("Update Values"), action: {
                            updateWorkoutValues()
                        }),
                        secondaryButton: .cancel(Text("Keep Original Values"), action: {
                            completeEndWorkoutSequence()
                        }))
                }
 
            }
            .id(workoutId)
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { _ in
                    self.updateTimerForForeground()
                }
                
                NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { _ in
                    self.handleAppBackgrounding()
                }
                if(workoutController.workoutManager.fetchWorkoutById(for: workoutId) != nil){
                    workoutController.loadWorkoutDetails(for: workoutId)
                    workoutController.originalWorkoutDetails = workoutController.workoutDetails
                    initSession()
                    isLoading = false
                    print("finished loading active workout")
                }
                else{
                    isLoading = false
                    print ("error, workout details not found")
                }
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
                NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
            }
        }
    }
    
    private func updateTimerForForeground() {
        if workoutStarted {
            let now = Date()
            if let startTime = workoutController.workoutManager.getSessions().first?.startTime {
                self.elapsedTime = Int(now.timeIntervalSince(startTime))
            }
        }
    }
    
    private func handleAppBackgrounding() {
    }
    
    private var displayExerciseDetailsAndSets: some View {
        ForEach(workoutController.workoutDetails.indices, id: \.self) { index in
            Section(header: HStack {
                Text(workoutController.workoutDetails[index].exerciseName).font(.title2)
                Spacer()
            }) {
                if !workoutController.workoutDetails[index].sets.isEmpty {
                    SetHeaders(exerciseQuantifier: workoutController.workoutDetails[index].exerciseQuantifier, exerciseMeasurement: workoutController.workoutDetails[index].exerciseMeasurement, active: true)
                }
                
                ForEach(workoutController.workoutDetails[index].sets.indices, id: \.self) { setIndex in
                    ExerciseRowActive(
                        setInput: $workoutController.workoutDetails[index].sets[setIndex],
                        setIndex: setIndex + 1,
                        workoutDetails: workoutController.workoutDetails[index],
                        workoutId: workoutId,
                        workoutStarted: workoutStarted,
                        workoutCancelled: workoutCancelled,
                        exerciseQuantifier: workoutController.workoutDetails[index].exerciseQuantifier,
                        exerciseMeasurement: workoutController.workoutDetails[index].exerciseMeasurement
                    )
                    .environmentObject(focusManager)
                    .environmentObject(workoutController)
                    .listRowInsets(EdgeInsets())
                }
            }
        }
    }
    
    private func initSession() {
        if(workoutController.hasActiveSession){
            self.workoutStarted = true
            let activeSession = workoutController.workoutManager.getSessions().first!
            if let startTime = activeSession.startTime {
                self.elapsedTime = Int(Date().timeIntervalSince(startTime))
                self.cancellableTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { _ in
                    self.elapsedTime += 1
                }
            }
            workoutController.loadTemporaryWorkoutDetails(for: workoutId)
        }
    }
    
    private func startWorkout() {
        workoutStarted = true
        workoutCancelled = false
        elapsedTime = 0
        cancellableTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { _ in
            self.elapsedTime += 1
        }
        
        workoutController.workoutManager.setSessionStatus(workoutId: workoutId, isActive: true)
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
        if workoutController.hasWorkoutChanged() {
            showUpdateDialog = true
            activeAlert = .updateValues
            showAlert = true
        } else {
            completeEndWorkoutSequence()
        }
    }
    
    private func completeEndWorkoutSequence() {
        workoutStarted = false
        showEndWorkoutOption = false
        workoutController.setSessionStatus(workoutId: workoutId, isActive: false)
        workoutController.saveWorkoutHistory(elapsedTimeFormatted: elapsedTimeFormatted, workoutId: workoutId)
        workoutController.workoutManager.deleteAllTemporaryWorkoutDetails()
        appViewModel.navigateTo(.workoutOverview(workoutId))
    }
    
    func updateWorkoutValues() {
        workoutController.workoutManager.updateWorkoutDetails(workoutId: workoutId, workoutDetailsInput: workoutController.workoutDetails)
        completeEndWorkoutSequence()
    }
    
    private func isAnyOtherSessionActive() -> Bool {
        let sessionsWorkoutId = workoutController.workoutManager.getWorkoutIdOfActiveSession()
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

enum ActiveWorkoutAlert {
    case updateValues, cancelWorkout
}
