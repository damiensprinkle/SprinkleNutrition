import SwiftUI

struct CardView: View {
    var title: String
    var isDefault: Bool
    var onDelete: (() -> Void)?
    @State private var isNavigateActive = false
    @State private var presentingModal: ModalType? = nil
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        let details = workoutManager.fetchWorkoutDetails(for: title)
        let colorName = details.first?.color ?? "MyBlue" // Fallback color name just in case
    
        let backgroundColor = Color(colorName, bundle: nil)
        
        VStack {
            if isDefault {
                defaultCardContent()
            } else {
                existingWorkoutCardContent()
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
                let details = workoutManager.fetchWorkoutDetails(for: originalTitle)
                EditWorkoutView(workoutTitle: originalTitle, workoutDetails: details, originalWorkoutTitle: originalTitle)
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
        Image(systemName: "plus.circle")
            .font(.system(size: 40))
            .foregroundColor(.white)
            .onTapGesture {
                presentingModal = .add
            }
    }
    
    @ViewBuilder
    private func existingWorkoutCardContent() -> some View {
        let workoutDetails = workoutManager.fetchWorkoutDetails(for: title)
        
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
        
        // Use the ZStack to overlay the play.circle icon on top of an invisible NavigationLink
        ZStack {
            // The invisible NavigationLink controlled by isNavigateActive
            NavigationLink(destination: ActiveWorkoutView(workoutDetails: workoutDetails), isActive: $isNavigateActive) {
                EmptyView()
            }
            .hidden()
            
            // The play.circle icon that starts
            Image(systemName: "play.circle")
                .font(.system(size: 40))
                .foregroundColor(.white)
                .onTapGesture {
                    // Trigger navigation by setting isNavigateActive to true
                    isNavigateActive = true
                }
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
