import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var persistenceController: PersistenceController
    @EnvironmentObject var workoutController: WorkoutTrackerController
    @AppStorage("appearancePreference") private var appearancePreference: String = "dark"

    private var preferredColorScheme: ColorScheme? {
        switch appearancePreference {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil
        }
    }

    var body: some View {
        Group {
            if persistenceController.isLoaded {
                if let error = persistenceController.loadError {
                    // Show error if CoreData failed to load
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                        Text("Failed to Load Data")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("There was a problem loading your workout data. Try restarting the app.")
                            .multilineTextAlignment(.center)
                            .padding()
                        Text("Error: \(error.localizedDescription)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding()
                    }
                    .padding()
                } else {
                    VStack {
                        HStack {
                            CustomTabView()
                                .environmentObject(appViewModel)
                                .environmentObject(workoutController)
                        }
                    }
                }
            } else {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading...")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
        }
        .preferredColorScheme(preferredColorScheme)
    }
}
