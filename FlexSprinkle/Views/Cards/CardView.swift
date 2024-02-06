import SwiftUI

struct CardView: View {
    var title: String
    var isDefault: Bool
    var workoutManager: WorkoutManager
    var onDelete: (() -> Void)?
    var color: Color?

    @State private var isFormPresented = false
    @State private var isPlayActiveWorkout = false
    @State private var isContextMenuPresented = false

    var body: some View {
        let backgroundColor = color ?? Color.black // Use provided color or random color

        return VStack {
            if isDefault {
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
                        isFormPresented.toggle()
                    }
                    .sheet(isPresented: $isFormPresented) {
                        AddWorkoutView(
                            isFormPresented: $isFormPresented,
                            onSave: { newWorkout, newColor in
                                workoutManager.workouts.append(newWorkout)
                                workoutManager.saveWorkouts()
                            },
                            workoutManager: workoutManager
                        )
                    }
            } else {
                HStack {
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                    Spacer()

                    VStack {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 0))
                            .foregroundColor(.white)
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                isContextMenuPresented.toggle()
                            }
                    }
                }

                Spacer()

                Image(systemName: "play.circle")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .onTapGesture {
                        isPlayActiveWorkout.toggle()
                    }
                    .background(
                        NavigationLink(
                            destination: ActiveWorkout(workoutDetails: workoutManager.fetchWorkoutDetails(for: title)),
                            isActive: $isPlayActiveWorkout
                        ) {
                            EmptyView()
                        }
                        .hidden()
                    )
            }
            Spacer()
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray, lineWidth: 1)
        )
        .aspectRatio(1, contentMode: .fit)
        .contextMenu {
            Button("Edit") {
                isFormPresented.toggle()
                isContextMenuPresented.toggle()
            }
            Button("Delete") {
                onDelete?()
                isContextMenuPresented.toggle()
            }
        }
        .sheet(isPresented: $isFormPresented) {
            EditWorkoutView(
                isFormPresented: $isFormPresented,
                workoutTitle: title,
                workoutDetails: workoutManager.fetchWorkoutDetails(for: title),
                onSave: { newTitle, newDetails in
                    workoutManager.editWorkout(oldTitle: title, newTitle: newTitle, newDetails: newDetails)
                }
            )
        }
    }
}
