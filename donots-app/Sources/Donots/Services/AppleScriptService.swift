import Foundation
import AppKit

enum AppleScriptError: Error, LocalizedError {
    case executionFailed(String)

    var errorDescription: String? {
        switch self {
        case .executionFailed(let msg): return msg
        }
    }
}

enum AppleScriptService {
    // MARK: - Notification Check

    static let notificationCheckScript = """
    tell application "System Events"
        try
            tell process "Notification Center"
                set notificationList to every UI element of window 1
                if (count of notificationList) > 0 then
                    return "notification_detected"
                end if
            end tell
        end try
    end tell
    """

    @MainActor
    static func checkForNotifications() async -> Bool {
        let result = executeScript(notificationCheckScript)
        return result == "notification_detected"
    }

    // MARK: - Display Bounds

    static let displayBoundsScript = """
    tell application "System Events"
        set screenBounds to bounds of window of desktop
        return item 3 of screenBounds & "," & item 4 of screenBounds
    end tell
    """

    @MainActor
    static func getDisplayBounds() async -> (width: Int, height: Int) {
        let result = executeScript(displayBoundsScript)
        if let result, result.contains(",") {
            let parts = result.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            if parts.count == 2 {
                return (parts[0], parts[1])
            }
        }
        return (1280, 800) // fallback
    }

    // MARK: - Send Email

    static func emailScript(
        subject: String,
        content: String,
        recipientName: String,
        recipientAddress: String,
        ccAddress: String,
        screenshotPaths: [String]
    ) -> String {
        let attachmentBlocks = screenshotPaths.map { path in
            """
                        set attachmentPath to POSIX file "\(path)"
                        tell theMessage
                            make new attachment with properties {file name:attachmentPath} at after last paragraph
                        end tell
            """
        }.joined(separator: "\n")

        return """
        tell application "Mail"
            set theMessage to make new outgoing message with properties {visible:true}
            tell theMessage
                set subject to "\(subject)"
                set content to "\(content)"
                make new to recipient at end of to recipients with properties {name:"\(recipientName)", address:"\(recipientAddress)"}
                make new cc recipient at end of cc recipients with properties {address:"\(ccAddress)"}
        \(attachmentBlocks)
                set visible to true
                delay 1
                send
            end tell
        end tell
        """
    }

    @MainActor
    static func sendEmail(
        subject: String,
        content: String,
        recipientName: String,
        recipientAddress: String,
        ccAddress: String,
        screenshotPaths: [String]
    ) async throws {
        let script = emailScript(
            subject: subject,
            content: content,
            recipientName: recipientName,
            recipientAddress: recipientAddress,
            ccAddress: ccAddress,
            screenshotPaths: screenshotPaths
        )
        var errorInfo: NSDictionary?
        let appleScript = NSAppleScript(source: script)
        appleScript?.executeAndReturnError(&errorInfo)
        if let errorInfo {
            let msg = errorInfo[NSAppleScript.errorMessage] as? String ?? "Unknown AppleScript error"
            throw AppleScriptError.executionFailed(msg)
        }
    }

    // MARK: - Helper

    @MainActor
    private static func executeScript(_ source: String) -> String? {
        var errorInfo: NSDictionary?
        let script = NSAppleScript(source: source)
        let result = script?.executeAndReturnError(&errorInfo)
        if errorInfo != nil { return nil }
        return result?.stringValue
    }
}
