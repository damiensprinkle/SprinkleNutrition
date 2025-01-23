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
            
            Spacer()
            
            Button(action: toggleTimer) {
                Image(systemName: timerRunning ? "pause.circle" : "play.circle")
                    .font(.title)
            }
            
            Button(action: resetTimer) {
                Image(systemName: "stop.circle")
                    .font(.title)
            }
            
            Button(action: { showTimer = false }) {
                Image(systemName: "xmark.circle")
                    .font(.title)
            }
        }
        .padding()
        .onAppear(perform: setupTimer)
        .onDisappear(perform: stopTimer)
    }

    // MARK: - Timer Logic

    private func toggleTimer() {
        timerRunning.toggle()
        if timerRunning {
            if timer == nil {
                setupTimer()
            }
        }
    }

    private func resetTimer() {
        stopTimer()
        elapsedTime = 0
    }

    private func stopTimer() {
        timerRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func setupTimer() {
        guard timer == nil else { return } 
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timerRunning {
                elapsedTime += 1
            }
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
