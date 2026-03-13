import Testing
@testable import Donots

@Suite("ScreenshotService Tests")
struct ScreenshotServiceTests {
    @Test("Path generation produces correct format with PNG")
    func pathGenerationPNG() {
        let path = ScreenshotService.screenshotPath(
            directory: "/tmp/screenshots",
            timestamp: "20240101_120000",
            index: 1,
            format: .png
        )
        #expect(path == "/tmp/screenshots/notification_20240101_120000_1.png")
    }

    @Test("Path generation produces correct format with JPEG")
    func pathGenerationJPEG() {
        let path = ScreenshotService.screenshotPath(
            directory: "/tmp/screenshots",
            timestamp: "20240101_120000",
            index: 1,
            format: .jpeg
        )
        #expect(path == "/tmp/screenshots/notification_20240101_120000_1.jpg")
    }

    @Test("Path generation defaults to PNG")
    func pathGenerationDefault() {
        let path = ScreenshotService.screenshotPath(
            directory: "/tmp/screenshots",
            timestamp: "20240101_120000",
            index: 1
        )
        #expect(path == "/tmp/screenshots/notification_20240101_120000_1.png")
    }

    @Test("Path generation with tilde expands home directory")
    func tildeExpansion() {
        let path = ScreenshotService.screenshotPath(
            directory: "~/screenshots",
            timestamp: "20240101_120000",
            index: 2
        )
        #expect(!path.contains("~"))
        #expect(path.hasSuffix("/screenshots/notification_20240101_120000_2.png"))
    }

    @Test("Path includes index number")
    func indexInPath() {
        for i in 1...5 {
            let path = ScreenshotService.screenshotPath(
                directory: "/tmp",
                timestamp: "20240101_120000",
                index: i
            )
            #expect(path.contains("_\(i).png"))
        }
    }

    @Test("JPEG path includes index number")
    func indexInJPEGPath() {
        for i in 1...3 {
            let path = ScreenshotService.screenshotPath(
                directory: "/tmp",
                timestamp: "20240101_120000",
                index: i,
                format: .jpeg
            )
            #expect(path.contains("_\(i).jpg"))
        }
    }
}
