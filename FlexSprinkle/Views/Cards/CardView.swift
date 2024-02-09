import SwiftUI

struct CardView: View {
    var title: String
    var workoutId: UUID
    var isDefault: Bool
    var onDelete: (() -> Void)?
    @Binding var navigationPath: NavigationPath
    @State private var presentingModal: ModalType? = nil
    @EnvironmentObject var workoutManager: WorkoutManager
    
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
        .sheet(item: $presentingModal) { modal in
            switch modal {
                case .add:
                    AddWorkoutView()
                case .edit(let workoutId, let originalTitle):
                EditWorkoutView(workoutId: workoutId)
                    .environmentObject(workoutManager)
            }
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
            // Directly navigate using workoutId
            navigationPath.append(workoutId)
        }) {
            Image(systemName: "play.circle")
                .font(.system(size: 40))
                .foregroundColor(.white)
        }
    }
    
    @ViewBuilder
    private func contextMenuContent() -> some View {
        if !isDefault {
            Button("Edit") {
                presentingModal = .edit(workoutId: workoutId, originalTitle: title)
            }
            Button("Delete", action: {
                onDelete?()
            })
        }
    }
}
