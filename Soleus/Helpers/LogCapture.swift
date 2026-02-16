import Foundation
import Combine

class LogCapture: ObservableObject {
    static let shared = LogCapture()

    @Published var logs: [LogEntry] = []
    private let maxLogs = 500

    struct LogEntry: Identifiable {
        let id = UUID()
        let timestamp: Date
        let category: String
        let level: LogLevel
        let message: String

        var formattedTime: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss.SSS"
            return formatter.string(from: timestamp)
        }
    }

    enum LogLevel: String {
        case debug = "🔍"
        case info = "ℹ️"
        case warning = "⚠️"
        case error = "❌"
        case critical = "🔥"
    }

    private init() {}

    func log(_ message: String, category: String = "General", level: LogLevel = .info) {
        DispatchQueue.main.async {
            let entry = LogEntry(
                timestamp: Date(),
                category: category,
                level: level,
                message: message
            )

            self.logs.append(entry)

            // Keep only recent logs
            if self.logs.count > self.maxLogs {
                self.logs.removeFirst(self.logs.count - self.maxLogs)
            }
        }
    }

    func debug(_ message: String, category: String = "General") {
        log(message, category: category, level: .debug)
    }

    func info(_ message: String, category: String = "General") {
        log(message, category: category, level: .info)
    }

    func warning(_ message: String, category: String = "General") {
        log(message, category: category, level: .warning)
    }

    func error(_ message: String, category: String = "General") {
        log(message, category: category, level: .error)
    }

    func critical(_ message: String, category: String = "General") {
        log(message, category: category, level: .critical)
    }

    func clear() {
        DispatchQueue.main.async {
            self.logs.removeAll()
        }
    }
}
