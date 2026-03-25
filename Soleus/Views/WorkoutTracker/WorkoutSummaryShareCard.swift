import SwiftUI

// MARK: - Card Style

enum ShareCardStyle: Int, CaseIterable {
    case midnight, ember, frost, forest

    var name: String {
        switch self {
        case .midnight: return "Midnight"
        case .ember:    return "Ember"
        case .frost:    return "Frost"
        case .forest:   return "Dune"
        }
    }

    // Background gradient colors
    var backgroundColors: [Color] {
        switch self {
        case .midnight:
            return [
                Color(red: 0.05, green: 0.07, blue: 0.18),
                Color(red: 0.08, green: 0.12, blue: 0.35),
                Color(red: 0.14, green: 0.08, blue: 0.30)
            ]
        case .ember:
            return [
                Color(red: 0.12, green: 0.04, blue: 0.02),
                Color(red: 0.30, green: 0.10, blue: 0.03),
                Color(red: 0.22, green: 0.06, blue: 0.06)
            ]
        case .frost:
            return [
                Color(red: 0.96, green: 0.97, blue: 1.00),
                Color(red: 0.88, green: 0.93, blue: 0.99),
                Color(red: 0.92, green: 0.95, blue: 1.00)
            ]
        case .forest:
            return [
                Color(red: 0.14, green: 0.09, blue: 0.04),
                Color(red: 0.25, green: 0.17, blue: 0.07),
                Color(red: 0.19, green: 0.12, blue: 0.05)
            ]
        }
    }

    // Radial glow color
    var glowColor: Color {
        switch self {
        case .midnight: return Color.blue.opacity(0.25)
        case .ember:    return Color.orange.opacity(0.30)
        case .frost:    return Color.blue.opacity(0.08)
        case .forest:   return Color(red: 0.902, green: 0.690, blue: 0.431).opacity(0.25)
        }
    }

    // Accent color for icons and divider
    var accentColor: Color {
        switch self {
        case .midnight: return Color(red: 0.45, green: 0.65, blue: 1.00)
        case .ember:    return Color(red: 1.00, green: 0.55, blue: 0.20)
        case .frost:    return Color(red: 0.20, green: 0.45, blue: 0.90)
        case .forest:   return Color(red: 0.902, green: 0.690, blue: 0.431)
        }
    }

    // Primary text color
    var primaryColor: Color {
        switch self {
        case .frost: return Color(red: 0.10, green: 0.12, blue: 0.18)
        default:     return .white
        }
    }

    // Secondary text color
    var secondaryColor: Color {
        switch self {
        case .frost: return Color(red: 0.10, green: 0.12, blue: 0.18).opacity(0.45)
        default:     return .white.opacity(0.45)
        }
    }

    // Divider color
    var dividerColor: Color {
        switch self {
        case .frost: return Color.black.opacity(0.10)
        default:     return Color.white.opacity(0.12)
        }
    }

    // Share button background
    var buttonBackground: Color {
        switch self {
        case .midnight: return Color(red: 0.08, green: 0.12, blue: 0.35)
        case .ember:    return Color(red: 0.30, green: 0.10, blue: 0.03)
        case .frost:    return Color(red: 0.20, green: 0.45, blue: 0.90)
        case .forest:   return Color(red: 0.25, green: 0.17, blue: 0.07)
        }
    }
}

// MARK: - Share Card

struct WorkoutSummaryShareCard: View {
    let workoutName: String
    let duration: String
    let date: Date
    let reps: Int32
    let weightLifted: Float
    let totalDistance: Float
    let cardioTime: String
    var style: ShareCardStyle = .midnight
    var logoImage: UIImage? = UIImage(named: "Soleus_Launch")

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM d, yyyy"
        return f.string(from: date)
    }

    private var stats: [(icon: String, value: String, label: String)] {
        var result: [(String, String, String)] = []
        result.append(("clock.fill", duration, "Duration"))
        if weightLifted > 0 {
            result.append(("scalemass.fill", String(format: "%.0f lbs", weightLifted), "Weight Lifted"))
        }
        if reps > 0 {
            result.append(("figure.strengthtraining.traditional", "\(reps)", "Reps"))
        }
        if totalDistance > 0 {
            result.append(("figure.run", String(format: "%.1f mi", totalDistance), "Distance"))
        }
        if !cardioTime.isEmpty && cardioTime != "00:00:00" {
            result.append(("timer", cardioTime, "Cardio Time"))
        }
        return result
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: style.backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [style.glowColor, Color.clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 300
            )

            VStack(alignment: .leading, spacing: 0) {

                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Soleus Fitness")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(style.primaryColor.opacity(0.5))
                        Text("Workout Summary")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(style.secondaryColor)
                    }
                    Spacer()
                    if let logoImage {
                        Image(uiImage: logoImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                            .opacity(0.85)
                    }
                }
                .padding(.bottom, 28)

                // Workout name
                Text(workoutName)
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(style.primaryColor)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .padding(.bottom, 4)

                Text(formattedDate)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(style.secondaryColor)
                    .padding(.bottom, 32)

                // Divider
                Rectangle()
                    .fill(style.dividerColor)
                    .frame(height: 1)
                    .padding(.bottom, 28)

                // Stats
                let columns = [GridItem(.flexible()), GridItem(.flexible())]
                LazyVGrid(columns: columns, alignment: .leading, spacing: 24) {
                    ForEach(stats.prefix(4), id: \.label) { stat in
                        StatBlock(icon: stat.icon, value: stat.value, label: stat.label, style: style)
                    }
                }

                Spacer()

                // Footer
                HStack {
                    Spacer()
                    Text("Built with Soleus")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(style.secondaryColor.opacity(0.6))
                }
            }
            .padding(28)
        }
        .frame(width: 360, height: 480)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

// MARK: - Stat Block

private struct StatBlock: View {
    let icon: String
    let value: String
    let label: String
    let style: ShareCardStyle

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(style.accentColor)
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(style.primaryColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(style.secondaryColor)
        }
    }
}
