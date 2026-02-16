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
    @State private var selectedExerciseIndexForNotes: Int?
    @State private var activeAlert: ActiveAlert = .error
    @State private var workoutSaveError: WorkoutSaveError = .emptyTitle
    @State private var initialWorkoutDetails: [WorkoutDetailInput] = []

    private let colorManager = ColorManager()
    @State private var showingAddExerciseDialog = false
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    addWorkoutForm

                    if(!focusManager.isAnyTextFieldFocused){
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showingAddExerciseDialog = true
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                Text("Add Exercise")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.staticWhite)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.myBlue, Color.myBlue.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(14)
                            .shadow(color: Color.myBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        .padding(.top, 12)
                    }
                }
                .background(Color(.systemGroupedBackground))
                
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
            .sheet(isPresented: $showingAddExerciseDialog) {
                AddExerciseDialog(
                    workoutDetails: $workoutController.workoutDetails,
                    showingDialog: $showingAddExerciseDialog
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: Binding(
                get: { selectedExerciseIndexForRenaming != nil },
                set: { if !$0 { selectedExerciseIndexForRenaming = nil } }
            )) {
                if let selectedIndex = selectedExerciseIndexForRenaming,
                   selectedIndex < workoutController.workoutDetails.count {
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
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                }
            }
            .sheet(isPresented: Binding(
                get: { selectedExerciseIndexForNotes != nil },
                set: { if !$0 { selectedExerciseIndexForNotes = nil } }
            )) {
                if let selectedIndex = selectedExerciseIndexForNotes,
                   selectedIndex < workoutController.workoutDetails.count {
                    ExerciseNotesDialogView(
                        isPresented: .init(
                            get: { self.selectedExerciseIndexForNotes != nil },
                            set: { _ in self.selectedExerciseIndexForNotes = nil }
                        ),
                        exerciseNotes: $workoutController.workoutDetails[selectedIndex].notes
                    )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                }
            }
        }
    }
    
    private var addWorkoutForm: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Workout Title Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Workout Title")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                    TextField("Enter Workout Title", text: $workoutTitle)
                        .font(.body)
                        .padding(16)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 8)

                // Exercise Cards
                ForEach(0..<workoutController.workoutDetails.count, id: \.self) { index in
                    ExerciseCard(
                        exerciseName: workoutController.workoutDetails[index].exerciseName,
                        hasNotes: workoutController.workoutDetails[index].notes != nil && !workoutController.workoutDetails[index].notes!.isEmpty,
                        notes: workoutController.workoutDetails[index].notes,
                        index: index,
                        workoutCount: workoutController.workoutDetails.count,
                        isKeyboardActive: focusManager.isAnyTextFieldFocused,
                        sets: $workoutController.workoutDetails[index].sets,
                        exerciseQuantifier: workoutController.workoutDetails[index].exerciseQuantifier,
                        exerciseMeasurement: workoutController.workoutDetails[index].exerciseMeasurement,
                        focusManager: focusManager,
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
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                self.selectedExerciseIndexForRenaming = index
                            }
                        },
                        notesAction: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                self.selectedExerciseIndexForNotes = index
                            }
                        },
                        addSetAction: {
                            workoutController.addSet(for: index)
                        }
                    )
                    .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 8)
        }
        .onTapGesture {
            if focusManager.isAnyTextFieldFocused {
                focusManager.isAnyTextFieldFocused = false
                focusManager.currentlyFocusedField = nil
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
    
    
    // MARK: - Exercise Card
    struct ExerciseCard: View {
        let exerciseName: String
        let hasNotes: Bool
        let notes: String?
        let index: Int
        let workoutCount: Int
        let isKeyboardActive: Bool
        @Binding var sets: [SetInput]
        let exerciseQuantifier: String
        let exerciseMeasurement: String
        let focusManager: FocusManager
        var moveUpAction: (() -> Void)?
        var moveDownAction: (() -> Void)?
        var deleteAction: (() -> Void)?
        var renameAction: (() -> Void)?
        var notesAction: (() -> Void)?
        var addSetAction: (() -> Void)?

        var body: some View {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    // Title and primary actions
                    HStack {
                        Text(exerciseName)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        Spacer()

                        HStack(spacing: 16) {
                            // Notes icon
                            Button(action: { notesAction?() }) {
                                Image(systemName: hasNotes ? "note.text.badge.plus" : "note.text")
                                    .font(.body)
                                    .foregroundColor(hasNotes ? .orange : .gray)
                            }

                            // More options menu
                            Menu {
                                Button(action: { renameAction?() }) {
                                    Label("Rename Exercise", systemImage: "pencil")
                                }

                                if index > 0 {
                                    Button(action: { moveUpAction?() }) {
                                        Label("Move Up", systemImage: "arrow.up")
                                    }
                                    .disabled(isKeyboardActive)
                                }

                                if index < workoutCount - 1 {
                                    Button(action: { moveDownAction?() }) {
                                        Label("Move Down", systemImage: "arrow.down")
                                    }
                                    .disabled(isKeyboardActive)
                                }

                                Divider()

                                Button(role: .destructive, action: { deleteAction?() }) {
                                    Label("Delete Exercise", systemImage: "trash")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                        }
                    }

                    // Notes display
                    if let notes = notes, !notes.isEmpty {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "quote.bubble.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text(notes)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }
                        .padding(12)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding(16)

                Divider()
                    .padding(.horizontal, 16)

                // Sets section
                VStack(spacing: 8) {
                    if !sets.isEmpty {
                        SetHeaders(exerciseQuantifier: exerciseQuantifier, exerciseMeasurement: exerciseMeasurement, active: false)
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                    }

                    ForEach(Array(sets.enumerated()), id: \.element.id) { setIndex, _ in
                        VStack(spacing: 0) {
                            ExerciseRow(
                                setIndex: setIndex + 1,
                                setInput: $sets[setIndex],
                                exerciseQuantifier: exerciseQuantifier,
                                exerciseMeasurement: exerciseMeasurement
                            )
                            .environmentObject(focusManager)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)

                            if setIndex < sets.count - 1 {
                                Divider()
                                    .padding(.horizontal, 16)
                            }
                        }
                    }

                    // Add Set Button
                    Button(action: { addSetAction?() }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.body)
                            Text("Add Set")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.myBlue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.myBlue.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 16)
                }
            }
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
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
