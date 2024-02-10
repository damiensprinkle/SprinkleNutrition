import SwiftUI

struct CardView: View {
    var workoutId: UUID
    var isDefault: Bool
    var onDelete: (() -> Void)?
    var hasActiveSession: Bool
    
    @State private var presentingModal: ModalType? = nil
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var animate = false
    @State private var showAlert = false
    
    @State private var showingDeletionConfirmation = false
    @EnvironmentObject var appViewModel: AppViewModel

    
    
    var body: some View {
        let workout = workoutManager.fetchWorkoutById(for: workoutId)
        let backgroundColor = Color(workout?.color ?? "MyBlue") // Use the w
        
        VStack {
            if isDefault {
                defaultCardContent()
            } else {
                existingWorkoutCardContent(workout: workout)
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(15)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.gray, lineWidth: 1))
        .aspectRatio(1, contentMode: .fit)
        .contextMenu { contextMenuContent() }
        .alert("Are you sure you want to delete this workout?", isPresented: $showingDeletionConfirmation) {
            Button("Delete", role: .destructive) {
                onDelete?()
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(item: $presentingModal) { modal in
            switch modal {
            case .add:
                AddWorkoutView()
            case .edit(let workoutId):
                EditWorkoutView(workoutId: workoutId)
                    .environmentObject(workoutManager)
            }
        }
        .onAppear{
            
        }
    }
    
    @ViewBuilder
    private func defaultCardContent() -> some View {
        HStack {
            Text("Add Workout")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            Spacer()
        }
        Spacer()
        Button(action: { presentingModal = .add }) {
            Image(systemName: "plus.circle")
                .font(.system(size: 40))
                .foregroundColor(.white)
        }
    }
    
    @ViewBuilder
    private func existingWorkoutCardContent(workout: Workouts?) -> some View {
        HStack {
            Text(workout?.name ?? "Workout")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            Spacer()
        }
        
        Spacer()
        Button(action: {
            let sessionId = workoutManager.getSessions().first?.workoutsR?.id
            if  sessionId != workoutId && sessionId != nil {
                showAlert = true
            } else {
                appViewModel.navigateTo(.workoutActiveView(workoutId))
            }
        }) {
            if(hasActiveSession) {
                Image(systemName: "figure.run.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
                    .scaleEffect(animate ? 1.2 : 1.0) 
                // Use animate state to toggle scale
                    .onAppear {
                        // Properly initiate the animation
                        withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                            animate = true
                        }
                        
                    }
            }
            else{
                Image(systemName: "play.circle")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Active Session Detected"),
                message: Text("You must complete or end your current session before starting a new one."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    @ViewBuilder
    private func contextMenuContent() -> some View {
        if !isDefault {
            Button("Edit") {
                presentingModal = .edit(workoutId: workoutId)
            }
            Button("Delete", role: .destructive) {
                showingDeletionConfirmation = true
            }
        }
    }
    
}
