import Foundation
import SwiftUI
import Combine
import OSLog

class RestTimerManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isResting: Bool = false
    @Published var remainingTime: Int = 0
    @Published var totalRestTime: Int = 0

    // MARK: - Private Properties
    private var timer: AnyCancellable?
    private var restEndTime: Date?

    // MARK: - Timer Control

    /// Start rest timer with specified duration
    func startRest(duration: Int) {
        guard duration > 0 else { return }

        isResting = true
        totalRestTime = duration
        remainingTime = duration
        restEndTime = Date().addingTimeInterval(TimeInterval(duration))

        startTimer()
        AppLogger.workout.info("Started rest timer: \(duration)s")
    }

    /// Pause the rest timer
    func pauseRest() {
        stopTimer()
        restEndTime = nil
        AppLogger.workout.debug("Paused rest timer at \(self.remainingTime)s remaining")
    }

    /// Resume the rest timer
    func resumeRest() {
        guard remainingTime > 0 else { return }
        restEndTime = Date().addingTimeInterval(TimeInterval(remainingTime))
        startTimer()
        AppLogger.workout.debug("Resumed rest timer with \(self.remainingTime)s remaining")
    }

    /// Skip/cancel the rest timer
    func skipRest() {
        stopTimer()
        isResting = false
        remainingTime = 0
        totalRestTime = 0
        restEndTime = nil
        HapticManager.shared.restTimerSkipped()
        AppLogger.workout.debug("Skipped rest timer")
    }

    /// Add time to rest timer
    func addTime(_ seconds: Int) {
        guard isResting else { return }

        remainingTime += seconds
        totalRestTime += seconds
        if let endTime = restEndTime {
            restEndTime = endTime.addingTimeInterval(TimeInterval(seconds))
        }
        AppLogger.workout.debug("Added \(seconds)s to rest timer")
    }

    /// Remove time from rest timer
    func subtractTime(_ seconds: Int) {
        guard isResting else { return }

        let newRemaining = max(0, remainingTime - seconds)
        let actualSubtraction = remainingTime - newRemaining

        remainingTime = newRemaining
        totalRestTime -= actualSubtraction

        if newRemaining == 0 {
            completeRest()
        } else if let endTime = restEndTime {
            restEndTime = endTime.addingTimeInterval(TimeInterval(-actualSubtraction))
        }

        AppLogger.workout.debug("Subtracted \(actualSubtraction)s from rest timer")
    }

    // MARK: - Private Methods

    private func startTimer() {
        stopTimer() // Clear any existing timer

        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimer()
            }
    }

    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }

    private func updateTimer() {
        guard let endTime = restEndTime else {
            stopTimer()
            return
        }

        let now = Date()
        let remaining = endTime.timeIntervalSince(now)

        if remaining <= 0 {
            completeRest()
        } else {
            let newRemainingTime = Int(ceil(remaining))
            // Only update if value actually changed to reduce view updates
            if newRemainingTime != remainingTime {
                remainingTime = newRemainingTime
            }
        }
    }

    private func completeRest() {
        stopTimer()
        isResting = false
        remainingTime = 0
        totalRestTime = 0
        restEndTime = nil
        HapticManager.shared.restTimerCompleted()
        AppLogger.workout.info("Rest timer completed")
    }

    // MARK: - Lifecycle

    deinit {
        stopTimer()
    }
}

// MARK: - Formatting Helpers

extension RestTimerManager {
    var formattedTime: String {
        let minutes = remainingTime / 60
        let seconds = remainingTime % 60

        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return "\(seconds)s"
        }
    }

    var progressPercentage: Double {
        guard totalRestTime > 0 else { return 0 }
        return Double(remainingTime) / Double(totalRestTime)
    }
}
