import SwiftUI
import ConfettiSwiftUI

struct WorkoutOverviewView: View {
    var workoutId: UUID
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var counter = 0
    @State private var history: WorkoutHistory?
    
    @State private var totalCardioTime = ""
    
    @State private var showFirstCard = false
    
    @State private var showSecondCard = false
    @State private var showThirdCard = false
    @State private var showFourthCard = false
    @State private var showProceedButton = false // State to control the visibility of the Proceed button
    
    var body: some View {
        ZStack {
            VStack {
                Divider()
                
                VStack {
                    HStack {
                        if showFirstCard {
                            DataCardView(icon: Image(systemName: "figure.walk"), number: "\(history?.repsCompleted ?? 0)", description: "Reps Completed")
                                .transition(.scale.combined(with: .opacity))
                        }
                        if showSecondCard {
                            DataCardView(icon: Image(systemName: "scalemass"), number: "\(history?.totalWeightLifted ?? 0)", description: "Total Weight Lifted")
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    HStack {
                        if showThirdCard {
                            DataCardView(icon: Image(systemName: "timer"), number: "\(totalCardioTime)", description: "Time Doing Cardio")
                                .transition(.scale.combined(with: .opacity))
                        }
                        if showFourthCard {
                            DataCardView(icon: Image(systemName: "clock"), number: "\(history?.workoutTimeToComplete ?? "0")", description: " Total Workout Time")
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                
                .onAppear {
                    history = workoutManager.fetchLatestWorkoutHistory(for: workoutId)
                    let totalCardioTimeInSeconds = Int((history?.timeDoingCardio!)!)
                    
                    let hours = totalCardioTimeInSeconds! / 3600
                    let minutes = (totalCardioTimeInSeconds! % 3600) / 60
                    let seconds = totalCardioTimeInSeconds! % 60
                    
                    totalCardioTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
                    
                    
                    withAnimation(.easeOut(duration: 0.5)) {
                        showFirstCard = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            showSecondCard = true
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            showThirdCard = true
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            showFourthCard = true
                        }
                        withAnimation(.easeIn(duration: 1.0)) {
                            showProceedButton = true // Show the Proceed button after all cards are shown
                        }
                    }
                }
                
                Spacer()
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
                            .foregroundColor(.white)
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
    }
}
