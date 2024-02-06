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
                        WorkoutFormView(
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

struct ColorManager {
    private static var availableColors: [Color] = [
        Color(hex: "#02A1D6"),
        Color(hex: "#0282AD"),
        Color(hex: "#02BDFA"),
        Color(hex: "#016485"),
        Color(hex: "#A802D6"),
        Color(hex: "#8802AD"),
        Color(hex: "#70008F"),
        Color(hex: "#48015C")
        // Add more colors as needed
    ]

    static func randomColor() -> Color? {
        guard !availableColors.isEmpty else {
            // If all colors are used, reset the list
            resetColors()
            return randomColor()
        }

        let randomIndex = Int.random(in: 0..<availableColors.count)
        let color = availableColors.remove(at: randomIndex)
        return color
    }

    private static func resetColors() {
        availableColors = [
            Color(hex: "#02A1D6"),
            Color(hex: "#0282AD"),
            Color(hex: "#02BDFA"),
            Color(hex: "#016485"),
            Color(hex: "#A802D6"),
            Color(hex: "#8802AD"),
            Color(hex: "#70008F"),
            Color(hex: "#48015C")
            // Add more colors as needed
        ]
    }
}
