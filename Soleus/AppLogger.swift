//
//  AppLogger.swift
//  FlexSprinkle
//
//  Centralized logging system using OSLog
//

import Foundation
import OSLog

/// Centralized logging system for FlexSprinkle app
/// Use these loggers throughout the app for better debugging and crash analysis
struct AppLogger {

    // MARK: - Subsystem
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.flexsprinkle.app"

    // MARK: - Category Loggers

    /// Logger for workout tracking operations
    static let workout = Logger(subsystem: subsystem, category: "workout")

    /// Logger for CoreData operations
    static let coreData = Logger(subsystem: subsystem, category: "coredata")

    /// Logger for UI events and view lifecycle
    static let ui = Logger(subsystem: subsystem, category: "ui")

    /// Logger for navigation and routing
    static let navigation = Logger(subsystem: subsystem, category: "navigation")

    /// Logger for data validation and errors
    static let validation = Logger(subsystem: subsystem, category: "validation")

    /// Logger for general app lifecycle events
    static let lifecycle = Logger(subsystem: subsystem, category: "lifecycle")
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
 // 3. Filter: process:FlexSprinkle
 // 4. Or filter by category: category:workout

 */
