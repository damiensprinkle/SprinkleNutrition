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
    @EnvironmentObject var workoutManager: WorkoutManager
    
    @State private var workoutTitle: String = ""
    @State private var workoutTitleOriginal: String = ""
    
    @State private var showingRenameDialog = false
    
    @State private var workoutDetails: [WorkoutDetailInput] = []
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var indexToDelete: Int? = nil
    
    @State private var selectedExerciseIndexForRenaming: Int?
    
    @State private var activeAlert: ActiveAlert = .error
    
    
    private let colorManager = ColorManager()
    @State private var showingAddExerciseDialog = false
    @EnvironmentObject var appViewModel: AppViewModel
    
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    addWorkoutForm
                    Spacer()
                    
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
                        .padding(.horizontal)
                }
                if let selectedIndex = selectedExerciseIndexForRenaming, selectedIndex < workoutDetails.count {
                    RenameExerciseDialogView(
                        isPresented: .init(
                            get: { self.selectedExerciseIndexForRenaming != nil },
                            set: { _ in self.selectedExerciseIndexForRenaming = nil }
                        ),
                        exerciseName: $workoutDetails[selectedIndex].exerciseName,
                        onRename: { newName in
                            workoutDetails[selectedIndex].exerciseName = newName
                        }
                    )
                    .transition(.scale)
                }
            }
            .navigationBarTitle(navigationTitle)
            .navigationBarItems(
                leading: Button("Cancel") {
                    if(update){
                        presentationMode.wrappedValue.dismiss()
                    }
                    else{
                        self.presentationMode.wrappedValue.dismiss()
                    }
                },
                trailing: Button("Save") { saveWorkout() }
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
                                workoutDetails.remove(at: index)
                                indexToDelete = nil
                            }
                        },
                        secondaryButton: .cancel {
                            indexToDelete = nil
                        }
                    )
                }
            }
            
            .onAppear {
                if(update){
                    loadWorkoutDetails()
                }
            }
        }
    }
    
    private var addWorkoutForm: some View {
        Form {
            workoutTitleSection
            ForEach($workoutDetails.indices, id: \.self) { index in
                Section(
                    header: ExerciseHeaderView(
                        exerciseName: workoutDetails[index].exerciseName,
                        index: index,
                        workoutCount: workoutDetails.count,
                        moveUpAction: {
                            moveExercise(from: index, to: index - 1)
                        },
                        moveDownAction: {
                            moveExercise(from: index, to: index + 1)
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
                )
                {
                    WorkoutSetListView(
                         sets: $workoutDetails[index].sets,
                         exerciseQuantifier: workoutDetails[index].exerciseQuantifier,
                         exerciseMeasurement: workoutDetails[index].exerciseMeasurement,
                         addSetAction: {
                             addSet(to: index)
                         }
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

        var body: some View {
            if !sets.isEmpty {
                SetHeaders(exerciseQuantifier: exerciseQuantifier, exerciseMeasurement: exerciseMeasurement, active: false)
            }
            
            ForEach(sets.indices, id: \.self) { setIndex in
                ExerciseRow(setIndex: setIndex + 1, setInput: $sets[setIndex], exerciseQuantifier: exerciseQuantifier, exerciseMeasurement: exerciseMeasurement)
            }
            .onDelete { offsets in
                sets.remove(atOffsets: offsets)
            }
            
            Button("Add Set") {
                addSetAction()
            }
        }
    }

    
    
    private func addSet(to workoutIndex: Int) {
        let maxSetIndex = workoutDetails[workoutIndex].sets.max(by: { $0.setIndex < $1.setIndex })?.setIndex ?? 0
        let newSetIndex = maxSetIndex + 1
        
        let newSet = workoutDetails[workoutIndex].sets.last.map {
            SetInput(reps: $0.reps, weight: $0.weight, time: $0.time, distance: $0.distance, setIndex: newSetIndex)
        } ?? SetInput(reps: 0, weight: 0, time: 0, distance: 0, setIndex: 0)
        
        workoutDetails[workoutIndex].sets.append(newSet)
    }
    
    private var workoutTitleSection: some View {
        Section(header: Text("Workout Title")) {
            TextField("Enter Workout Title", text: $workoutTitle)
        }
    }
    
    
    private func loadWorkoutDetails() {
        guard let workout = workoutManager.fetchWorkoutById(for: workoutId) else {
            print("Could not find workout with ID \(workoutId)")
            return
        }
        
        self.workoutTitle = workout.name ?? ""
        self.workoutTitleOriginal = self.workoutTitle
        
        if let detailsSet = workout.details as? Set<WorkoutDetail> {
            let details = detailsSet.sorted { $0.orderIndex < $1.orderIndex }
            self.workoutDetails = details.map { detail in
                let sortedSets = (detail.sets?.allObjects as? [WorkoutSet])?.sorted(by: { $0.setIndex < $1.setIndex }) ?? []
                let setInputs = sortedSets.map { ws in
                    SetInput(id: ws.id, reps: ws.reps, weight: ws.weight, time: ws.time, distance: ws.distance, isCompleted: ws.isCompleted, setIndex: ws.setIndex)
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
                    .foregroundColor(.black)
                    .onTapGesture {
                        renameAction?()
                    }
            }
        }
    }
    
    
    
    private func deleteExercise(at offsets: IndexSet) {
        workoutDetails.remove(atOffsets: offsets)
    }
    
    private func moveExercise(from source: Int, to destination: Int) {
        let item = workoutDetails.remove(at: source)
        workoutDetails.insert(item, at: destination)
        
        for (index, var detail) in workoutDetails.enumerated() {
            detail.orderIndex = Int32(index)
            workoutDetails[index] = detail // Update the detail with the new orderIndex
        }
    }
    
    private func saveWorkout() {
        if workoutTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please Enter a Workout Title"
            showAlert = true
            activeAlert = .error
        } else if workoutDetails.isEmpty {
            errorMessage = "Please add at least one exercise detail"
            showAlert = true
            activeAlert = .error
        } else if workoutTitleOriginal != workoutTitle && workoutManager.titleExists(workoutTitle) {
            errorMessage = "Workout Title Already Exists"
            showAlert = true
            activeAlert = .error
        } else {
            if(update){
                let filledDetails = workoutDetails.filter { detail in
                    guard !detail.exerciseName.isEmpty else { return false }
                    guard !detail.exerciseName.isEmpty else { return false }
                    
                    return !detail.sets.isEmpty
                }
                workoutManager.updateWorkoutDetails(workoutId: workoutId, workoutDetailsInput: filledDetails)
                workoutManager.updateWorkoutTitle(workoutId: workoutId, to: workoutTitle)
            }
            else{
                for detail in workoutDetails {
                    workoutManager.addWorkoutDetail(
                        workoutTitle: workoutTitle,
                        exerciseName: detail.exerciseName,
                        color: colorManager.getRandomColor(),
                        orderIndex: Int32(detail.orderIndex),
                        sets: detail.sets,
                        exerciseMeasurement: detail.exerciseMeasurement,
                        exerciseQuantifier: detail.exerciseQuantifier
                    )
                }
            }
            
            // appViewModel.resetToWorkoutMainView()
            presentationMode.wrappedValue.dismiss()
            
        }
    }
}


enum ActiveAlert {
    case error, deleteConfirmation
}
