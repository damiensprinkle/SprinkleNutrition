import SwiftUI

struct TimerHeaderView: View {
    @Binding var showTimer: Bool
    @State private var elapsedTime: TimeInterval = 0
    @State private var timerRunning: Bool = false
    @State private var timer: Timer?

    var body: some View {
        HStack(spacing: 16) {
            // Timer circle with animated border
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 4)
                    .frame(width: 60, height: 60)

                // Animated rotating circle when timer is running
                if timerRunning {
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(Double(elapsedTime) * 60))
                        .animation(.linear(duration: 1), value: elapsedTime)
                }

                VStack(spacing: 2) {
                    Image(systemName: "stopwatch")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    Text(formatTime(elapsedTime))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Custom Timer")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))

                HStack(spacing: 12) {
                    // Play/Pause button
                    Button(action: toggleTimer) {
                        Image(systemName: timerRunning ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(timerRunning ? .yellow : .green)
                    }

                    // Reset button
                    Button(action: resetTimer) {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.blue)
                    }
                }
            }

            Spacer()

            // Close button
            Button(action: {
                cleanupTimer()
                showTimer = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .onDisappear(perform: cleanupTimer)
    }

    // MARK: - Timer Logic

    private func toggleTimer() {
        timerRunning.toggle()
        if timerRunning {
            startTimer()
        } else {
            pauseTimer()
        }
    }

    private func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] _ in
            // Update elapsed time
            self.elapsedTime += 1
        }
    }

    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func resetTimer() {
        cleanupTimer()
        timerRunning = false
        elapsedTime = 0
    }

    private func cleanupTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
