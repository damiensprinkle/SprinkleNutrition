import SwiftUI

struct RestTimerView: View {
    @ObservedObject var restTimer: RestTimerManager

    var body: some View {
        if restTimer.isResting {
            VStack(spacing: 12) {
                // Timer display
                HStack(spacing: 16) {
                    // Timer circle with progress
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                            .frame(width: 60, height: 60)

                        Circle()
                            .trim(from: 0, to: restTimer.progressPercentage)
                            .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.1), value: restTimer.progressPercentage)

                        Text(restTimer.formattedTime)
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.primary)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Rest timer")
                    .accessibilityValue("\(restTimer.formattedTime) remaining")
                    .accessibilityAddTraits(.updatesFrequently)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Rest Time")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        HStack(spacing: 8) {
                            // -30s button
                            Button(action: {
                                restTimer.subtractTime(30)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.orange)
                            }
                            .accessibilityLabel("Subtract 30 seconds")
                            .accessibilityHint("Removes 30 seconds from rest timer")

                            // +30s button
                            Button(action: {
                                restTimer.addTime(30)
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.blue)
                            }
                            .accessibilityLabel("Add 30 seconds")
                            .accessibilityHint("Adds 30 seconds to rest timer")

                            // Skip button
                            Button(action: {
                                restTimer.skipRest()
                            }) {
                                Text("Skip")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 32)
                                    .background(Color.red)
                                    .cornerRadius(8)
                            }
                            .accessibilityLabel("Skip rest")
                            .accessibilityHint("Ends rest timer and continues workout")
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemGroupedBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
            }
            .padding(.horizontal)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - Compact Timer View (for inline display)

struct CompactRestTimerView: View {
    @ObservedObject var restTimer: RestTimerManager

    var body: some View {
        if restTimer.isResting {
            HStack(spacing: 12) {
                // Compact timer display
                HStack(spacing: 6) {
                    Image(systemName: "timer")
                        .font(.system(size: 14))
                        .foregroundColor(.green)

                    Text(restTimer.formattedTime)
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        .foregroundColor(.primary)
                }

                // Quick actions
                HStack(spacing: 8) {
                    Button(action: {
                        restTimer.subtractTime(15)
                    }) {
                        Text("-15s")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.15))
                            .cornerRadius(6)
                    }

                    Button(action: {
                        restTimer.addTime(15)
                    }) {
                        Text("+15s")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.15))
                            .cornerRadius(6)
                    }

                    Button(action: {
                        restTimer.skipRest()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.tertiarySystemGroupedBackground))
            )
            .transition(.scale.combined(with: .opacity))
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        let timer1 = RestTimerManager()
        let timer2 = RestTimerManager()

        RestTimerView(restTimer: timer1)
            .onAppear {
                timer1.startRest(duration: 90)
            }

        CompactRestTimerView(restTimer: timer2)
            .onAppear {
                timer2.startRest(duration: 45)
            }
    }
    .padding()
}
