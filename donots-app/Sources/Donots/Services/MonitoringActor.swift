import Foundation

actor MonitoringActor {
    // Settings snapshot
    private let captureX: Int
    private let captureY: Int
    private let screenshotWidth: Int
    private let screenshotHeight: Int
    private let numScreenshots: Int
    private let screenshotDelay: Double
    private let initialDelay: Double
    private let screenshotDirectory: String
    private let emailRecipient: String
    private let recipientName: String
    private let emailSubject: String
    private let emailContent: String
    private let sendingAccount: String
    private let captureOptions: CaptureOptions

    private let onLog: @Sendable (String, LogLevel) -> Void

    private var lastNotificationState = false
    private var pollingTask: Task<Void, Never>?

    init(
        captureX: Int,
        captureY: Int,
        screenshotWidth: Int,
        screenshotHeight: Int,
        numScreenshots: Int,
        screenshotDelay: Double,
        initialDelay: Double,
        screenshotDirectory: String,
        emailRecipient: String,
        recipientName: String,
        emailSubject: String,
        emailContent: String,
        sendingAccount: String,
        captureOptions: CaptureOptions = CaptureOptions(),
        onLog: @escaping @Sendable (String, LogLevel) -> Void
    ) {
        self.captureX = captureX
        self.captureY = captureY
        self.screenshotWidth = screenshotWidth
        self.screenshotHeight = screenshotHeight
        self.numScreenshots = numScreenshots
        self.screenshotDelay = screenshotDelay
        self.initialDelay = initialDelay
        self.screenshotDirectory = screenshotDirectory
        self.emailRecipient = emailRecipient
        self.recipientName = recipientName
        self.emailSubject = emailSubject
        self.emailContent = emailContent
        self.sendingAccount = sendingAccount
        self.captureOptions = captureOptions
        self.onLog = onLog
    }

    func start() {
        guard pollingTask == nil else { return }
        lastNotificationState = false
        onLog("Monitoring started", .success)
        onLog("Capture region: x=\(captureX), y=\(captureY), w=\(screenshotWidth), h=\(screenshotHeight)", .info)
        onLog("Capture format: \(captureOptions.imageFormat.displayName), scale: \(Int(captureOptions.scaleDownFactor * 100))%", .info)
        onLog("Polling every 1 second...", .info)

        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.pollOnce()
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    func stop() {
        pollingTask?.cancel()
        pollingTask = nil
        onLog("Monitoring stopped", .info)
    }

    private func pollOnce() async {
        let detected = await MainActor.run {
            var errorInfo: NSDictionary?
            let script = NSAppleScript(source: AppleScriptService.notificationCheckScript)
            let result = script?.executeAndReturnError(&errorInfo)
            if errorInfo != nil { return false }
            return result?.stringValue == "notification_detected"
        }

        // Edge detection: only act on rising edge
        if detected && !lastNotificationState {
            onLog("Notification detected!", .success)
            await handleNotification()
        }
        lastNotificationState = detected
    }

    private func handleNotification() async {
        if initialDelay > 0 {
            onLog("Waiting \(initialDelay)s initial delay...", .info)
            try? await Task.sleep(for: .seconds(initialDelay))
        }

        var screenshots: [String] = []

        for i in 1...numScreenshots {
            guard !Task.isCancelled else { return }
            do {
                let path = try await ScreenshotService.captureRegion(
                    x: captureX, y: captureY,
                    width: screenshotWidth, height: screenshotHeight,
                    directory: screenshotDirectory,
                    index: i,
                    options: captureOptions
                )
                screenshots.append(path)
                onLog("Screenshot \(i)/\(numScreenshots) saved: \(path)", .success)
            } catch {
                onLog("Screenshot \(i) failed: \(error.localizedDescription)", .error)
            }

            if i < numScreenshots && screenshotDelay > 0 {
                try? await Task.sleep(for: .seconds(screenshotDelay))
            }
        }

        guard !screenshots.isEmpty else {
            onLog("No screenshots captured, skipping email", .warning)
            return
        }

        // Send email
        let screenshotsCopy = screenshots
        onLog("Sending email with \(screenshotsCopy.count) attachment(s)...", .info)
        do {
            try await MainActor.run {
                var errorInfo: NSDictionary?
                let scriptSource = AppleScriptService.emailScript(
                    subject: emailSubject,
                    content: emailContent,
                    recipientName: recipientName,
                    recipientAddress: emailRecipient,
                    ccAddress: sendingAccount,
                    screenshotPaths: screenshotsCopy
                )
                let script = NSAppleScript(source: scriptSource)
                script?.executeAndReturnError(&errorInfo)
                if let errorInfo {
                    let msg = errorInfo[NSAppleScript.errorMessage] as? String ?? "Unknown error"
                    throw AppleScriptError.executionFailed(msg)
                }
            }
            onLog("Email sent to \(emailRecipient)", .success)
        } catch {
            onLog("Email failed: \(error.localizedDescription)", .error)
        }
    }
}
