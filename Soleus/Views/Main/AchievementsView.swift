import SwiftUI

enum AchievementFilter: String, CaseIterable {
    case all = "Show All"
    case completed = "Completed"
    case incomplete = "Incomplete"
}

struct AchievementsView: View {
    @EnvironmentObject var achievementManager: AchievementManager
    @State private var achievementProgress: [AchievementProgress] = []
    @State private var selectedFilter: AchievementFilter = .all

    var filteredAchievements: [AchievementProgress] {
        switch selectedFilter {
        case .all:
            return achievementProgress
        case .completed:
            return achievementProgress.filter { $0.isUnlocked }
        case .incomplete:
            return achievementProgress.filter { !$0.isUnlocked }
        }
    }

    var completionStats: (completed: Int, total: Int, percentage: Double) {
        let completed = achievementProgress.filter { $0.isUnlocked }.count
        let total = achievementProgress.count
        let percentage = total > 0 ? (Double(completed) / Double(total)) * 100 : 0
        return (completed, total, percentage)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Filter Picker
            Picker("Filter", selection: $selectedFilter) {
                ForEach(AchievementFilter.allCases, id: \.self) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .background(Color(.systemGroupedBackground))

            // Progress Section
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.myBlue)
                        .font(.title2)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Overall Progress")
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text("\(completionStats.completed) / \(completionStats.total) completed (\(String(format: "%.1f", completionStats.percentage))%)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding(.horizontal)

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 12)

                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.myBlue, Color.myLightBlue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(completionStats.percentage / 100), height: 12)
                    }
                }
                .frame(height: 12)
                .padding(.horizontal)
            }
            .padding(.vertical, 16)
            .background(Color(.secondarySystemGroupedBackground))

            // Achievements List
            List {
                ForEach(filteredAchievements, id: \.achievement.id) { progress in
                    AchievementRow(progress: progress)
                }
            }
            .listStyle(.insetGrouped)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            achievementProgress = achievementManager.getAchievementProgress()
        }
    }
}

struct AchievementRow: View {
    let progress: AchievementProgress

    var body: some View {
        HStack(spacing: 12) {
            // Trophy icon
            Image(systemName: progress.achievement.trophy.icon)
                .font(.system(size: 32))
                .foregroundColor(progress.isUnlocked ? Color(progress.achievement.trophy.color) : Color.secondary.opacity(0.3))
                .frame(width: 50)

            VStack(alignment: .leading, spacing: 6) {
                // Achievement name
                Text(progress.achievement.name)
                    .font(.headline)
                    .foregroundColor(progress.isUnlocked ? .primary : .secondary)

                // Achievement description
                Text(progress.achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                // Progress bar
                if !progress.isUnlocked {
                    VStack(alignment: .leading, spacing: 4) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.secondary.opacity(0.2))
                                    .frame(height: 6)

                                // Progress fill
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(progress.achievement.trophy.color))
                                    .frame(width: geometry.size.width * CGFloat(progress.progressPercentage / 100), height: 6)
                            }
                        }
                        .frame(height: 6)

                        // Progress text
                        Text(formatProgress(progress))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("Unlocked!")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(progress.achievement.trophy.color))
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .opacity(progress.isUnlocked ? 1.0 : 0.7)
    }

    private func formatProgress(_ progress: AchievementProgress) -> String {
        let current = progress.currentProgress
        let target = progress.targetValue

        // Format numbers nicely
        if target >= 1000 {
            return String(format: "%.0f / %.0f", current, target)
        } else if target >= 1 {
            return String(format: "%.1f / %.1f", current, target)
        } else {
            return String(format: "%.2f%%", progress.progressPercentage)
        }
    }
}
