import SwiftUI
import ConfettiSwiftUI

import SwiftUI
import ConfettiSwiftUI

struct WorkoutOverviewView: View {
    var workoutId: UUID
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var counter = 0
    @State private var history: WorkoutHistory?
    
    // State variables to control the visibility of each card
    @State private var showFirstCard = false
    @State private var showSecondCard = false
    @State private var showThirdCard = false
    @State private var showFourthCard = false
    
    var body: some View {
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
                    DataCardView(icon: Image(systemName: "timer"), number: "\(history?.timeDoingCardio ?? "0")", description: "Time Doing Cardio")
                        .transition(.scale.combined(with: .opacity))
                }
                if showFourthCard {
                    DataCardView(icon: Image(systemName: "clock"), number: "\(history?.workoutTimeToComplete ?? "0")", description: "Total Workout Time")
                        .transition(.scale.combined(with: .opacity))
                }
            }

            .onAppear {
                counter += 1
                history = workoutManager.fetchLatestWorkoutHistory(for: workoutId)
                
                // Sequence to display cards one after another
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
                }
            }
            .confettiCannon(counter: $counter, confettis: [.sfSymbol(symbolName: "dumbbell.fill"), .sfSymbol(symbolName: "trophy.fill")], confettiSize: 20.0, radius: 400.0)
        }
        
    }
}
