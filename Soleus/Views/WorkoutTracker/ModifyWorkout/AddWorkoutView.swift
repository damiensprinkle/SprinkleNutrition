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
    @State private var showingTemplatePickerSheet = false
    @State private var pendingTemplate: WorkoutTemplate? = nil
    @State private var formID = UUID()
    @State private var hasLoaded = false
    @FocusState private var isTitleFocused: Bool
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom navigation header (replaces NavigationView to avoid nested nav conflict)
                HStack {
                    Button("Cancel") {
                        if initialWorkoutDetails != workoutController.workoutDetails {
                            alertMessage = "You have unsaved changes are you sure you want to cancel?"
                            activeAlert = .cancelConfirmation
                            showAlert = true
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .accessibilityIdentifier(AccessibilityID.addWorkoutCancelButton)

                    Spacer()

                    Text(navigationTitle)
                        .font(.headline)

                    Spacer()

                    Button("Save") {
                        let result = workoutController.saveWorkout(title: workoutTitle, update: update, workoutId: workoutId)
                        switch result {
                        case .success:
                            presentationMode.wrappedValue.dismiss()
                        case .failure(let error):
                            handleSaveError(error)
                        }
                    }
                    .accessibilityIdentifier(AccessibilityID.addWorkoutSaveButton)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(.systemGroupedBackground))

                Divider()

                addWorkoutForm
                    .id(formID)

                if !focusManager.isAnyTextFieldFocused {
                    bottomButtons
                }
            }
            .background(Color(.systemGroupedBackground))
        }
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
                case .templateOverwriteConfirmation:
                    return Alert(
                        title: Text("Replace Workout?"),
                        message: Text("This will overwrite your current title and exercises. This cannot be undone."),
                        primaryButton: .destructive(Text("Replace")) {
                            if let template = pendingTemplate {
                                applyTemplate(template)
                            }
                            pendingTemplate = nil
                        },
                        secondaryButton: .cancel {
                            pendingTemplate = nil
                        }
                    )
                }
            }
            .onAppear {
                guard !hasLoaded else { return }
                hasLoaded = true
                workoutController.workoutDetails = []
                formID = UUID()
                if update {
                    workoutController.loadWorkoutDetails(for: workoutId)
                    workoutTitle = workoutController.selectedWorkoutName ?? ""
                    initialWorkoutDetails = workoutController.workoutDetails
                }
            }
            .sheet(isPresented: $showingTemplatePickerSheet) {
                TemplatePickerView(isPresented: $showingTemplatePickerSheet) { template in
                    let hasExistingContent = !workoutController.workoutDetails.isEmpty || !workoutTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    if hasExistingContent {
                        showingTemplatePickerSheet = false
                        pendingTemplate = template
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            activeAlert = .templateOverwriteConfirmation
                            showAlert = true
                        }
                    } else {
                        applyTemplate(template)
                        showingTemplatePickerSheet = false
                    }
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
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
    
    private var bottomButtons: some View {
        VStack(spacing: 8) {
            Button(action: {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
            .accessibilityIdentifier(AccessibilityID.addWorkoutAddExerciseButton)

            if !update {
                Button(action: { showingTemplatePickerSheet = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.plaintext")
                            .font(.title3)
                        Text("Start from Template")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.myBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.myBlue.opacity(0.1))
                    .cornerRadius(14)
                }
                .accessibilityIdentifier(AccessibilityID.templatePickerButton)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 20)
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
                        .focused($isTitleFocused)
                        .font(.body)
                        .padding(16)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .accessibilityIdentifier(AccessibilityID.addWorkoutTitleField)
                }
                .padding(.bottom, 8)

                // Exercise Cards
                ForEach(Array(workoutController.workoutDetails.enumerated()), id: \.element.id) { index, detail in
                    ExerciseCard(
                        exerciseName: detail.exerciseName,
                        hasNotes: detail.notes != nil && !detail.notes!.isEmpty,
                        notes: detail.notes,
                        index: index,
                        workoutCount: workoutController.workoutDetails.count,
                        isKeyboardActive: focusManager.isAnyTextFieldFocused,
                        sets: Binding(
                            get: { index < workoutController.workoutDetails.count ? workoutController.workoutDetails[index].sets : detail.sets },
                            set: { if index < workoutController.workoutDetails.count { workoutController.workoutDetails[index].sets = $0 } }
                        ),
                        exerciseQuantifier: detail.exerciseQuantifier,
                        exerciseMeasurement: detail.exerciseMeasurement,
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
                    .accessibilityIdentifier("\(AccessibilityID.exerciseCard)_\(index)")
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

                    ForEach(Array(sets.enumerated()), id: \.element.id) { setIndex, set in
                        VStack(spacing: 0) {
                            ExerciseRow(
                                setIndex: setIndex + 1,
                                setInput: Binding(
                                    get: { setIndex < sets.count ? sets[setIndex] : set },
                                    set: { if setIndex < sets.count { sets[setIndex] = $0 } }
                                ),
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
    
    private func applyTemplate(_ template: WorkoutTemplate) {
        workoutTitle = template.name
        workoutController.workoutDetails = template.toWorkoutDetails()
        formID = UUID()
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
    case error, deleteConfirmation, cancelConfirmation, templateOverwriteConfirmation
}
