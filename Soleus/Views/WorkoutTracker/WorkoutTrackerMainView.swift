import SwiftUI
import SwiftData

struct WorkoutTrackerMainView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var workoutController: WorkoutTrackerController
    @State private var deletingWorkouts: Set<UUID> = []
    @State private var duplicatingWorkouts: Set<UUID> = []
    @State private var presentingModal: ModalType? = nil
    @State private var showDocumentPicker = false
    @State private var importedWorkout: ShareableWorkout?
    @State private var showImportPreview = false
    @State private var isLoadingImport = false
    @State private var isEditMode = false
    @State private var draggingId: UUID?
    @State private var dragPosition: CGPoint = .zero
    @State private var draggingCardSize: CGSize = .zero
    @State private var cardFrames: [UUID: CGRect] = [:]
    @State private var reorderCooldown = false
    @GestureState private var isDragActive = false

    private var visibleWorkouts: [WorkoutInfo] {
        workoutController.workouts.filter { !deletingWorkouts.contains($0.id) }
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                ScrollView {
                    Divider()
                    workoutGrid
                }
                .scrollDisabled(draggingId != nil)
                .onPreferenceChange(WorkoutCardFrameKey.self) { cardFrames = $0 }
                .onChange(of: isDragActive) {
                    // GestureState reverts to false on system cancellation — clean up any stuck drag
                    if !isDragActive, draggingId != nil {
                        reorderCooldown = false
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            draggingId = nil
                        }
                        workoutController.workoutManager.saveWorkoutOrder(workouts: workoutController.workouts)
                    }
                }

                // Floating card that follows the finger during a drag
                if let id = draggingId {
                    CardView(workoutId: id, isEditMode: true, isDragging: true)
                        .environmentObject(workoutController)
                        .environmentObject(appViewModel)
                        .frame(width: draggingCardSize.width, height: draggingCardSize.height)
                        .scaleEffect(1.05)
                        .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
                        .position(
                            x: dragPosition.x - proxy.frame(in: .global).minX,
                            y: dragPosition.y - proxy.frame(in: .global).minY
                        )
                        .allowsHitTesting(false)
                }
            }
        }
        .navigationBarItems(trailing: HStack(spacing: 20) {
            if !visibleWorkouts.isEmpty {
                Button(action: {
                    isEditMode.toggle()
                }) {
                    Image(systemName: isEditMode ? "checkmark.circle.fill" : "arrow.up.arrow.down.circle")
                        .foregroundColor(isEditMode ? .green : .primary)
                        .help(isEditMode ? "Done rearranging" : "Rearrange workouts")
                }
                .accessibilityIdentifier(AccessibilityID.navReorderButton)
            }
            Button(action: {
                // Clear any previous import data
                importedWorkout = nil
                showImportPreview = false
                isLoadingImport = false
                showDocumentPicker = true
            }) {
                Image(systemName: "square.and.arrow.down")
                    .help("Import workout")
            }
            .accessibilityIdentifier(AccessibilityID.navImportButton)
            .disabled(isEditMode)
            .opacity(isEditMode ? 0.5 : 1.0)
            Button(action: {
                appViewModel.navigateTo(.workoutHistoryView)
            }) {
                Image(systemName: "clock")
                    .help("View workout history")
            }
            .accessibilityIdentifier(AccessibilityID.navHistoryButton)
            .disabled(isEditMode)
            .opacity(isEditMode ? 0.5 : 1.0)
            Button(action: {
                presentingModal = .add
            }) {
                Image(systemName: "plus")
                    .help("Create a new workout")
            }
            .accessibilityIdentifier(AccessibilityID.navAddWorkoutButton)
            .disabled(isEditMode)
            .opacity(isEditMode ? 0.5 : 1.0)
        }
        .glassEffect(in: Capsule())
        )
        .onAppear {
            workoutController.loadWorkouts()
            consumePendingImport()
        }
        .onChange(of: appViewModel.pendingImport) {
            consumePendingImport()
        }
        .background(Color.myWhite.ignoresSafeArea())
        .sheet(item: $presentingModal) { modal in
            switch modal {
            case .add:
                AddWorkoutView(workoutId: UUID(), navigationTitle: "Create Workout Plan", update: false)
                    .environmentObject(appViewModel)
                    .environmentObject(workoutController)
            case .edit(let workoutId):
                AddWorkoutView(workoutId: workoutId, navigationTitle: "Edit Workout Plan", update: true)
                    .environmentObject(appViewModel)
                    .environmentObject(workoutController)
            }
        }
        .sheet(isPresented: $showDocumentPicker, onDismiss: {
            // When document picker dismisses, wait longer to ensure file is fully read
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let _ = importedWorkout, !showImportPreview {
                    showImportPreview = true
                } else if importedWorkout == nil {
                    // If still no workout after delay, file reading may have failed
                    AppLogger.lifecycle.warning("No workout loaded after document picker dismissed")
                }
            }
        }) {
            DocumentPicker(importedWorkout: $importedWorkout, showImportPreview: .constant(false))
        }
        .sheet(isPresented: $showImportPreview, onDismiss: {
            // Clean up after import preview is dismissed
            importedWorkout = nil
            // Clear stale workoutDetails left by importWorkout() so subsequent
            // edits start from a clean state (same as any non-imported workout).
            workoutController.workoutDetails = []
        }) {
            ImportWorkoutPreviewContent(
                importedWorkout: $importedWorkout,
                showImportPreview: $showImportPreview
            )
            .environmentObject(workoutController)
        }
    }
    
    private var workoutGrid: some View {
        VStack(spacing: 0) {
            if isEditMode {
                HStack(spacing: 8) {
                    Image(systemName: "hand.point.up.left")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    Text("Long press a card, then drag to reorder")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            if workoutController.hasActiveSession, let workoutId = workoutController.activeWorkoutId {
                Button(action: {
                    appViewModel.navigateTo(.workoutActiveView(workoutId))
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "figure.run.circle.fill")
                            .font(.title2)
                            .foregroundColor(.staticWhite)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(workoutController.activeWorkoutName ?? "Workout")
                                .font(.headline)
                                .foregroundColor(.staticWhite)
                            Text("Tap to Resume")
                                .font(.subheadline)
                                .foregroundColor(.staticWhite.opacity(0.9))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.body)
                            .foregroundColor(.staticWhite.opacity(0.7))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.myBlue, Color.myBlue.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: Color.myBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                .accessibilityIdentifier(AccessibilityID.activeSessionBanner)
            }
            if visibleWorkouts.isEmpty && !isEditMode {
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 60)

                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.myBlue.opacity(0.5))

                    VStack(spacing: 8) {
                        Text("No Workouts Yet")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .accessibilityIdentifier(AccessibilityID.emptyStateTitle)

                        Text("Create your first workout to get started")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    Button(action: {
                        presentingModal = .add
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                            Text("Create Workout")
                                .font(.headline)
                        }
                        .foregroundColor(.staticWhite)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.myBlue)
                        .cornerRadius(10)
                    }
                    .accessibilityIdentifier(AccessibilityID.emptyStateCreateButton)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding()
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(workoutController.workouts) { workout in
                    if !deletingWorkouts.contains(workout.id) {
                        CardView(
                            workoutId: workout.id,
                            onDelete: { deleteWorkouts(workout.id) },
                            onDuplicate: { duplicateWorkout(workout.id) },
                            isEditMode: isEditMode,
                            isDragging: false
                        )
                        .background(
                            GeometryReader { geo in
                                Color.clear.preference(
                                    key: WorkoutCardFrameKey.self,
                                    value: [workout.id: geo.frame(in: .global)]
                                )
                            }
                        )
                        // Hide (but preserve the slot) while this card is floating
                        .opacity(draggingId == workout.id ? 0 : 1)
                        .scaleEffect(isEditMode ? 0.95 : 1.0)
                        .transition(.asymmetric(insertion: .opacity.combined(with: .scale), removal: .opacity.combined(with: .scale)))
                        .environmentObject(appViewModel)
                        .environmentObject(workoutController)
                        .if(isEditMode) { view in
                            view
                                .onLongPressGesture(minimumDuration: 0.4) {
                                    guard draggingId == nil else { return }
                                    if let frame = cardFrames[workout.id] {
                                        draggingCardSize = frame.size
                                        dragPosition = CGPoint(x: frame.midX, y: frame.midY)
                                    }
                                    draggingId = workout.id
                                    HapticManager.shared.medium()
                                }
                                .simultaneousGesture(
                                    DragGesture(minimumDistance: 0, coordinateSpace: .global)
                                        .updating($isDragActive) { _, state, _ in state = true }
                                        .onChanged { drag in
                                            guard draggingId == workout.id else { return }
                                            dragPosition = drag.location
                                            checkReorder(at: drag.location, for: workout.id)
                                        }
                                        .onEnded { _ in
                                            guard draggingId != nil else { return }
                                            reorderCooldown = false
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                draggingId = nil
                                            }
                                            workoutController.workoutManager.saveWorkoutOrder(workouts: workoutController.workouts)
                                        }
                                )
                        }
                    }
                }
            }
            .padding()
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: workoutController.workouts)
        }
    }
    
    private func deleteWorkouts(_ workoutId: UUID) {
        _ = withAnimation {
            deletingWorkouts.insert(workoutId)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            workoutController.deleteWorkout(workoutId)

            // Wait for workouts array to update, then check if workout is gone
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                // Only remove from deletingWorkouts if the workout is actually gone
                if !workoutController.workouts.contains(where: { $0.id == workoutId }) {
                    deletingWorkouts.remove(workoutId)
                }
            }
        }
    }
    
    private func consumePendingImport() {
        guard let pending = appViewModel.pendingImport else { return }
        appViewModel.pendingImport = nil
        importedWorkout = nil
        showImportPreview = false
        importedWorkout = pending
        showImportPreview = true
    }

    private func duplicateWorkout(_ workoutId: UUID) {
        withAnimation {
            duplicatingWorkouts.insert(workoutId)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation {
                    workoutController.duplicateWorkout(workoutId)
                    duplicatingWorkouts.remove(workoutId)
                }
            }
        }
    }

    private func checkReorder(at position: CGPoint, for dragId: UUID) {
        guard !reorderCooldown else { return }
        guard let fromIndex = workoutController.workouts.firstIndex(where: { $0.id == dragId }) else { return }
        guard let targetId = cardFrames.first(where: { $0.key != dragId && $0.value.contains(position) })?.key,
              let toIndex = workoutController.workouts.firstIndex(where: { $0.id == targetId }) else { return }

        withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
            workoutController.workouts.move(
                fromOffsets: IndexSet(integer: fromIndex),
                toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex
            )
        }
        HapticManager.shared.selection()
        reorderCooldown = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            reorderCooldown = false
        }
    }
}

private struct WorkoutCardFrameKey: PreferenceKey {
    static var defaultValue: [UUID: CGRect] = [:]
    static func reduce(value: inout [UUID: CGRect], nextValue: () -> [UUID: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

// Helper view that reacts to changes in importedWorkout
struct ImportWorkoutPreviewContent: View {
    @Binding var importedWorkout: ShareableWorkout?
    @Binding var showImportPreview: Bool
    @EnvironmentObject var workoutController: WorkoutTrackerController

    var body: some View {
        Group {
            if let workout = importedWorkout {
                ImportWorkoutPreviewView(shareableWorkout: workout, isPresented: $showImportPreview)
                    .environmentObject(workoutController)
            } else {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading workout...")
                        .font(.headline)
                }
                .padding()
                .onAppear {
                    // Dismiss if workout doesn't load within 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        if importedWorkout == nil {
                            showImportPreview = false
                        }
                    }
                }
            }
        }
    }
}
