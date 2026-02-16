import Foundation
import OSLog

/// Centralized logging system for Soleus app
/// Use these loggers throughout the app for better debugging and crash analysis
struct AppLogger {

    // MARK: - Subsystem
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.damiensprinkle.soleus"

    // MARK: - Category Loggers

    /// Logger for workout tracking operations
    static let workout = CapturedLogger(category: "Workout")
    static let activeWorkout = CapturedLogger(category: "ActiveWorkout")


    /// Logger for CoreData operations
    static let coreData = CapturedLogger(category: "CoreData")

    /// Logger for UI events and view lifecycle
    static let ui = CapturedLogger(category: "UI")

    /// Logger for navigation and routing
    static let navigation = CapturedLogger(category: "Navigation")

    /// Logger for data validation and errors
    static let validation = CapturedLogger(category: "Validation")

    /// Logger for general app lifecycle events
    static let lifecycle = CapturedLogger(category: "Lifecycle")
}

/// Logger wrapper that sends to both OSLog and in-memory LogCapture
class CapturedLogger {
    private let osLogger: Logger
    private let category: String

    init(category: String) {
        let subsystem = Bundle.main.bundleIdentifier ?? "com.damiensprinkle.soleus"
        self.osLogger = Logger(subsystem: subsystem, category: category.lowercased())
        self.category = category
    }

    func debug(_ message: String) {
        osLogger.debug("\(message)")
        LogCapture.shared.debug(message, category: category)
    }

    func info(_ message: String) {
        osLogger.info("\(message)")
        LogCapture.shared.info(message, category: category)
    }

    func warning(_ message: String) {
        osLogger.warning("\(message)")
        LogCapture.shared.warning(message, category: category)
    }

    func error(_ message: String) {
        osLogger.error("\(message)")
        LogCapture.shared.error(message, category: category)
    }

    func critical(_ message: String) {
        osLogger.critical("\(message)")
        LogCapture.shared.critical(message, category: category)
    }
}

// MARK: - Usage Examples
/*

 // Error logging (appears in red in Console.app)
 AppLogger.coreData.error("Failed to save context: \(error.localizedDescription)")

 // Warning logging (appears in yellow)
 AppLogger.validation.warning("exerciseId is nil, cannot save workout detail")

 // Info logging (appears normally, persisted)
 AppLogger.workout.info("Deleted \(count) temporary workout details")

 // Debug logging (only shows in debug builds)
 AppLogger.ui.debug("User tapped button at index \(index)")

 // Viewing logs:
 // 1. Open Console.app on Mac
 // 2. Select your iPhone from sidebar
 // 3. Filter: process:Soleus
 // 4. Or filter by category: category:workout

 */
