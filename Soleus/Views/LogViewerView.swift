import SwiftUI

struct LogViewerView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var logCapture = LogCapture.shared

    @State private var selectedLevel: LogCapture.LogLevel?
    @State private var selectedCategory: String?
    @State private var searchText = ""

    private var categories: [String] {
        Array(Set(logCapture.logs.map { $0.category })).sorted()
    }

    private var filteredLogs: [LogCapture.LogEntry] {
        logCapture.logs
            .filter { entry in
                if let level = selectedLevel, entry.level != level {
                    return false
                }
                if let category = selectedCategory, entry.category != category {
                    return false
                }
                if !searchText.isEmpty && !entry.message.localizedCaseInsensitiveContains(searchText) {
                    return false
                }
                return true
            }
            .reversed() // Show newest first
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search logs...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()

                // Filter buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // Level filters
                        ForEach([LogCapture.LogLevel.debug, .info, .warning, .error, .critical], id: \.self) { level in
                            Button(action: {
                                selectedLevel = selectedLevel == level ? nil : level
                            }) {
                                Text("\(level.rawValue)")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedLevel == level ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedLevel == level ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }

                        Divider()
                            .frame(height: 20)

                        // Category filters
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = selectedCategory == category ? nil : category
                            }) {
                                Text(category)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedCategory == category ? Color.green : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedCategory == category ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 8)

                Divider()

                // Log list
                if filteredLogs.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.5))
                        Text(logCapture.logs.isEmpty ? "No logs yet" : "No matching logs")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 4) {
                            ForEach(filteredLogs) { entry in
                                LogEntryRow(entry: entry)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("App Logs (\(filteredLogs.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear") {
                        logCapture.clear()
                    }
                    .foregroundColor(.red)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct LogEntryRow: View {
    let entry: LogCapture.LogEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(entry.level.rawValue)
                    .font(.caption)

                Text(entry.formattedTime)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(entry.category)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)

                Spacer()
            }

            Text(entry.message)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.primary)
        }
        .padding(8)
        .background(backgroundColor)
        .cornerRadius(8)
    }

    private var backgroundColor: Color {
        switch entry.level {
        case .debug:
            return Color.gray.opacity(0.1)
        case .info:
            return Color.blue.opacity(0.05)
        case .warning:
            return Color.yellow.opacity(0.1)
        case .error:
            return Color.red.opacity(0.1)
        case .critical:
            return Color.red.opacity(0.2)
        }
    }
}

#Preview {
    LogViewerView()
}
