import Foundation

enum LogLevel: String, Sendable {
    case info
    case warning
    case error
    case success
}

struct LogEntry: Identifiable, Sendable {
    let id = UUID()
    let timestamp: Date
    let message: String
    let level: LogLevel

    init(_ message: String, level: LogLevel = .info) {
        self.timestamp = Date()
        self.message = message
        self.level = level
    }
}
