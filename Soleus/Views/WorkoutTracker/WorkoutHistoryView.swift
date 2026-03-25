import SwiftUI

struct WorkoutHistoryView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var workoutController: WorkoutTrackerController
    @State private var histories: [WorkoutHistory] = []
    @State private var appearedCards: Set<UUID> = []

    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date()) - 1
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var availableYears: [Int] = [Calendar.current.component(.year, from: Date())]
    @State private var viewMode: ViewMode = .list
    @State private var timePeriod: TimePeriod = .monthly
    @State private var isLoading: Bool = false

    enum ViewMode: String, CaseIterable {
        case list = "List"
        case progress = "Progress"

        var icon: String {
            switch self {
            case .list: return "list.bullet"
            case .progress: return "chart.line.uptrend.xyaxis"
            }
        }
    }

    enum TimePeriod: String, CaseIterable {
        case monthly = "Monthly"
        case allTime = "All Time"

        var icon: String {
            switch self {
            case .monthly: return "calendar"
            case .allTime: return "calendar.badge.clock"
            }
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Time period selector
                HStack(spacing: 8) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                timePeriod = period
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: period.icon)
                                    .font(.system(size: 14))
                                Text(period.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(timePeriod == period ? .semibold : .regular)
                            }
                            .foregroundColor(timePeriod == period ? .white : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(timePeriod == period ? Color.blue : Color.gray.opacity(0.2))
                            )
                        }
                        .accessibilityIdentifier(period == .monthly ? AccessibilityID.historyTimePeriodMonthly : AccessibilityID.historyTimePeriodAllTime)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)

                // Month/Year picker - only show for monthly view
                if timePeriod == .monthly {
                    MonthYearPickerView(selectedMonth: $selectedMonth, selectedYear: $selectedYear, years: availableYears)
                        .onChange(of: selectedMonth) { loadHistories() }
                        .onChange(of: selectedYear) { loadHistories() }
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

            // Header with view mode toggle
            if !histories.isEmpty {
                VStack(spacing: 8) {
                    HStack {
                        Text("\(histories.count) workout\(histories.count == 1 ? "" : "s") completed")
                            .font(.subheadline)
                            .foregroundColor(Color("MyGrey"))
                        Spacer()
                    }

                    // View mode selector
                    HStack(spacing: 8) {
                        ForEach(ViewMode.allCases, id: \.self) { mode in
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) {
                                    viewMode = mode
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: mode.icon)
                                        .font(.system(size: 14))
                                    Text(mode.rawValue)
                                        .font(.subheadline)
                                        .fontWeight(viewMode == mode ? .semibold : .regular)
                                }
                                .foregroundColor(viewMode == mode ? .white : .primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(viewMode == mode ? Color.blue : Color.gray.opacity(0.2))
                                )
                            }
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 12)
            }

            Divider()
            if histories.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.6))
                    Text("No workout history yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .accessibilityIdentifier(AccessibilityID.historyEmptyStateText)
                    Text("Your past workouts will appear here once you complete them.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray.opacity(0.8))
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            else {
                // Switch between list and progress views
                Group {
                    switch viewMode {
                    case .list:
                        listView
                            .transition(.opacity)
                    case .progress:
                        WorkoutProgressView(histories: histories)
                            .transition(.opacity)
                    }
                }
            }
            }
            .background(Color.myWhite)
            .onAppear {
                loadAvailableYears()
                loadHistories()
            }
            .onChange(of: timePeriod) {
                loadHistories()
            }

            // Loading spinner overlay
            if isLoading {
                ZStack {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()

                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(1.5)

                        Text("Loading workout history...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(radius: 10)
                    )
                }
                .transition(.opacity)
            }
        }
    }

    private var listView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(Array(histories.enumerated()), id: \.element) { index, history in
                    if let historyId = history.id {
                        ZStack {
                            // Skeleton loader - shows until card appears
                            if !appearedCards.contains(historyId) {
                                WorkoutHistorySkeletonView()
                                    .transition(.opacity)
                            }

                            // Actual card
                            WorkoutHistoryCardView(history: history, onDelete: {
                                deleteWorkoutHistory(historyId)
                            })
                            .opacity(appearedCards.contains(historyId) ? 1 : 0)
                        }
                        .onAppear {
                            // Remove stagger delay for large datasets
                            let delay = histories.count > 50 ? 0 : Double(index) * 0.05
                            withAnimation(.easeOut(duration: 0.2).delay(delay)) {
                                _ = appearedCards.insert(historyId)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }

    private func loadAvailableYears() {
        let currentYear = Calendar.current.component(.year, from: Date())
        let earliestYear = workoutController.workoutManager.fetchEarliestHistoryYear() ?? currentYear
        availableYears = Array(earliestYear...currentYear)
    }

    private func loadHistories(showSkeletons: Bool = true) {
        if showSkeletons {
            appearedCards.removeAll()
        }

        withAnimation {
            isLoading = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let fetchedHistories: [WorkoutHistory]?

            switch timePeriod {
            case .monthly:
                let calendar = Calendar.current
                var components = DateComponents()
                components.year = selectedYear
                components.month = selectedMonth + 1

                guard let startDate = calendar.date(from: components) else {
                    AppLogger.ui.error("Unable to create date from components - year: \(selectedYear), month: \(selectedMonth + 1)")
                    histories = []
                    withAnimation {
                        isLoading = false
                    }
                    return
                }

                fetchedHistories = workoutController.workoutManager.fetchAllWorkoutHistory(for: startDate)

            case .allTime:
                fetchedHistories = workoutController.workoutManager.fetchAllWorkoutHistoryAllTime()
            }

            let loaded = fetchedHistories ?? []
            withAnimation {
                histories = loaded
                isLoading = false
            }

            // Fallback: LazyVStack won't re-fire .onAppear for items already in the viewport.
            // After a short delay, mark any cards still missing from appearedCards as visible.
            let loadedIds = Set(loaded.compactMap { $0.id })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeOut(duration: 0.2)) {
                    appearedCards.formUnion(loadedIds)
                }
            }
        }
    }

    private func deleteWorkoutHistory(_ historyId: UUID) {
        withAnimation(.easeOut(duration: 0.2)) {
            histories.removeAll { $0.id == historyId }
            appearedCards.remove(historyId)
        }
        workoutController.workoutManager.deleteWorkoutHistory(for: historyId)
    }
}

// MARK: - Skeleton Loader

struct WorkoutHistorySkeletonView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header skeleton
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 150, height: 24)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 100, height: 16)
                }

                Spacer()

                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 30, height: 30)
            }

            // Stats boxes skeleton
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 60)

                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 60)
            }

            // Exercises header skeleton
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 16)

                Spacer()

                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 24)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0),
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: isAnimating ? 400 : -400)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal, 8)
        .onAppear {
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}
