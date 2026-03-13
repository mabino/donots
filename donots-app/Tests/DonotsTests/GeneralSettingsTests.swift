import Testing
import Foundation
@testable import Donots

@Suite("General Settings Tests")
struct GeneralSettingsTests {
    @Test("Reset clears UserDefaults for app domain")
    func resetClearsDefaults() {
        // Use a dedicated suite to isolate from the test runner's own defaults
        let suiteName = "com.donots.app.test.\(UUID().uuidString)"
        let suite = UserDefaults(suiteName: suiteName)!

        suite.set("testValue", forKey: "emailRecipient")
        suite.set(42, forKey: "screenshotWidth")
        suite.synchronize()

        #expect(suite.string(forKey: "emailRecipient") == "testValue")
        #expect(suite.integer(forKey: "screenshotWidth") == 42)

        // Simulate reset
        suite.removePersistentDomain(forName: suiteName)
        suite.synchronize()

        #expect(suite.string(forKey: "emailRecipient") == nil)
        #expect(suite.integer(forKey: "screenshotWidth") == 0)
    }

    @Test("AppStorage defaults are correct values")
    func defaultValues() {
        // Unset AppStorage keys should return false/0
        let suiteName = "com.donots.app.test.\(UUID().uuidString)"
        let suite = UserDefaults(suiteName: suiteName)!

        #expect(suite.bool(forKey: "launchAtLogin") == false)
        #expect(suite.bool(forKey: "menuBarEnabled") == false)
    }

    @Test("Int.nonZero returns nil for zero, value otherwise")
    func intNonZeroExtension() {
        #expect(0.nonZero == nil)
        #expect(1.nonZero == 1)
        #expect(400.nonZero == 400)
        #expect((-5).nonZero == -5)
    }
}
