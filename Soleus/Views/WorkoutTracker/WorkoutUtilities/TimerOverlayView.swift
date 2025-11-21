//
//  TimerOverlayView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 11/21/24.
//

import SwiftUI

struct TimerHeaderView: View {
    @Binding var showTimer: Bool
    @State private var elapsedTime: TimeInterval = 0
    @State private var timerRunning: Bool = false
    @State private var timer: Timer?

    var body: some View {
        HStack {
            Text(formatTime(elapsedTime))
                .font(.headline)
                .foregroundColor(.myWhite)

            Spacer()

            Button(action: toggleTimer) {
                Image(systemName: timerRunning ? "pause.circle" : "play.circle")
                    .font(.title)
                    .foregroundColor(.myWhite)
            }

            Button(action: resetTimer) {
                Image(systemName: "stop.circle")
                    .font(.title)
                    .foregroundColor(.myWhite)
            }

            Button(action: {
                cleanupTimer()
                showTimer = false
            }) {
                Image(systemName: "xmark.circle")
                    .font(.title)
                    .foregroundColor(.myWhite)
            }
        }
        .padding()
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
