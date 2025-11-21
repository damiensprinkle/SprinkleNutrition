//
//  FAQView.swift
//  FlexSprinkle
//
//  Created by Claude Code
//

import SwiftUI

struct FAQView: View {
    @Environment(\.dismiss) var dismiss
    @State private var expandedQuestion: String?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Frequently Asked Questions")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Learn how to use Soleus")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 8)

                    // Getting Started
                    SectionHeader(title: "Getting Started")

                    FAQItem(
                        question: "How do I create my first workout?",
                        answer: "Tap the '+' icon in the top right of the Workouts tab. Give your workout a name and color, then add exercises by tapping 'Add Exercise'. For each exercise, you can configure sets, reps, weight, time, or distance.",
                        expandedQuestion: $expandedQuestion
                    )

                    FAQItem(
                        question: "What's the difference between a workout and workout history?",
                        answer: "A workout is a template or plan that you create. When you start and complete a workout, it creates a workout history entry that tracks what you actually did. This way you can reuse the same workout template multiple times while keeping a record of each session.",
                        expandedQuestion: $expandedQuestion
                    )

                    // Using Workouts
                    SectionHeader(title: "Using Workouts")

                    FAQItem(
                        question: "How do I start a workout?",
                        answer: "Tap the play button on any workout card. Review the exercises and sets, then tap 'Start Workout'. You can then track your progress by checking off completed sets.",
                        expandedQuestion: $expandedQuestion
                    )

                    FAQItem(
                        question: "Can I modify a workout while it's in progress?",
                        answer: "Yes! During an active workout, tap the pencil icon to enter edit mode. You can then:\n\n• Add new exercises\n• Add or remove sets\n• Rearrange exercises with up/down arrows\n• Adjust weights, reps, or times\n\nAfter completing the workout, you can preview your changes before deciding whether to update the original workout template.",
                        expandedQuestion: $expandedQuestion
                    )

                    FAQItem(
                        question: "What happens when I finish a workout with changes?",
                        answer: "If you made changes during your workout, you'll see a preview showing exactly what changed (exercises added/removed, sets modified, etc.). You can then choose to:\n\n• Update Workout - Save changes to your template\n• Keep Original - Save the workout history but don't update the template\n\nThis lets you adapt workouts on the fly without permanently changing your template if you don't want to.",
                        expandedQuestion: $expandedQuestion
                    )

                    FAQItem(
                        question: "How do I rearrange my workouts?",
                        answer: "Tap the rearrange icon (arrows) in the top right. Then swipe workout cards left or right to reorder them. Tap the checkmark when done.",
                        expandedQuestion: $expandedQuestion
                    )

                    FAQItem(
                        question: "How do I duplicate or delete a workout?",
                        answer: "Long press on any workout card to open the context menu. From there you can edit, duplicate, share, or delete the workout.",
                        expandedQuestion: $expandedQuestion
                    )

                    // Exercises & Sets
                    SectionHeader(title: "Exercises & Sets")

                    FAQItem(
                        question: "What types of exercises can I track?",
                        answer: "FlexSprinkle supports four types of exercises:\n\n• Reps (like push-ups, pull-ups)\n• Weight & Reps (like bench press, squats)\n• Time (like planks, wall sits)\n• Distance (like running, cycling)\n\nEach exercise type has appropriate fields for tracking your performance.",
                        expandedQuestion: $expandedQuestion
                    )

                    FAQItem(
                        question: "How do I add or remove sets?",
                        answer: "When creating or editing a workout, tap 'Add Set' to add more sets to an exercise. During an active workout, you need to enter edit mode first (tap the pencil icon). New sets automatically copy the values from your previous set for convenience.\n\nTo remove a set, swipe left on it and tap delete. In active workouts, sets can only be deleted when in edit mode.",
                        expandedQuestion: $expandedQuestion
                    )

                    FAQItem(
                        question: "Can I add notes to exercises?",
                        answer: "Yes! Tap the notebook icon next to any exercise name to add notes. You can use notes to record form cues, personal records, or any reminders. Notes appear below the exercise title and are saved with your workout template.",
                        expandedQuestion: $expandedQuestion
                    )

                    FAQItem(
                        question: "Do sets auto-complete?",
                        answer: "Yes! When you're tracking an active workout, sets will automatically mark as complete when you enter values in both required fields (e.g., reps AND weight). You can also manually check off sets using the slider.",
                        expandedQuestion: $expandedQuestion
                    )

                    // Achievements & Stats
                    SectionHeader(title: "Achievements & Stats")

                    FAQItem(
                        question: "How do achievements work?",
                        answer: "Achievements unlock automatically based on your workout activity. Track total weight lifted, reps completed, workout streaks, and more. View all achievements and your progress in the Dashboard tab.",
                        expandedQuestion: $expandedQuestion
                    )

                    FAQItem(
                        question: "What is a workout streak?",
                        answer: "A workout streak counts consecutive days you've completed workouts. Work out every day to build your streak! Your current and longest streaks are shown in the Dashboard.",
                        expandedQuestion: $expandedQuestion
                    )

                    FAQItem(
                        question: "Where can I see my personal records?",
                        answer: "The Dashboard shows your personal records including:\n\n• Heaviest single workout (total weight)\n• Most reps in one workout\n• Longest workout duration\n• Furthest distance in one session",
                        expandedQuestion: $expandedQuestion
                    )

                    // Data & Privacy
                    SectionHeader(title: "Data & Privacy")

                    FAQItem(
                        question: "Is my data synced to the cloud?",
                        answer: "No. All your data stays on your device. Soleus doesn't use any cloud services, which means your workout data is completely private and under your control.",
                        expandedQuestion: $expandedQuestion
                    )

                    FAQItem(
                        question: "Can I export my workouts?",
                        answer: "Yes! Long press on any workout card and select 'Share'. You can share the workout file with others or save it as a backup. Recipients can import the workout into their Soleus app.",
                        expandedQuestion: $expandedQuestion
                    )

                    FAQItem(
                        question: "What happens if I delete a workout?",
                        answer: "Deleting a workout removes the template, but your workout history is preserved. This means your achievements, stats, and personal records remain intact even if you delete the original workout.",
                        expandedQuestion: $expandedQuestion
                    )

                    // Customization
                    SectionHeader(title: "Customization")

                    FAQItem(
                        question: "Can I change my weight and distance units?",
                        answer: "Yes! Go to Settings and choose between lbs/kg for weight and miles/km for distance. Your preference will be used throughout the app.",
                        expandedQuestion: $expandedQuestion
                    )

                    FAQItem(
                        question: "Can I change workout card colors?",
                        answer: "Absolutely! Long Press on the workout card and select 'Customize Card' ",
                        expandedQuestion: $expandedQuestion
                    )

                    // Video Tutorials Section
                    SectionHeader(title: "Video Tutorials")

                    Text("Coming soon! Video tutorials will be added here to help you get the most out of Soleus.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(8)

                    Spacer()
                        .frame(height: 20)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Help & FAQ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.myBlue)
            .padding(.top, 8)
    }
}

struct FAQItem: View {
    let question: String
    let answer: String
    @Binding var expandedQuestion: String?

    private var isExpanded: Bool {
        expandedQuestion == question
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedQuestion = isExpanded ? nil : question
                }
            }) {
                HStack {
                    Text(question)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
            }

            if isExpanded {
                Text(answer)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color(.tertiarySystemGroupedBackground))
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }
}
