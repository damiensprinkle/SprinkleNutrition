import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var workoutController: WorkoutTrackerViewModel
    @EnvironmentObject var achievementManager: AchievementManager

    @State private var lifeStats: WorkoutStats?
    @State private var personalRecords: PersonalRecords?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Divider()
                // View Achievements Card
                Button(action: {
                    appViewModel.navigateTo(.achievementsView)
                }) {
                    HStack(spacing: 16) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.staticWhite)
                            .padding(.leading, 8)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Achievements")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.staticWhite)

                            Text("View your progress")
                                .font(.subheadline)
                                .foregroundColor(.staticWhite.opacity(0.9))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.body)
                            .foregroundColor(.staticWhite.opacity(0.7))
                            .padding(.trailing, 8)
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.myTan, Color.myLightBrown]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(15)
                    .shadow(color: Color.myTan.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Streaks Card
                if let stats = lifeStats {
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.orange)

                            Text("Workout Streaks")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)

                            Spacer()
                        }

                        HStack(spacing: 16) {
                            // Current Streak
                            VStack(spacing: 8) {
                                Text("\(stats.currentStreak)")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(stats.currentStreak > 0 ? .orange : .secondary)

                                HStack(spacing: 4) {
                                    Image(systemName: "flame.fill")
                                        .font(.caption)
                                        .foregroundColor(stats.currentStreak > 0 ? .orange : .secondary)
                                    Text("Current Streak")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.tertiarySystemGroupedBackground))
                            .cornerRadius(12)

                            // Longest Streak
                            VStack(spacing: 8) {
                                Text("\(stats.longestStreak)")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(.myBlue)

                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .font(.caption)
                                        .foregroundColor(.myBlue)
                                    Text("Longest Streak")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.tertiarySystemGroupedBackground))
                            .cornerRadius(12)
                        }

                        if stats.currentStreak > 0 {
                            Text("Keep it up! You're on fire! 🔥")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                                .fontWeight(.medium)
                        } else if stats.longestStreak > 0 {
                            Text("Start a new streak today!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Work out 2 days in a row to start your first streak!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(20)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                }

                // LifeStats Card
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 32))
                            .foregroundColor(.myBlue)

                        Text("Lifetime Stats")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        Spacer()
                    }

                    if let stats = lifeStats {
                        VStack(spacing: 12) {
                            StatRow(
                                icon: "figure.walk",
                                label: "Total Reps",
                                value: "\(stats.totalReps)",
                                color: .myBlue
                            )

                            Divider()

                            StatRow(
                                icon: "scalemass",
                                label: "Total Weight Lifted",
                                value: formatWeight(stats.totalWeightLifted),
                                color: .myBlue
                            )

                            Divider()

                            StatRow(
                                icon: "timer",
                                label: "Total Workout Time",
                                value: String(format: "%.1f hrs", stats.totalTimeInHours),
                                color: .myBlue
                            )

                            Divider()

                            StatRow(
                                icon: "figure.run",
                                label: "Total Distance",
                                value: String(format: "%.1f mi", stats.totalDistance),
                                color: .myBlue
                            )
                        }
                    } else {
                        ProgressView()
                            .padding()
                    }
                }
                .padding(20)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                .padding(.horizontal)

                // Personal Records Card
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.myTan)

                        Text("Personal Records")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        Spacer()
                    }

                    if let records = personalRecords {
                        VStack(spacing: 12) {
                            if records.heaviestWeight > 0 {
                                StatRow(
                                    icon: "scalemass.fill",
                                    label: "Heaviest Workout",
                                    value: formatWeight(records.heaviestWeight),
                                    color: .myTan
                                )

                                Divider()
                            }

                            if records.mostReps > 0 {
                                StatRow(
                                    icon: "figure.walk",
                                    label: "Most Reps",
                                    value: "\(records.mostReps) reps",
                                    color: .myTan
                                )

                                Divider()
                            }

                            if records.longestWorkoutMinutes > 0 {
                                StatRow(
                                    icon: "timer",
                                    label: "Longest Workout",
                                    value: String(format: "%.0f min", records.longestWorkoutMinutes),
                                    color: .myTan
                                )

                                if records.furthestDistance > 0 {
                                    Divider()
                                }
                            }

                            if records.furthestDistance > 0 {
                                StatRow(
                                    icon: "figure.run",
                                    label: "Furthest Distance",
                                    value: String(format: "%.1f mi", records.furthestDistance),
                                    color: .myTan
                                )
                            }

                            // Show message if no records yet
                            if records.heaviestWeight == 0 && records.mostReps == 0 && records.longestWorkoutMinutes == 0 && records.furthestDistance == 0 {
                                VStack(spacing: 8) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.myTan.opacity(0.5))

                                    Text("Complete workouts to set your first records!")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.vertical, 20)
                            }
                        }
                    } else {
                        ProgressView()
                            .padding()
                    }
                }
                .padding(20)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                .padding(.horizontal)

                Spacer()
            }
        }
        .background(Color.myWhite.ignoresSafeArea())
        .onAppear {
            lifeStats = achievementManager.getWorkoutStats()
            personalRecords = achievementManager.getPersonalRecords()
        }
    }

    private func formatWeight(_ weight: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","
        formatter.usesGroupingSeparator = true

        if let formattedNumber = formatter.string(from: NSNumber(value: weight)) {
            return "\(formattedNumber) lbs"
        }
        return "\(Int(weight)) lbs"
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)

            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
}
