import Foundation

/// Errors that can occur during CoreData operations
enum CoreDataError: LocalizedError, Equatable {
    public static func == (lhs: CoreDataError, rhs: CoreDataError) -> Bool {
        switch (lhs, rhs) {
        case (.contextNotAvailable, .contextNotAvailable): return true
        case (.saveFailed, .saveFailed): return true
        case (.fetchFailed, .fetchFailed): return true
        case (.deleteFailed, .deleteFailed): return true
        case (.workoutNotFound(let a), .workoutNotFound(let b)): return a == b
        case (.invalidData(let a), .invalidData(let b)): return a == b
        default: return false
        }
    }
    case contextNotAvailable
    case saveFailed(Error)
    case fetchFailed(Error)
    case deleteFailed(Error)
    case workoutNotFound(UUID)
    case invalidData(String)

    var errorDescription: String? {
        switch self {
        case .contextNotAvailable:
            return "Database is not available. Please restart the app."
        case .saveFailed(let error):
            return "Failed to save workout data: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to load workout data: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete workout: \(error.localizedDescription)"
        case .workoutNotFound(let id):
            return "Workout with ID \(id) not found."
        case .invalidData(let message):
            return "Invalid data: \(message)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .contextNotAvailable:
            return "Try restarting the app. If the problem persists, you may need to reinstall."
        case .saveFailed:
            return "Your changes may not have been saved. Please try again."
        case .fetchFailed:
            return "Unable to load your workouts. Please check your internet connection and try again."
        case .deleteFailed:
            return "The workout could not be deleted. Please try again."
        case .workoutNotFound:
            return "This workout may have been deleted. Please refresh the list."
        case .invalidData:
            return "Please check your input and try again."
        }
    }
}
