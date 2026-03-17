import Foundation

/// Codable model for exporting/importing workouts as JSON
/// File format: 4-byte magic header "SLSE" followed by UTF-8 JSON.
/// The binary header prevents QuickLook from rendering the file as plain text,
/// so iMessage shows it as a tappable file bubble rather than an inline text preview.
struct ShareableWorkout: Codable, Equatable {
    // Magic bytes that prefix every exported .soleus file
    private static let magic: [UInt8] = [0x53, 0x4C, 0x53, 0x45] // "SLSE"
    var version: String = "1.0"
    let workoutName: String
    let workoutColor: String?
    let exercises: [ShareableExercise]
    let exportDate: Date

    struct ShareableExercise: Codable, Equatable {
        let name: String
        let orderIndex: Int32
        let quantifier: String // "Reps" or "Distance"
        let measurement: String // "Weight" or "Time"
        let sets: [ShareableSet]
        let notes: String?
    }

    struct ShareableSet: Codable, Equatable {
        let setIndex: Int32
        let reps: Int32
        let weight: Float
        let time: Int32
        let distance: Float
    }

    /// Export workout details to JSON data
    static func export(workoutName: String, workoutColor: String?, workoutDetails: [WorkoutDetailInput]) -> Data? {
        let exercises = workoutDetails.map { detail in
            let sets = detail.sets.map { set in
                ShareableSet(
                    setIndex: set.setIndex,
                    reps: set.reps,
                    weight: set.weight,
                    time: set.time,
                    distance: set.distance
                )
            }

            return ShareableExercise(
                name: detail.exerciseName,
                orderIndex: detail.orderIndex,
                quantifier: detail.exerciseQuantifier,
                measurement: detail.exerciseMeasurement,
                sets: sets,
                notes: detail.notes
            )
        }

        let shareableWorkout = ShareableWorkout(
            workoutName: workoutName,
            workoutColor: workoutColor,
            exercises: exercises,
            exportDate: Date()
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        // Compact JSON — file has a binary header so human-readability isn't needed,
        // and smaller JSON means shorter base64 URLs when sharing via Messages.

        guard let jsonData = try? encoder.encode(shareableWorkout) else { return nil }

        // Compress the JSON payload. zlib typically halves JSON size, which cuts
        // the base64-encoded iMessage link from ~1500 chars down to ~500-600.
        let payload: Data
        if let compressed = try? (jsonData as NSData).compressed(using: .zlib) {
            payload = compressed as Data
        } else {
            payload = jsonData
        }

        var result = Data(magic)
        result.append(payload)
        return result
    }

    /// Import workout from .soleus file data.
    /// Handles compressed (current), uncompressed, and legacy raw-JSON formats.
    static func `import`(from data: Data) -> ShareableWorkout? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let jsonData: Data
        if data.prefix(magic.count) == Data(magic) {
            let payload = data.dropFirst(magic.count)
            // Try zlib decompression first (current format), fall back to plain JSON.
            if let decompressed = try? (payload as NSData).decompressed(using: .zlib) {
                jsonData = decompressed as Data
            } else {
                jsonData = Data(payload)
            }
        } else {
            // Legacy: raw JSON without magic header
            jsonData = data
        }

        return try? decoder.decode(ShareableWorkout.self, from: jsonData)
    }

    /// Convert to WorkoutDetailInput array for saving
    func toWorkoutDetails() -> [WorkoutDetailInput] {
        return exercises.map { exercise in
            let setInputs = exercise.sets.map { set in
                SetInput(
                    reps: set.reps,
                    weight: set.weight,
                    time: set.time,
                    distance: set.distance,
                    setIndex: set.setIndex
                )
            }

            return WorkoutDetailInput(
                id: UUID(), // Generate new ID for imported workout
                exerciseId: UUID(), // Generate new exercise ID
                exerciseName: exercise.name,
                notes: exercise.notes, orderIndex: exercise.orderIndex,
                sets: setInputs,
                exerciseQuantifier: exercise.quantifier,
                exerciseMeasurement: exercise.measurement
            )
        }
    }
}
