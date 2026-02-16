import SwiftUI

struct WorkoutProgressView: View {
    let histories: [WorkoutHistory]
    @AppStorage("weightPreference") private var weightPreference: String = "Lbs"
    @AppStorage("distancePreference") private var distancePreference: String = "mile"

    // Group histories by workout name
    private var groupedHistories: [String: [WorkoutHistory]] {
        Dictionary(grouping: histories) { history in
            history.workoutR?.name ?? "Unknown Workout"
        }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if groupedHistories.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(Array(groupedHistories.keys.sorted()), id: \.self) { workoutName in
                        if let workoutHistories = groupedHistories[workoutName] {
                            WorkoutProgressCard(
                                workoutName: workoutName,
                                histories: workoutHistories.sorted { ($0.workoutDate ?? Date.distantPast) > ($1.workoutDate ?? Date.distantPast) }
                            )
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color.myWhite)
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.6))
            Text("No progress data yet")
                .font(.headline)
                .foregroundColor(.gray)
            Text("Complete multiple workouts to see your progress over time.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray.opacity(0.8))
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Workout Progress Card

struct WorkoutProgressCard: View {
    let workoutName: String
    let histories: [WorkoutHistory]
    @State private var isExpanded: Bool = true
    @State private var selectedExercise: String?
    @AppStorage("weightPreference") private var weightPreference: String = "Lbs"

    // Get unique exercises across all histories
    private var uniqueExercises: [String] {
        var exercises = Set<String>()
        for history in histories {
            if let details = history.details?.allObjects as? [WorkoutDetail] {
                for detail in details {
                    if let name = detail.exerciseName {
                        exercises.insert(name)
                    }
                }
            }
        }
        return Array(exercises).sorted()
    }

    // Overall workout stats
    private var overallStats: (totalWorkouts: Int, avgWeight: Float, avgTime: String, trend: String) {
        let count = histories.count
        let avgWeight = histories.reduce(0.0) { $0 + $1.totalWeightLifted } / Float(count)

        // Calculate trend (comparing first half vs second half)
        let midpoint = count / 2
        let recentAvg = histories.prefix(midpoint).reduce(0.0) { $0 + $1.totalWeightLifted } / Float(max(midpoint, 1))
        let olderAvg = histories.suffix(count - midpoint).reduce(0.0) { $0 + $1.totalWeightLifted } / Float(max(count - midpoint, 1))

        let trend: String
        if recentAvg > olderAvg * 1.05 {
            trend = "↑"
        } else if recentAvg < olderAvg * 0.95 {
            trend = "↓"
        } else {
            trend = "→"
        }

        let avgTimeStr = histories.first?.workoutTimeToComplete ?? "0"

        return (count, avgWeight, avgTimeStr, trend)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workoutName)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("\(overallStats.totalWorkouts) session\(overallStats.totalWorkouts == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isExpanded.toggle()
                        }
                    }
            }

            // Overall stats
            HStack(spacing: 20) {
                StatBox(
                    icon: "dumbbell.fill",
                    label: "Avg Weight",
                    value: "\(overallStats.avgWeight, default: "%.0f") \(weightPreference)",
                    trend: overallStats.trend,
                    color: .blue
                )

                StatBox(
                    icon: "clock.fill",
                    label: "Avg Duration",
                    value: overallStats.avgTime,
                    trend: nil,
                    color: .green
                )
            }

            if isExpanded {
                Divider()

                // Exercise selection
                if !uniqueExercises.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Exercise Progress")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(uniqueExercises, id: \.self) { exercise in
                                    ExerciseChip(
                                        name: exercise,
                                        isSelected: selectedExercise == exercise,
                                        onTap: {
                                            withAnimation {
                                                selectedExercise = selectedExercise == exercise ? nil : exercise
                                            }
                                        }
                                    )
                                }
                            }
                        }

                        if let exercise = selectedExercise {
                            ExerciseProgressDetail(
                                exerciseName: exercise,
                                histories: histories
                            )
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Stat Box

struct StatBox: View {
    let icon: String
    let label: String
    let value: String
    let trend: String?
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)

                HStack(spacing: 4) {
                    Text(value)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    if let trend = trend {
                        Text(trend)
                            .font(.title3)
                            .foregroundColor(trendColor(trend))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(10)
    }

    private func trendColor(_ trend: String) -> Color {
        switch trend {
        case "↑": return .green
        case "↓": return .red
        default: return .orange
        }
    }
}

// MARK: - Exercise Chip

struct ExerciseChip: View {
    let name: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(name)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.blue : Color(.tertiarySystemGroupedBackground))
                )
        }
    }
}

// MARK: - Exercise Progress Detail

struct ExerciseProgressDetail: View {
    let exerciseName: String
    let histories: [WorkoutHistory]
    @AppStorage("weightPreference") private var weightPreference: String = "Lbs"
    @AppStorage("distancePreference") private var distancePreference: String = "mile"

    // Extract exercise data from histories
    private var exerciseData: [(date: Date, maxWeight: Float, totalReps: Int, totalVolume: Float)] {
        var data: [(Date, Float, Int, Float)] = []

        for history in histories {
            guard let date = history.workoutDate,
                  let details = history.details?.allObjects as? [WorkoutDetail] else { continue }

            if let detail = details.first(where: { $0.exerciseName == exerciseName }),
               let sets = detail.sets?.allObjects as? [WorkoutSet] {

                let maxWeight = sets.map { $0.weight }.max() ?? 0
                let totalReps = sets.reduce(0) { $0 + Int($1.reps) }
                let totalVolume = sets.reduce(0.0) { result, set in
                    result + (Float(set.reps) * set.weight)
                }

                data.append((date, maxWeight, totalReps, totalVolume))
            }
        }

        return data.sorted { (first: (date: Date, maxWeight: Float, totalReps: Int, totalVolume: Float), second: (date: Date, maxWeight: Float, totalReps: Int, totalVolume: Float)) -> Bool in
            first.date > second.date
        }
    }

    // Calculate trends
    private var trends: (weight: String, reps: String, volume: String) {
        guard exerciseData.count >= 2 else { return ("→", "→", "→") }

        let recent = exerciseData.prefix(exerciseData.count / 2)
        let older = exerciseData.suffix(exerciseData.count - exerciseData.count / 2)

        let recentAvgWeight = recent.reduce(0.0) { $0 + $1.maxWeight } / Float(recent.count)
        let olderAvgWeight = older.reduce(0.0) { $0 + $1.maxWeight } / Float(older.count)

        let recentAvgReps = recent.reduce(0) { $0 + $1.totalReps } / recent.count
        let olderAvgReps = older.reduce(0) { $0 + $1.totalReps } / older.count

        let recentAvgVolume = recent.reduce(0.0) { $0 + $1.totalVolume } / Float(recent.count)
        let olderAvgVolume = older.reduce(0.0) { $0 + $1.totalVolume } / Float(older.count)

        let weightTrend = recentAvgWeight > olderAvgWeight * 1.02 ? "↑" : (recentAvgWeight < olderAvgWeight * 0.98 ? "↓" : "→")
        let repsTrend = recentAvgReps > olderAvgReps ? "↑" : (recentAvgReps < olderAvgReps ? "↓" : "→")
        let volumeTrend = recentAvgVolume > olderAvgVolume * 1.05 ? "↑" : (recentAvgVolume < olderAvgVolume * 0.95 ? "↓" : "→")

        return (weightTrend, repsTrend, volumeTrend)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(exerciseName)
                .font(.headline)

            // Trend summary
            HStack(spacing: 12) {
                TrendIndicator(label: "Max Weight", trend: trends.weight)
                TrendIndicator(label: "Total Reps", trend: trends.reps)
                TrendIndicator(label: "Volume", trend: trends.volume)
            }

            Divider()

            // Session history
            VStack(alignment: .leading, spacing: 8) {
                Text("Recent Sessions")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                ForEach(Array(exerciseData.prefix(5).enumerated()), id: \.offset) { index, data in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(formatDate(data.date))
                                .font(.caption)
                                .foregroundColor(.secondary)

                            HStack(spacing: 12) {
                                Label("\(data.maxWeight, specifier: "%.1f") \(weightPreference)", systemImage: "scalemass")
                                    .font(.caption)
                                Label("\(data.totalReps) reps", systemImage: "repeat")
                                    .font(.caption)
                            }
                        }

                        Spacer()

                        Text("\(data.totalVolume, specifier: "%.0f")")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                    }
                    .padding(.vertical, 4)

                    if index < min(4, exerciseData.count - 1) {
                        Divider()
                    }
                }
            }
            .padding(12)
            .background(Color(.tertiarySystemGroupedBackground))
            .cornerRadius(10)
        }
        .padding(.top, 8)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Trend Indicator

struct TrendIndicator: View {
    let label: String
    let trend: String

    var body: some View {
        VStack(spacing: 4) {
            Text(trend)
                .font(.title)
                .foregroundColor(trendColor)

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(8)
    }

    private var trendColor: Color {
        switch trend {
        case "↑": return .green
        case "↓": return .red
        default: return .orange
        }
    }
}

#Preview {
    WorkoutProgressView(histories: [])
}
