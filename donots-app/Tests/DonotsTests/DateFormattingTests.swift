import Testing
import Foundation
@testable import Donots

@Suite("DateFormatting Tests")
struct DateFormattingTests {
    @Test("Filename timestamp format")
    func filenameFormat() {
        let date = DateComponents(
            calendar: Calendar.current,
            year: 2024, month: 1, day: 15,
            hour: 14, minute: 30, second: 45
        ).date!
        let result = DateFormatting.filenameTimestamp(date)
        #expect(result == "20240115_143045")
    }

    @Test("Log timestamp format")
    func logFormat() {
        let date = DateComponents(
            calendar: Calendar.current,
            year: 2024, month: 1, day: 15,
            hour: 14, minute: 30, second: 45
        ).date!
        let result = DateFormatting.logTimestamp(date)
        #expect(result == "2024-01-15 14:30:45")
    }

    @Test("Default parameter uses current time")
    func defaultTimestamp() {
        let result = DateFormatting.filenameTimestamp()
        #expect(!result.isEmpty)
        #expect(result.count == 15) // yyyyMMdd_HHmmss
    }
}
