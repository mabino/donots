import Foundation

enum DateFormatting {
    private static let filenameFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd_HHmmss"
        return f
    }()

    private static let logFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f
    }()

    static func filenameTimestamp(_ date: Date = Date()) -> String {
        filenameFormatter.string(from: date)
    }

    static func logTimestamp(_ date: Date = Date()) -> String {
        logFormatter.string(from: date)
    }
}
