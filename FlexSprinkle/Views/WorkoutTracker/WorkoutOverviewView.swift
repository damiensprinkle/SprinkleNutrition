import SwiftUI
import ConfettiSwiftUI

struct WorkoutOverviewView: View {
    var workoutId: UUID
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var counter = 0

    var body: some View {
        VStack {
            Text("Workout Overview for \(workoutId)")
                .padding()
            
        }
        .navigationBarTitle("Workout Overview")
        .confettiCannon(counter: $counter, confettis: [.sfSymbol(symbolName: "dumbbell"), .sfSymbol(symbolName: "trophy")], colors: [.purple, Color("MyBlue")], confettiSize: 20.0, radius: 400.0)
        .onAppear {
            // Optionally delay the confetti trigger
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.counter += 1  // This triggers the confetti
            }
        }
    }
}
