import SwiftUI

struct CardView: View {
    var title: String
    var isDefault: Bool
    var onDelete: (() -> Void)?
    @Binding var navigationPath: NavigationPath
    @State private var presentingModal: ModalType? = nil
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        let workoutDetails = workoutManager.fetchWorkoutDetails(for: title)
        let colorName = workoutDetails.first?.color ?? "MyBlue" // Fallback color name just in case
        let backgroundColor = Color(colorName) // Use your color logic here
        
        VStack {
            if isDefault {
                defaultCardContent()
            } else {
                existingWorkoutCardContent(details: workoutDetails)
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(15)
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.gray, lineWidth: 1))
        .aspectRatio(1, contentMode: .fit)
        .contextMenu { contextMenuContent() }
        .sheet(item: $presentingModal) { modal in
            switch modal {
                case .add:
                    AddWorkoutView()
                case .edit(let originalTitle):
                    EditWorkoutView(workoutTitle: originalTitle, workoutDetails: workoutDetails, originalWorkoutTitle: originalTitle)
                    .environmentObject(workoutManager)
            }
        }
    }
    
    @ViewBuilder
    private func defaultCardContent() -> some View {
        HStack {
            Text("Add")
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
    private func existingWorkoutCardContent(details: [WorkoutDetail]) -> some View {
        HStack {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            Spacer()
        }
        
        Spacer()
        Button(action: {
            if let detail = workoutManager.fetchWorkoutDetails(for: title).first {
                navigationPath.append(detail)
            }
        }) {
            Image(systemName: "play.circle")
                .font(.system(size: 40))
                .foregroundColor(.white)
        }



    }
    
    @ViewBuilder
    private func contextMenuContent() -> some View {
        Button("Edit") {
            presentingModal = .edit(originalTitle: title)
        }
        Button("Delete", action: {
            onDelete?()
        })
    }
}
