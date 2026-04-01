import SwiftUI


/// This is the view that occurs when you complete a workout
struct WorkoutOverviewView: View {
    var workoutId: UUID
    var elapsedTime: String
    var workoutDetails: [WorkoutDetailInput] = []

    @EnvironmentObject var workoutController: WorkoutTrackerViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var achievementManager: AchievementManager
    @State private var counter = 0
    @State private var history: WorkoutHistory?

    @State private var totalCardioTime = ""
    @State private var showProceedButton = false
    @State private var unlockedAchievements: [Achievement] = []
    @State private var shareItem: ShareableImage? = nil
    @State private var selectedStyleIndex: Int = 0
    private let logoImage: UIImage? = UIImage(named: "Soleus_Launch")
    private let motivationalMessage: String = WorkoutOverviewView.randomMotivationalMessage()
    @Environment(\.displayScale) private var displayScale
    @State private var cardContainerWidth: CGFloat = 390

    private static let motivationalMessages: [String] = [
        "You showed up. That's everything.",
        "Stronger than yesterday.",
        "Workout complete. Discipline wins.",
        "No excuses, just results.",
        "Progress > perfection.",
        "You did what most didn't.",
        "Earned, not given.",
        "That's how it's done.",
        "One more step forward.",
        "You're building something real.",
        "Every rep made you stronger.",
        "Small gains today, big results tomorrow.",
        "You're closer than you think.",
        "This is what progress feels like.",
        "Strength is built, not found.",
        "Consistency is your superpower.",
        "You're leveling up—keep going.",
        "The work is working.",
        "Your future self thanks you.",
        "That effort compounds.",
        "Motivation fades—discipline stays.",
        "You kept the promise you made to yourself.",
        "Hard days build strong minds.",
        "You chose growth today.",
        "This is what commitment looks like.",
        "You don't wait—you act.",
        "One decision at a time.",
        "You proved you can do hard things.",
        "That's mental toughness.",
        "You're in control.",
        "Let's gooo 🔥",
        "You crushed that.",
        "Beast mode: activated.",
        "Unstoppable.",
        "Built different.",
        "That was elite.",
        "You showed no mercy.",
        "DOMINATED.",
        "Keep that energy.",
        "Next level unlocked.",
        "Be proud of yourself.",
        "That time was for you.",
        "You invested in your health today.",
        "Strong body, clear mind.",
        "You earned this feeling.",
        "Take a moment—you did great.",
        "That's self-respect in action.",
        "You chose yourself today.",
        "Feel that momentum.",
        "This is how habits are built.",
        "Sweat = success.",
        "You survived 😅",
        "Gym: 0, You: 1",
        "That burn means it's working.",
        "You didn't quit—and that's huge.",
        "Worth it. Every time.",
        "Same time tomorrow?"
    ]

    private static func randomMotivationalMessage() -> String {
        motivationalMessages.randomElement() ?? "Workout complete."
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Achievements Unlocked Section
                    if showProceedButton && !unlockedAchievements.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Spacer()
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(.myTan)
                                    .font(.title2)
                                Text("Achievements Unlocked!")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
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
                        .transition(.move(edge: .top).combined(with: .opacity))

                        Divider()
                            .padding(.horizontal)
                    }

                    if showProceedButton {
                        Text(motivationalMessage)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                            .padding(.top, 8)
                            .transition(.opacity)
                    }

                    // MARK: Share Card
                    if history != nil {
                        shareCardSection
                    }
                }
                .padding()
                .padding(.bottom, 16)
            }
        }
        .confettiCannon(counter: $counter)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if showProceedButton {
                    Button("Done") {
                        appViewModel.resetToWorkoutMainView()
                    }
                    .fontWeight(.semibold)
                    .onAppear {
                        counter += 1
                    }
                }
            }
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(items: [item.image])
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

            // Animate share card in after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.6)) {
                    history = fetchedHistory
                    totalCardioTime = cardioTime
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeIn(duration: 1.0)) {
                    unlockedAchievements = achievements
                    showProceedButton = true
                }
            }
        }
    }
}

// MARK: - Share Card Section

extension WorkoutOverviewView {
    private var currentStyle: ShareCardStyle {
        ShareCardStyle(rawValue: selectedStyleIndex) ?? .midnight
    }

    private func makeCard(style: ShareCardStyle) -> WorkoutSummaryShareCard {
        WorkoutSummaryShareCard(
            workoutName: workoutController.selectedWorkoutName ?? "Workout",
            duration: elapsedTime,
            date: history?.workoutDate ?? Date(),
            reps: history?.repsCompleted ?? 0,
            weightLifted: history?.totalWeightLifted ?? 0,
            totalDistance: history?.totalDistance ?? 0,
            cardioTime: totalCardioTime,
            style: style,
            logoImage: logoImage
        )
    }

    var shareCardSection: some View {
        let styles = ShareCardStyle.allCases
        let total = styles.count
        let cardW: CGFloat = 360
        let cardH: CGFloat = 480
        let scale: CGFloat = (cardContainerWidth - 16) / cardW

        return VStack(spacing: 16) {

            // Card with arrows overlaid
            ZStack {
                makeCard(style: currentStyle)
                    .frame(width: cardW, height: cardH)
                    .scaleEffect(scale)
                    .frame(width: cardW * scale, height: cardH * scale) // keep layout frame in sync
                    .shadow(color: Color.black.opacity(0.25), radius: 16, x: 0, y: 8)
                    .id(selectedStyleIndex)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .move(edge: .leading).combined(with: .opacity)
                    ))

                // Arrow overlays
                HStack {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selectedStyleIndex = (selectedStyleIndex - 1 + total) % total
                        }
                    } label: {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.white.opacity(0.85), Color.black.opacity(0.25))
                            .shadow(radius: 4)
                    }

                    Spacer()

                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selectedStyleIndex = (selectedStyleIndex + 1) % total
                        }
                    } label: {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.white.opacity(0.85), Color.black.opacity(0.25))
                            .shadow(radius: 4)
                    }
                }
                .padding(.horizontal, 12)
                .frame(width: cardW * scale, height: cardH * scale)
            }

            // Dot indicators + style name
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    ForEach(0..<total, id: \.self) { i in
                        Circle()
                            .fill(i == selectedStyleIndex ? Color.primary : Color.secondary.opacity(0.35))
                            .frame(
                                width:  i == selectedStyleIndex ? 8 : 6,
                                height: i == selectedStyleIndex ? 8 : 6
                            )
                            .animation(.easeInOut(duration: 0.2), value: selectedStyleIndex)
                    }
                }
                Text(currentStyle.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }

            // Share button
            Button {
                let card = makeCard(style: currentStyle)
                let renderer = ImageRenderer(content: card)
                renderer.scale = displayScale
                if let image = renderer.uiImage {
                    shareItem = ShareableImage(image: image)
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Share Workout")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(currentStyle.buttonBackground)
                .cornerRadius(14)
                .animation(.easeInOut(duration: 0.25), value: selectedStyleIndex)
            }
        }
        .background(
            GeometryReader { geo in
                Color.clear.onAppear { cardContainerWidth = geo.size.width }
            }
        )
    }
}

// MARK: - Share Sheet

struct ShareableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}


struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
