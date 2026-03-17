import SwiftUI

struct TemplatePickerView: View {
    @Binding var isPresented: Bool
    let onSelect: (WorkoutTemplate) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Start from Template")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("Choose a template to pre-fill your workout")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 24)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

            Divider()

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(WorkoutTemplate.allTemplates, id: \.name) { template in
                        Button(action: { onSelect(template) }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(template.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("\(template.exercises.count) exercises")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(16)
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityIdentifier("\(AccessibilityID.templatePickerRow)_\(template.name)")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }

            Divider()

            Button(action: { isPresented = false }) {
                Text("Cancel")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .accessibilityIdentifier(AccessibilityID.templatePickerCancelButton)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .background(Color(.systemGroupedBackground))
    }
}
