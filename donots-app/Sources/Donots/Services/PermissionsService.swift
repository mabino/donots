import Foundation
import AppKit
import ScreenCaptureKit

enum PermissionStatus: String, Sendable {
    case granted = "Granted"
    case denied = "Not Granted"
    case unknown = "Unknown"
}

@Observable
@MainActor
final class PermissionsService {
    var accessibilityStatus: PermissionStatus = .unknown
    var screenRecordingStatus: PermissionStatus = .unknown
    var mailAutomationStatus: PermissionStatus = .unknown

    init() {
        refreshAll()
    }

    // MARK: - Refresh

    func refreshAll() {
        checkAccessibility()
        checkScreenRecording()
        checkMailAutomation()
    }

    // MARK: - Accessibility

    func checkAccessibility() {
        let trusted = AXIsProcessTrusted()
        accessibilityStatus = trusted ? .granted : .denied
    }

    func requestAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
        // Poll briefly for the user to grant, then refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.checkAccessibility()
        }
    }

    // MARK: - Screen Recording

    func checkScreenRecording() {
        // CGPreflightScreenCaptureAccess() caches its result for the lifetime of the process,
        // so it won't detect a grant made while the app is running.
        // SCShareableContent reflects live permission state on macOS 14+.
        Task { @MainActor in
            do {
                _ = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)
                screenRecordingStatus = .granted
            } catch {
                screenRecordingStatus = .denied
            }
        }
    }

    func requestScreenRecording() {
        // CGRequestScreenCaptureAccess() shows the system prompt if the user hasn't decided yet.
        // It returns true only if access was already granted (does not wait for the dialog).
        // After the dialog, the user must restart the app for the grant to take effect.
        let alreadyGranted = CGRequestScreenCaptureAccess()
        screenRecordingStatus = alreadyGranted ? .granted : .denied
    }

    // MARK: - Mail Automation (Apple Events)

    func checkMailAutomation() {
        // Try a harmless AppleScript to check if we have permission to target Mail.
        // If denied, the system will have previously shown a prompt or we get an error.
        let script = NSAppleScript(source: """
        tell application "System Events"
            return name of application process "Mail"
        end tell
        """)
        var errorInfo: NSDictionary?
        script?.executeAndReturnError(&errorInfo)
        if let errorInfo,
           let errorNumber = errorInfo[NSAppleScript.errorNumber] as? Int,
           errorNumber == -1743 {
            // -1743 = not permitted to send Apple Events
            mailAutomationStatus = .denied
        } else if errorInfo != nil {
            // Other error (Mail not running, etc.) - doesn't mean denied
            mailAutomationStatus = .unknown
        } else {
            mailAutomationStatus = .granted
        }
    }

    func requestMailAutomation() {
        // Trigger the system prompt by sending a benign Apple Event to Mail.
        // This will show the macOS permission dialog if not previously authorized.
        let script = NSAppleScript(source: """
        tell application "Mail"
            get name
        end tell
        """)
        var errorInfo: NSDictionary?
        script?.executeAndReturnError(&errorInfo)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.checkMailAutomation()
        }
    }

    // MARK: - Open System Settings

    func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    func openScreenRecordingSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }

    func openAutomationSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation") {
            NSWorkspace.shared.open(url)
        }
    }
}
