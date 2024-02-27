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
                            .padding() // Apply padding to the Text itself
                            .frame(maxWidth: .infinity) // Make the Text view take up maximum width
                            .background(Color.myBlue) // Apply the background color to the Text view
                            .cornerRadius(10) // Apply corner radius to the background
                    }
                    .padding(.horizontal) // Apply padding outside the button to maintain some space from the screen edges
                    
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
                    .transition(.scale) // Optional: Add transition effect
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
                                indexToDelete = nil // Reset deletion index
                            }
                        },
                        secondaryButton: .cancel {
                            indexToDelete = nil // Reset deletion index on cancel
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
            Section(header: Text("Workout Title")) {
                TextField("Enter Workout Title", text: $workoutTitle)
            }
            
            ForEach($workoutDetails.indices, id: \.self) { index in
                Section(header: HStack {
                    Text(workoutDetails[index].exerciseName).font(.title2)
                    Spacer()
                    // Move up
                    if index > 0 {
                        Image(systemName: "arrow.up")
                            .foregroundColor(.blue)
                            .onTapGesture {
                                moveExercise(from: index, to: index - 1)
                            }
                    }
                    
                    // Move down
                    if index < workoutDetails.count - 1 {
                        Image(systemName: "arrow.down")
                            .foregroundColor(.blue)
                            .onTapGesture {
                                moveExercise(from: index, to: index + 1)
                            }
                    }
                    
                    // Delete
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .onTapGesture {
                            indexToDelete = index // Mark the item for potential deletion
                            alertMessage = "Are you sure you want to delete this exercise?"
                            activeAlert = .deleteConfirmation // Specify which alert to show
                            showAlert = true // Show the alert
                        }
                    Image(systemName: "pencil")
                        .foregroundColor(.myBlack)
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.2)) {
                                self.selectedExerciseIndexForRenaming = index
                            }
                        }
                })
                {
                    
                    if !workoutDetails[index].sets.isEmpty {
                        SetHeaders(isCardio: workoutDetails[index].isCardio)
                    }
                    
                    ForEach($workoutDetails[index].sets.indices, id: \.self) { setIndex in
                        if workoutDetails[index].isCardio {
                            CardioSetRow(setIndex: setIndex + 1, setInput: $workoutDetails[index].sets[setIndex])
                        } else {
                            LiftingSetRow(setIndex: setIndex + 1, setInput: $workoutDetails[index].sets[setIndex])
                        }
                    }
                    .onDelete { offsets in
                        // Delete the set at the specified offsets
                        workoutDetails[index].sets.remove(atOffsets: offsets)
                    }
                    
                    Button("Add Set") {
                        let maxSetIndex = workoutDetails[index].sets.max(by: { $0.setIndex < $1.setIndex })?.setIndex ?? 0
                        let newSetIndex = maxSetIndex + 1

                        // Check if there are any sets already
                        if let lastSet = workoutDetails[index].sets.last {
                            // Use the values from the last set
                            let newSet = SetInput(reps: lastSet.reps, weight: lastSet.weight, time: lastSet.time, distance: lastSet.distance, setIndex: newSetIndex)
                            workoutDetails[index].sets.append(newSet)
                        } else {
                            // If there are no sets, use default values
                            let newSet = SetInput(reps: 0, weight: 0, time: 0, distance: 0, setIndex: 0)
                            workoutDetails[index].sets.append(newSet)
                        }
                    }
                }
            }
            .onDelete(perform: deleteExercise)
            
        }
    }
    
    private func loadWorkoutDetails() {
        guard let workout = workoutManager.fetchWorkoutById(for: workoutId) else {
            print("Could not find workout with ID \(workoutId)")
            return
        }
        
        self.workoutTitle = workout.name ?? ""
        self.workoutTitleOriginal = self.workoutTitle
        
        // Assuming 'workout.details' can be cast to Set<WorkoutDetail>
        if let detailsSet = workout.details as? Set<WorkoutDetail> {
            let details = detailsSet.sorted { $0.orderIndex < $1.orderIndex }
            self.workoutDetails = details.map { detail in
                // Make sure to sort the sets by setIndex before converting them to SetInput
                let sortedSets = (detail.sets?.allObjects as? [WorkoutSet])?.sorted(by: { $0.setIndex < $1.setIndex }) ?? []
                let setInputs = sortedSets.map { ws in
                    SetInput(id: ws.id, reps: ws.reps, weight: ws.weight, time: ws.time, distance: ws.distance, isCompleted: ws.isCompleted, setIndex: ws.setIndex)
                }
                
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
                    // Keep details where the exercise name is not empty, regardless of set counts or weights being 0
                    guard !detail.exerciseName.isEmpty else { return false }
                    guard !detail.exerciseName.isEmpty else { return false }
                    
                    // If there's at least one set, it's considered meaningful data
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
                        isCardio: detail.isCardio,
                        orderIndex: Int32(detail.orderIndex), // Ensure you have orderIndex in WorkoutDetailInput
                        sets: detail.sets
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
