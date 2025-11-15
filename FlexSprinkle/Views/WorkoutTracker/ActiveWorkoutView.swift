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
    @StateObject private var viewModel: ActiveWorkoutViewModel

    // UI State only
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var showUpdateDialog = false
    @State private var showingStartConfirmation = false
    @State private var showEndWorkoutOption = false
    @State private var showCancelWorkoutOption = false
    @State private var activeAlert: ActiveWorkoutAlert = .updateValues
    @State private var endWorkoutConfirmationShown = false
    @State private var showTimer: Bool = false

    init(workoutId: UUID) {
        self.workoutId = workoutId
        _viewModel = StateObject(wrappedValue: ActiveWorkoutViewModel(workoutId: workoutId))
    }

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading workout...")
                        .font(.title)
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                }
                else{
                    VStack(spacing: 0) {
                        if showTimer {
                            TimerHeaderView(showTimer: $showTimer)
                                .frame(height: 80)
                                .background(Color.black.opacity(0.8))
                                .zIndex(1)
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
                            .padding(.top)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .background(
                        Color.myWhite
                            .ignoresSafeArea(.all, edges: .bottom)
                    )
                }
            }
            .navigationBarTitle(viewModel.workoutTitle)
            .navigationBarItems(
                leading: Button("Back") {
                    appViewModel.resetToWorkoutMainView()
                },
                trailing: viewModel.workoutStarted ? Menu {
                    Button(action: {
                        activeAlert = .cancelWorkout
                        showAlert = true
                    }) {
                        Label("Cancel Workout", systemImage: "xmark.circle")
                    }
                    Button(action: {
                        showTimer.toggle()
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
                    return Alert(
                        title: Text("Cancel Workout"),
                        message: Text("Are you sure you want to cancel the workout? This will discard all progress."),
                        primaryButton: .destructive(Text("Cancel Workout"), action: {
                            viewModel.cancelWorkout()
                            showEndWorkoutOption = false
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
                            viewModel.completeWorkout(shouldUpdateTemplate: true)
                        }),
                        secondaryButton: .cancel(Text("Keep Original Values"), action: {
                            viewModel.completeWorkout(shouldUpdateTemplate: false)
                        }))
                }

            }
            .id(workoutId)
            .onAppear {
                // Setup ViewModel with dependencies
                viewModel.setup(workoutController: workoutController, appViewModel: appViewModel)
                viewModel.loadWorkout()
            }
            .onDisappear {
                viewModel.cleanup()
            }
        }
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
                        workoutStarted: viewModel.workoutStarted,
                        workoutCancelled: viewModel.workoutCancelled,
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

    private func buttonAction() {
        if viewModel.workoutStarted {
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
        if viewModel.hasWorkoutChanged() {
            showUpdateDialog = true
            activeAlert = .updateValues
            showAlert = true
        } else {
            viewModel.completeWorkout(shouldUpdateTemplate: false)
        }
    }

    private var startWorkoutButton: some View {
        Button(action: buttonAction) {
            Text(workoutButtonText)
                .font(.title2)
                .foregroundColor(Color.myWhite)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.myBlue)
                .cornerRadius(10)
        }
        .padding(.horizontal)
        .disabled(!viewModel.workoutStarted && showEndWorkoutOption || viewModel.isAnyOtherSessionActive())
        .confirmationDialog("Are you sure you want to end this workout?", isPresented: $endWorkoutConfirmationShown, titleVisibility: .visible) {
            Button("End Workout", action: endWorkout)
            Button("Cancel", role: .cancel) {
                self.showEndWorkoutOption = false
            }
        }
        .confirmationDialog("Are you sure you want to start this workout?", isPresented: $showingStartConfirmation, titleVisibility: .visible) {
            Button("Start", action: { viewModel.startWorkout() })
            Button("Cancel", role: .cancel) {}
        }
    }

    private var workoutButtonText: String {
        if viewModel.workoutStarted {
            return showEndWorkoutOption ? "End Workout" : viewModel.elapsedTimeFormatted
        } else {
            return "Start Workout"
        }
    }
}

enum ActiveWorkoutAlert {
    case updateValues, cancelWorkout
}
