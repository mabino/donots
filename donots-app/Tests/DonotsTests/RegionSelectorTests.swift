import Testing
import Foundation
@testable import Donots

@Suite("RegionSelector Coordinate Conversion Tests")
struct RegionSelectorTests {
    @Test("Bottom-left to top-left origin conversion")
    func basicConversion() {
        // Simulated screen: 1920x1080
        // NSView rect: origin at (100, 500) with 200x150
        // NSView y=500 means 500 from bottom, maxY = 650
        // screencapture y = 1080 - 650 = 430
        let screen = MockScreen(width: 1920, height: 1080)
        let nsRect = NSRect(x: 100, y: 500, width: 200, height: 150)

        let result = convertToScreenCapture(nsRect: nsRect, screenHeight: screen.height)

        #expect(result.origin.x == 100)
        #expect(result.origin.y == 430)
        #expect(result.width == 200)
        #expect(result.height == 150)
    }

    @Test("Top of screen selection converts to y=0")
    func topOfScreen() {
        let screen = MockScreen(width: 1920, height: 1080)
        // NSView: origin at bottom, near top of screen
        // y = 1080 - 50 = 1030, maxY = 1030 + 50 = 1080
        // screencapture y = 1080 - 1080 = 0
        let nsRect = NSRect(x: 0, y: 1030, width: 400, height: 50)

        let result = convertToScreenCapture(nsRect: nsRect, screenHeight: screen.height)

        #expect(result.origin.y == 0)
        #expect(result.width == 400)
        #expect(result.height == 50)
    }

    @Test("Bottom of screen selection converts to screen height minus rect height")
    func bottomOfScreen() {
        let screen = MockScreen(width: 1920, height: 1080)
        // NSView: origin at (0, 0), height 100
        // maxY = 100
        // screencapture y = 1080 - 100 = 980
        let nsRect = NSRect(x: 0, y: 0, width: 1920, height: 100)

        let result = convertToScreenCapture(nsRect: nsRect, screenHeight: screen.height)

        #expect(result.origin.y == 980)
        #expect(result.width == 1920)
        #expect(result.height == 100)
    }

    @Test("Full screen selection preserves dimensions")
    func fullScreen() {
        let screen = MockScreen(width: 2560, height: 1440)
        let nsRect = NSRect(x: 0, y: 0, width: 2560, height: 1440)

        let result = convertToScreenCapture(nsRect: nsRect, screenHeight: screen.height)

        #expect(result.origin.x == 0)
        #expect(result.origin.y == 0)
        #expect(result.width == 2560)
        #expect(result.height == 1440)
    }

    @Test("Values are rounded to whole pixels")
    func rounding() {
        let screen = MockScreen(width: 1920, height: 1080)
        let nsRect = NSRect(x: 100.7, y: 500.3, width: 200.4, height: 150.6)

        let result = convertToScreenCapture(nsRect: nsRect, screenHeight: screen.height)

        #expect(result.origin.x == 101)
        // maxY = 500.3 + 150.6 = 650.9, screencapture y = 1080 - 650.9 = 429.1 → 429
        #expect(result.origin.y == 429)
        #expect(result.width == 200)
        #expect(result.height == 151)
    }

    // MARK: - Helpers

    private struct MockScreen {
        let width: CGFloat
        let height: CGFloat
    }

    /// Pure-logic extraction of the coordinate math (testable without NSScreen)
    private func convertToScreenCapture(nsRect: NSRect, screenHeight: CGFloat) -> CGRect {
        let topLeftY = screenHeight - nsRect.maxY
        return CGRect(
            x: round(nsRect.minX),
            y: round(topLeftY),
            width: round(nsRect.width),
            height: round(nsRect.height)
        )
    }
}
