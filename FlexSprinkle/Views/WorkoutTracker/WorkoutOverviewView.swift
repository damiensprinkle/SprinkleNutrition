import SwiftUI
import ConfettiSwiftUI


/// This is the view that occurs when you complete a workout
struct WorkoutOverviewView: View {
    var workoutId: UUID
    var workoutDetails: [WorkoutDetailInput] = []
    
    @EnvironmentObject var workoutController: WorkoutTrackerController
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var counter = 0
    @State private var history: WorkoutHistory?
    
    @State private var totalCardioTime = ""
    @State private var showProceedButton = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            ScrollView {
                Divider()
                LazyVGrid(columns: columns, spacing: 20) {
                    if let repsCompleted = history?.repsCompleted, repsCompleted > 0 {
                        DataCardView(icon: Image(systemName: "figure.walk"), number: "\(repsCompleted)", description: "Reps Completed")
                            .transition(.scale.combined(with: .opacity))
                    }
                    if let totalWeightLifted = history?.totalWeightLifted, totalWeightLifted > 0 {
                        DataCardView(icon: Image(systemName: "scalemass"), number: "\(totalWeightLifted)", description: "Total Weight Lifted")
                            .transition(.scale.combined(with: .opacity))
                    }
                    if !totalCardioTime.isEmpty && totalCardioTime != "00:00:00" {
                        DataCardView(icon: Image(systemName: "timer"), number: totalCardioTime, description: "Time Doing Cardio")
                            .transition(.scale.combined(with: .opacity))
                    }
                    if let totalDistance = history?.totalDistance, totalDistance > 0.0 {
                        DataCardView(icon: Image(systemName: "gauge.with.needle"), number: "\(totalDistance)", description: "Total Distance")
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding()
            }
            
            if showProceedButton {
                VStack {
                    Spacer()
                    Button(action: {
                        appViewModel.resetToWorkoutMainView()
                    }) {
                        Text("Proceed")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.staticWhite)
                            .background(Color.myBlue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    .confettiCannon(counter: $counter, confettis: [.sfSymbol(symbolName: "dumbbell.fill"), .sfSymbol(symbolName: "trophy.fill")], confettiSize: 20.0, radius: 500.0)
                }
                .onAppear{
                    counter += 1
                }
            }
        }
        .navigationTitle("Time: \(history?.workoutTimeToComplete ?? "0")")
        .onAppear {
            history = workoutController.workoutManager.fetchLatestWorkoutHistory(for: workoutId)
            
            if let totalCardioTimeInSeconds = Int(history?.timeDoingCardio ?? "0") {
                totalCardioTime = formatTimeFromSeconds(totalSeconds: totalCardioTimeInSeconds)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeIn(duration: 1.0)) {
                    showProceedButton = true
                }
            }
        }
    }
}
