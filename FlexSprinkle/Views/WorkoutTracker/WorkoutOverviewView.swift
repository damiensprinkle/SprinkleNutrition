import SwiftUI

struct WorkoutOverviewView: View {
    var workoutId: UUID
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack {
            // Your content here
            Text("Workout Overview for \(workoutId)")
                .padding()
            
            Button("Go to Home") {
                // This assumes you have a way to programmatically navigate to the home view
                // For example, by resetting the navigation stack or using a published variable observed by your parent view to change the displayed view.
                // This example simply dismisses the current view, which may not return to the home depending on your navigation setup.
                self.presentationMode.wrappedValue.dismiss()
                
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(Color.white)
            .cornerRadius(10)
        }
        .navigationBarBackButtonHidden(true) // This hides the back button
        .navigationBarTitle(Text("Workout Overview"), displayMode: .inline)
        // Optionally hide the whole navigation bar if you want
        // .navigationBarHidden(true)
    }
}
