import Testing
import Foundation
@testable import Donots

@Suite("LogEntry Tests")
struct LogEntryTests {
    @Test("Default level is info")
    func defaultLevel() {
        let entry = LogEntry("test message")
        #expect(entry.level == .info)
        #expect(entry.message == "test message")
    }

    @Test("Custom level is preserved")
    func customLevel() {
        let entry = LogEntry("error occurred", level: .error)
        #expect(entry.level == .error)
    }

    @Test("Each entry gets unique ID")
    func uniqueIDs() {
        let a = LogEntry("a")
        let b = LogEntry("b")
        #expect(a.id != b.id)
    }

    @Test("Timestamp is set at creation")
    func timestampSet() {
        let before = Date()
        let entry = LogEntry("test")
        let after = Date()
        #expect(entry.timestamp >= before)
        #expect(entry.timestamp <= after)
    }

    @Test("All log levels")
    func allLevels() {
        let levels: [LogLevel] = [.info, .warning, .error, .success]
        for level in levels {
            let entry = LogEntry("msg", level: level)
            #expect(entry.level == level)
        }
    }
}
