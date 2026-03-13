import Testing
@testable import Donots

@Suite("AppleScriptService Tests")
struct AppleScriptServiceTests {
    @Test("Notification check script contains expected elements")
    func notificationCheckScriptStructure() {
        let script = AppleScriptService.notificationCheckScript
        #expect(script.contains("System Events"))
        #expect(script.contains("Notification Center"))
        #expect(script.contains("notification_detected"))
        #expect(script.contains("UI element"))
        #expect(script.contains("window 1"))
    }

    @Test("Display bounds script contains expected elements")
    func displayBoundsScriptStructure() {
        let script = AppleScriptService.displayBoundsScript
        #expect(script.contains("System Events"))
        #expect(script.contains("bounds"))
        #expect(script.contains("desktop"))
    }

    @Test("Email script includes all parameters")
    func emailScriptConstruction() {
        let script = AppleScriptService.emailScript(
            subject: "Test Subject",
            content: "Test Body",
            recipientName: "John Doe",
            recipientAddress: "john@example.com",
            ccAddress: "cc@example.com",
            screenshotPaths: ["/tmp/test1.png", "/tmp/test2.png"]
        )
        #expect(script.contains("Test Subject"))
        #expect(script.contains("Test Body"))
        #expect(script.contains("John Doe"))
        #expect(script.contains("john@example.com"))
        #expect(script.contains("cc@example.com"))
        #expect(script.contains("/tmp/test1.png"))
        #expect(script.contains("/tmp/test2.png"))
        #expect(script.contains("Mail"))
        #expect(script.contains("to recipient"))
        #expect(script.contains("cc recipient"))
        #expect(script.contains("send"))
    }

    @Test("Email script with no attachments")
    func emailScriptNoAttachments() {
        let script = AppleScriptService.emailScript(
            subject: "Sub",
            content: "Body",
            recipientName: "Name",
            recipientAddress: "a@b.com",
            ccAddress: "c@b.com",
            screenshotPaths: []
        )
        #expect(script.contains("Mail"))
        #expect(!script.contains("POSIX file"))
    }

    @Test("Email script attachment uses POSIX file")
    func emailScriptAttachmentFormat() {
        let script = AppleScriptService.emailScript(
            subject: "Sub",
            content: "Body",
            recipientName: "Name",
            recipientAddress: "a@b.com",
            ccAddress: "c@b.com",
            screenshotPaths: ["/path/to/file.png"]
        )
        #expect(script.contains("POSIX file \"/path/to/file.png\""))
        #expect(script.contains("attachment"))
    }
}
