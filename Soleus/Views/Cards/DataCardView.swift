import SwiftUI

struct DataCardView: View {
    let icon: Image
    let number: String
    let description: String

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            // Icon at top, centered
            icon
                .font(.system(size: 32))
                .foregroundColor(.myBlue)
                .frame(height: 40)

            // Number
            Text(number)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            // Description
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
