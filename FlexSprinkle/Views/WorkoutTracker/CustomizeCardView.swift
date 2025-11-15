import SwiftUI

struct CustomizeCardView: View {
    var workoutId: UUID
    @EnvironmentObject var workoutController: WorkoutTrackerController
    @EnvironmentObject var appViewModel: AppViewModel
    
    private let colorManager = ColorManager()
    
    @State private var colorNames: [String] = []
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    VStack {
                        Spacer()
                        CardColorPickerView(
                            selectedColor: Binding(
                                get: { workoutController.cardColor ?? "MyBlue" },
                                set: { workoutController.cardColor = $0 }
                            ),
                            colorNames: colorNames
                        )
                    }
                }
                .padding()
                .background(
                    Color(workoutController.cardColor ?? "MyBlue")
                )
                .cornerRadius(15)
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.myBlack, lineWidth: 1))
                .aspectRatio(1, contentMode: .fit)
                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 15))
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.myWhite)
        .onAppear {
            workoutController.loadWorkoutColors(for: workoutId)
            colorNames = colorManager.colorNames
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    workoutController.saveWorkoutColor(workoutId: workoutId)
                    appViewModel.resetToWorkoutMainView()
                }
                .font(.headline)
            }
        }
    }
}

struct CardColorPickerView: View {
    @Binding var selectedColor: String
    let colorNames: [String]
    
    private let gridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            Text("Select Card Color")
                .font(.headline)
                .padding(.bottom, 10)
            
            LazyVGrid(columns: gridColumns, spacing: 16) {
                ForEach(colorNames.indices, id: \.self) { index in
                    colorButton(for: index)
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private func colorButton(for index: Int) -> some View {
        Button(action: {
            selectedColor = colorNames[index]
        }) {
            VStack {
                colorSquare(for: index)
                colorLabel(for: index)
            }
        }
    }
    
    @ViewBuilder
    private func colorSquare(for index: Int) -> some View {
        Color(colorNames[index])
            .frame(width: 60, height: 60)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selectedColor == colorNames[index] ? Color.black : Color.clear, lineWidth: 2)
            )
    }
    
    @ViewBuilder
    private func colorLabel(for index: Int) -> some View {
        Text("\(index + 1)")
            .font(.subheadline)
            .foregroundColor(Color.myBlack)
    }
}
