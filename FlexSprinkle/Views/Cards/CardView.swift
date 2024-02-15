import SwiftUI

struct CardView: View {
    var workoutId: UUID
    var onDelete: (() -> Void)?
    var hasActiveSession: Bool
    
    @State private var presentingModal: ModalType? = nil
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var animate = false
    @State private var showAlert = false
    @State private var showingDeletionConfirmation = false
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var alertTitle = ""

    
    var body: some View {
        let workout = workoutManager.fetchWorkoutById(for: workoutId)
        let backgroundColor = Color(workout?.color ?? "MyBlue")
        
        VStack {
            existingWorkoutCardContent(workout: workout)
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(15)
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.gray, lineWidth: 1))
        .aspectRatio(1, contentMode: .fit)
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 15))
        .contextMenu { contextMenuContent() }
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
                AddWorkoutView(workoutId: UUID(), navigationTitle: "") // not used
            case .edit(let workoutId):
                AddWorkoutView(workoutId: workoutId, navigationTitle: "Edit Workout Plan")
                    .environmentObject(workoutManager)
                    .environmentObject(appViewModel)

            }
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
                alertTitle = "You must complete your current session before starting a new one"
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
                    .onAppear {
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
    }
    
    @ViewBuilder
    private func contextMenuContent() -> some View {
        Button(action: {
            presentingModal = .edit(workoutId: workoutId)
        }) {
            Label("Edit", systemImage: "square.and.pencil")
        }
        
        Button(action: {
            let sessionId = workoutManager.getSessions().first?.workoutsR?.id
            if  sessionId == workoutId {
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

}

