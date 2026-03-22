import SwiftUI

struct ReleaseNotesView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    releaseSection(
                        version: "v1.0.2",
                        items: [
                            ("bell.fill", "Push Notifications", "Stay on top of your fitness with customizable reminders — active workout alerts, inactivity nudges, and streak-at-risk warnings."),
                            ("square.and.arrow.down", "Import Workout", "Import .soleus workout files directly from Settings for a cleaner main view."),
                        ]
                    )

                    releaseSection(
                        version: "v1.0.1",
                        items: [
                            ("hand.point.up.left.fill", "Drag to Reorder", "Long-press any workout card and drag to reorder — just like your iPhone home screen."),
                            ("rectangle.and.pencil.and.ellipsis", "Swipe-Down Warning", "Adding or editing a workout now warns you before discarding unsaved changes."),
                            ("textformat.123", "Character Limits", "Workout and exercise name fields now show a live character counter with a 30-character cap."),
                        ]
                    )
                }
                .padding()
            }
            .navigationTitle("What's New")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func releaseSection(version: String, items: [(String, String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(version)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.myBlue)

            VStack(alignment: .leading, spacing: 14) {
                ForEach(items, id: \.1) { icon, title, description in
                    HStack(alignment: .top, spacing: 14) {
                        Image(systemName: icon)
                            .font(.title3)
                            .foregroundColor(.myBlue)
                            .frame(width: 28)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
