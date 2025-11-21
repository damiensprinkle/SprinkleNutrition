import SwiftUI

struct CardView: View {
    var workoutId: UUID
    var onDelete: (() -> Void)?
    var onDuplicate: (() -> Void)?
    var isEditMode: Bool = false

    @EnvironmentObject var workoutController: WorkoutTrackerController
    @EnvironmentObject var appViewModel: AppViewModel

    @State private var presentingModal: ModalType? = nil
    @State private var animate = false
    @State private var pulseOpacity = false
    @State private var rotation = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var workout: Workouts?
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var shakeOffset: CGFloat = 0


    var body: some View {
        let backgroundColor = Color(workout?.color ?? "MyBlue")

        ZStack {
            // Base card
            VStack {
                existingWorkoutCardContent(workout: workout)
            }
            .padding()
            .background(
                ZStack {
                    // Main color background
                    backgroundColor

                    // Subtle gradient overlay for depth
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.1),
                            Color.clear,
                            Color.black.opacity(0.15)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .cornerRadius(18)
        }
        .aspectRatio(1, contentMode: .fit)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        .shadow(color: backgroundColor.opacity(0.3), radius: 12, x: 0, y: 6)
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 18))
        .rotationEffect(.degrees(isEditMode ? shakeOffset : 0))
        .onAppear {
            let manager = workoutController.workoutManager
            workout = manager.fetchWorkoutById(for: workoutId)

            if isEditMode {
                startShakeAnimation()
            }
        }
        .onChange(of: workoutController.workouts) { _, newWorkouts in
            // Only refresh if this workout still exists in the array
            if newWorkouts.contains(where: { $0.id == workoutId }) {
                let manager = workoutController.workoutManager
                workout = manager.fetchWorkoutById(for: workoutId)
            }
        }
        .onChange(of: isEditMode) { _, newValue in
            if newValue {
                startShakeAnimation()
            }
        }
        .if(!isEditMode) { view in
            view.contextMenu { contextMenuContent() }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            if alertTitle.contains("Are you sure you want to delete this workout?") {
                Button("Delete", role: .destructive) {
                    onDelete?()
                }
                Button("Cancel", role: .cancel) { }
            }
            else{
                Button("Dismiss", role: .cancel) { }
            }
            
        }
        .sheet(item: $presentingModal) { modal in
            switch modal {
            case .add:
                AddWorkoutView(workoutId: UUID(), navigationTitle: "", update: false) // not used
            case .edit(let workoutId):
                AddWorkoutView(workoutId: workoutId, navigationTitle: "Edit Workout Plan", update: true)
                    .environmentObject(appViewModel)
                    .environmentObject(workoutController)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if !shareItems.isEmpty {
                ActivityViewController(activityItems: shareItems)
            }
        }
    }
    
    @ViewBuilder
    private func existingWorkoutCardContent(workout: Workouts?) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Workout name
            Text(workout?.name ?? "Workout")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.staticWhite)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)

            Spacer()

            // Play button
            HStack {
                Spacer()
                Button(action: {
                    if let activeWorkoutId = workoutController.activeWorkoutId, activeWorkoutId != workoutId {
                        alertTitle = "You must complete your current session before starting a new one"
                        showAlert = true
                    } else {
                        appViewModel.navigateTo(.workoutActiveView(workoutId))
                    }
                }) {
                    playButtonContent()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func playButtonContent() -> some View {
        if(workoutController.hasActiveSession && workoutController.activeWorkoutId == workoutId) {
                ZStack {
                    // Outer glow ring
                    Circle()
                        .stroke(Color.green.opacity(pulseOpacity ? 0.3 : 0.0), lineWidth: 3)
                        .frame(width: 50, height: 50)
                        .scaleEffect(pulseOpacity ? 1.4 : 1.0)

                    // Main icon with multiple animations
                    Image(systemName: "figure.run.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                        .scaleEffect(animate ? 1.15 : 1.0)
                        .rotationEffect(.degrees(rotation ? 2 : -2))
                        .shadow(color: .green.opacity(0.6), radius: animate ? 8 : 4)
                }
                .onAppear {
                    // Pulse scale animation
                    withAnimation(
                        Animation.easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true)
                    ) {
                        animate = true
                    }

                    // Glow ring animation
                    withAnimation(
                        Animation.easeOut(duration: 1.5)
                            .repeatForever(autoreverses: false)
                    ) {
                        pulseOpacity = true
                    }

                    // Subtle rotation animation
                    withAnimation(
                        Animation.easeInOut(duration: 1.2)
                            .repeatForever(autoreverses: true)
                    ) {
                        rotation = true
                    }
                }
        } else {
            ZStack {
                // Background circle
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 56, height: 56)

                // Play icon
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.staticWhite)
                    .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
            }
        }
    }
    
    @ViewBuilder
    private func contextMenuContent() -> some View {
        Button(action: {
            if  workoutController.activeWorkoutId == workoutId {
                alertTitle = "You Cannot Edit a Workout That Is In Progress"
                showAlert = true
            } else {
                presentingModal = .edit(workoutId: workoutId)
            }
        }) {
            Label("Edit", systemImage: "square.and.pencil")
        }

        Button(action: {
            onDuplicate?()
        }) {
            Label("Duplicate", systemImage: "doc.on.doc")
        }

        Button(action: {
            shareWorkout()
        }) {
            Label("Share Workout", systemImage: "square.and.arrow.up")
        }

        Button(action: {
            appViewModel.navigateTo(.customizeCardView(workoutId))
        }) {
            Label("Customize Card", systemImage: "paintpalette")
        }

        Button(role: .destructive, action: {
            if  workoutController.activeWorkoutId == workoutId {
                alertTitle = "You Cannot Delete a Workout That Is In Progress"
                showAlert = true
            }
            else{
                alertTitle =  "Are you sure you want to delete this workout?"
                showAlert = true
            }
        }) {
            Label("Delete", systemImage: "trash")
        }
    }

    private func shareWorkout() {
        guard let data = workoutController.exportWorkout(workoutId) else {
            alertTitle = "Failed to export workout"
            showAlert = true
            return
        }

        let workoutName = workout?.name ?? "Workout"
        let fileName = "\(workoutName.replacingOccurrences(of: " ", with: "_")).flexsprinkle"

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try data.write(to: tempURL)
            shareItems = [tempURL]
            showShareSheet = true
        } catch {
            alertTitle = "Failed to create shareable file"
            showAlert = true
        }
    }

    private func startShakeAnimation() {
        withAnimation(
            Animation.easeInOut(duration: 0.15)
                .repeatForever(autoreverses: true)
        ) {
            shakeOffset = 1.5
        }
    }
}

// Extension to conditionally apply modifiers
extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
