import SwiftUI


/// This is the view that occurs when you complete a workout
struct WorkoutOverviewView: View {
    var workoutId: UUID
    var elapsedTime: String
    var workoutDetails: [WorkoutDetailInput] = []

    @EnvironmentObject var workoutController: WorkoutTrackerController
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var achievementManager: AchievementManager
    @State private var counter = 0
    @State private var history: WorkoutHistory?

    @State private var totalCardioTime = ""
    @State private var showProceedButton = false
    @State private var unlockedAchievements: [Achievement] = []
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Achievements Unlocked Section
                    if !unlockedAchievements.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(.myTan)
                                    .font(.title2)
                                Text("Achievements Unlocked!")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(unlockedAchievements) { achievement in
                                        AchievementUnlockedCard(achievement: achievement)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                    }

                    LazyVGrid(columns: columns, spacing: 16) {
                        if let repsCompleted = history?.repsCompleted, repsCompleted > 0 {
                            DataCardView(
                                icon: Image(systemName: "figure.walk"),
                                number: "\(repsCompleted)",
                                description: "Reps Completed"
                            )
                            .transition(.scale.combined(with: .opacity))
                        }
                        if let totalWeightLifted = history?.totalWeightLifted, totalWeightLifted > 0 {
                            DataCardView(
                                icon: Image(systemName: "scalemass"),
                                number: String(format: "%.0f lbs", totalWeightLifted),
                                description: "Total Weight Lifted"
                            )
                            .transition(.scale.combined(with: .opacity))
                        }
                        if !totalCardioTime.isEmpty && totalCardioTime != "00:00:00" {
                            DataCardView(
                                icon: Image(systemName: "timer"),
                                number: totalCardioTime,
                                description: "Time Doing Cardio"
                            )
                            .transition(.scale.combined(with: .opacity))
                        }
                        if let totalDistance = history?.totalDistance, totalDistance > 0.0 {
                            DataCardView(
                                icon: Image(systemName: "figure.run"),
                                number: String(format: "%.1f mi", totalDistance),
                                description: "Total Distance"
                            )
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                .padding()
                .padding(.bottom, 80)
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
                    .confettiCannon(counter: $counter)
                }
                .onAppear{
                    counter += 1
                }
            }
        }
        .onAppear {
            let manager = workoutController.workoutManager
            let fetchedHistory = manager.fetchLatestWorkoutHistory(for: workoutId)

            var cardioTime = ""
            if let totalCardioTimeInSeconds = Int(fetchedHistory?.timeDoingCardio ?? "0") {
                cardioTime = formatTimeFromSeconds(totalSeconds: totalCardioTimeInSeconds)
            }

            // Check for newly unlocked achievements (only those unlocked during this workout)
            let newlyUnlocked = achievementManager.getNewlyUnlockedAchievements()

            // Show only Gold and Platinum tier achievements, or first 3 achievements
            var achievements = newlyUnlocked
                .filter { $0.trophy == .gold || $0.trophy == .platinum }
                .prefix(3)
                .map { $0 }

            // If no Gold/Platinum, show any unlocked (limit to 3)
            if achievements.isEmpty {
                achievements = Array(newlyUnlocked.prefix(3))
            }

            // Animate cards in after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.6)) {
                    history = fetchedHistory
                    totalCardioTime = cardioTime
                    unlockedAchievements = achievements
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeIn(duration: 1.0)) {
                    showProceedButton = true
                }
            }
        }
    }
}

struct AchievementUnlockedCard: View {
    let achievement: Achievement

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: achievement.trophy.icon)
                .font(.system(size: 40))
                .foregroundColor(Color(achievement.trophy.color))

            Text(achievement.name)
                .font(.headline)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(achievement.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            Text(achievement.trophy.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color(achievement.trophy.color).opacity(0.2))
                .cornerRadius(8)
        }
        .padding(16)
        .frame(width: 220)
        .fixedSize(horizontal: true, vertical: false)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(achievement.trophy.color), lineWidth: 2)
        )
        .shadow(color: Color(achievement.trophy.color).opacity(0.3), radius: 8, x: 0, y: 4)
    }
}
