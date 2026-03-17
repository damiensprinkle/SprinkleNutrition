import UIKit

/// Provides different sharing representations depending on the target activity.
/// For Messages: shares a text message with a `soleus://import?data=…` deep link.
/// For everything else (AirDrop, Mail, Files, etc.): shares the `.soleus` file directly.
final class WorkoutActivityItemProvider: UIActivityItemProvider {
    private let fileURL: URL
    private let workoutData: Data
    private let workoutName: String

    init(fileURL: URL, workoutData: Data, workoutName: String) {
        self.fileURL = fileURL
        self.workoutData = workoutData
        self.workoutName = workoutName
        super.init(placeholderItem: fileURL)
    }

    override var item: Any {
        if activityType == .message {
            let base64 = workoutData.base64EncodedString()
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "=", with: "")
            let link = "soleus://import?data=\(base64)"
            return "\(workoutName) was shared with you via Soleus\n\(link)"
        }
        return fileURL
    }
}
