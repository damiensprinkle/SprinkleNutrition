//
//  NewWorkoutView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/4/24.
//

import SwiftUI

struct AddWorkoutView: View {
    var workoutId: UUID
    let navigationTitle: String
    var update: Bool
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var workoutController: WorkoutTrackerController
    @StateObject private var focusManager = FocusManager()
    
    @State private var workoutTitle: String = ""
    @State private var showingRenameDialog = false
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var indexToDelete: Int? = nil
    @State private var selectedExerciseIndexForRenaming: Int?
    @State private var activeAlert: ActiveAlert = .error
    @State private var workoutSaveError: WorkoutSaveError = .emptyTitle
    @State private var initialWorkoutDetails: [WorkoutDetailInput] = []
    
    private let colorManager = ColorManager()
    @State private var showingAddExerciseDialog = false
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    addWorkoutForm
                    Spacer()
                    if(!focusManager.isAnyTextFieldFocused){
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.2)) {
                                showingAddExerciseDialog = true
                            }
                        }) {
                            Text("Add Exercise")
                                .font(.title2)
                                .foregroundColor(.staticWhite)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.myBlue)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
                
                if showingAddExerciseDialog || selectedExerciseIndexForRenaming != nil {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                }
                
                if showingAddExerciseDialog {
                    AddExerciseDialog(
                        workoutDetails: $workoutController.workoutDetails,
                        showingDialog: $showingAddExerciseDialog
                    )
                    .background(Color.staticWhite)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .transition(.scale)
                    .padding(.horizontal)
                }
                
                if let selectedIndex = selectedExerciseIndexForRenaming, selectedIndex < $workoutController.workoutDetails.count {
                    RenameExerciseDialogView(
                        isPresented: .init(
                            get: { self.selectedExerciseIndexForRenaming != nil },
                            set: { _ in self.selectedExerciseIndexForRenaming = nil }
                        ),
                        exerciseName: $workoutController.workoutDetails[selectedIndex].exerciseName,
                        onRename: { newName in
                            workoutController.renameExercise(at: selectedIndex, to: newName)
                        }
                    )
                    .transition(.scale)
                }
            }
            .navigationBarTitle(navigationTitle)
            .navigationBarItems(
                leading: Button("Cancel") {
                    if(initialWorkoutDetails != workoutController.workoutDetails){
                        alertMessage = "You have unsaved changes are you sure you want to cancel?"
                        activeAlert = .cancelConfirmation
                        showAlert = true
                    }
                    else{
                        presentationMode.wrappedValue.dismiss()
                    }
                },
                trailing: Button("Save") {
                    let result = workoutController.saveWorkout(title: workoutTitle, update: update, workoutId: workoutId)
                    switch result {
                    case .success:
                        presentationMode.wrappedValue.dismiss()
                    case .failure(let error):
                        handleSaveError(error)
                    }
                }
            )
            .alert(isPresented: $showAlert) {
                switch activeAlert {
                case .error:
                    return Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                case .deleteConfirmation:
                    return Alert(
                        title: Text("Confirm Deletion"),
                        message: Text(alertMessage),
                        primaryButton: .destructive(Text("Delete")) {
                            if let index = indexToDelete {
                                workoutController.workoutDetails.remove(at: index)
                                indexToDelete = nil
                            }
                        },
                        secondaryButton: .cancel {
                            indexToDelete = nil
                        }
                    )
                case .cancelConfirmation:
                    return Alert(
                        title: Text("Warning"),
                        message: Text(alertMessage),
                        primaryButton: .default(Text("Yes")) {
                            presentationMode.wrappedValue.dismiss()
                        },
                        secondaryButton: .cancel(Text("No")) {
                            showAlert = false
                        }
                    )
                }
            }
            .onAppear {
                if update {
                    workoutController.loadWorkoutDetails(for: workoutId)
                    workoutTitle = workoutController.selectedWorkoutName ?? ""
                    initialWorkoutDetails = workoutController.workoutDetails
                }
                else{
                    workoutController.workoutDetails.removeAll()
                }
            }
        }
    }
    
    private var addWorkoutForm: some View {
        Form {
            workoutTitleSection
            ForEach($workoutController.workoutDetails.indices, id: \.self) { index in
                Section(
                    header: ExerciseHeaderView(
                        exerciseName: workoutController.workoutDetails[index].exerciseName,
                        index: index,
                        workoutCount: workoutController.workoutDetails.count,
                        moveUpAction: {
                            workoutController.moveExercise(from: index, to: index - 1)
                        },
                        moveDownAction: {
                            workoutController.moveExercise(from: index, to: index + 1)
                        },
                        deleteAction: {
                            indexToDelete = index
                            alertMessage = "Are you sure you want to delete this exercise?"
                            activeAlert = .deleteConfirmation
                            showAlert = true
                        },
                        renameAction: {
                            withAnimation(.easeOut(duration: 0.2)) {
                                self.selectedExerciseIndexForRenaming = index
                            }
                        }
                    )
                ) {
                    WorkoutSetListView(
                        sets: $workoutController.workoutDetails[index].sets,
                        exerciseQuantifier: workoutController.workoutDetails[index].exerciseQuantifier,
                        exerciseMeasurement: workoutController.workoutDetails[index].exerciseMeasurement,
                        addSetAction: {
                            workoutController.addSet(for: index)
                        },
                        focusManager: focusManager
                    )
                }
            }
            .onDelete(perform: deleteExercise)
        }
    }
    
    
    struct WorkoutSetListView: View {
        @Binding var sets: [SetInput]
        let exerciseQuantifier: String
        let exerciseMeasurement: String
        let addSetAction: () -> Void
        let focusManager: FocusManager
        
        
        var body: some View {
            if !sets.isEmpty {
                SetHeaders(exerciseQuantifier: exerciseQuantifier, exerciseMeasurement: exerciseMeasurement, active: false)
            }
            
            ForEach(sets.indices, id: \.self) { setIndex in
                ExerciseRow(
                    setIndex: setIndex + 1,
                    setInput: $sets[setIndex],
                    exerciseQuantifier: exerciseQuantifier,
                    exerciseMeasurement: exerciseMeasurement
                )
                .environmentObject(focusManager)
            }
            .onDelete { offsets in
                sets.remove(atOffsets: offsets)
            }
            
            Button("Add Set") {
                addSetAction()
            }
        }
    }
    
    struct ExerciseHeaderView: View {
        let exerciseName: String
        let index: Int
        let workoutCount: Int
        var moveUpAction: (() -> Void)?
        var moveDownAction: (() -> Void)?
        var deleteAction: (() -> Void)?
        var renameAction: (() -> Void)?
        
        var body: some View {
            HStack {
                Text(exerciseName).font(.title2)
                Spacer()
                
                // Move up
                if index > 0 {
                    Image(systemName: "arrow.up")
                        .foregroundColor(.blue)
                        .onTapGesture {
                            moveUpAction?()
                        }
                }
                
                // Move down
                if index < workoutCount - 1 {
                    Image(systemName: "arrow.down")
                        .foregroundColor(.blue)
                        .onTapGesture {
                            moveDownAction?()
                        }
                }
                
                // Delete
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .onTapGesture {
                        deleteAction?()
                    }
                
                // Rename
                Image(systemName: "pencil")
                    .foregroundColor(.myBlack)
                    .onTapGesture {
                        renameAction?()
                    }
            }
        }
    }
    
    
    private var workoutTitleSection: some View {
        Section(header: Text("Workout Title")) {
            TextField("Enter Workout Title", text: $workoutTitle)
        }
    }
    
    private func deleteExercise(at offsets: IndexSet) {
        workoutController.workoutDetails.remove(atOffsets: offsets)
    }
    
    private func handleSaveError(_ error: WorkoutSaveError) {
        switch error {
        case .emptyTitle:
            errorMessage = "Please enter a workout title."
        case .noExerciseDetails:
            errorMessage = "Please add at least one exercise detail."
        case .titleExists:
            errorMessage = "Workout title already exists."
        }
        activeAlert = .error
        showAlert = true
    }
}

enum ActiveAlert {
    case error, deleteConfirmation, cancelConfirmation
}
