import Foundation
import SwiftUI

extension Int {
    /// Returns nil when value is 0, useful for @AppStorage defaults that return 0 when unset.
    var nonZero: Int? { self == 0 ? nil : self }
}

@Observable
@MainActor
final class MonitorViewModel {
    var isMonitoring = false
    var logEntries: [LogEntry] = []

    private var monitoringActor: MonitoringActor?

    func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        logEntries.append(LogEntry("Starting monitoring...", level: .info))

        let defaults = UserDefaults.standard
        let captureOptions = CaptureOptions.fromDefaults()

        let actor = MonitoringActor(
            captureX: defaults.integer(forKey: "captureX"),
            captureY: defaults.integer(forKey: "captureY").nonZero ?? 30,
            screenshotWidth: defaults.integer(forKey: "screenshotWidth").nonZero ?? 400,
            screenshotHeight: defaults.integer(forKey: "screenshotHeight").nonZero ?? 100,
            numScreenshots: defaults.integer(forKey: "numScreenshots").nonZero ?? 1,
            screenshotDelay: Double(defaults.integer(forKey: "screenshotDelay")),
            initialDelay: Double(defaults.integer(forKey: "initialDelay")),
            screenshotDirectory: defaults.string(forKey: "screenshotDirectory") ?? "~/Library/Application Support/Donots/Screenshots",
            emailRecipient: defaults.string(forKey: "emailRecipient") ?? "",
            recipientName: defaults.string(forKey: "recipientName") ?? "",
            emailSubject: defaults.string(forKey: "emailSubject") ?? "New Notification",
            emailContent: defaults.string(forKey: "emailContent") ?? "new notification",
            sendingAccount: defaults.string(forKey: "sendingAccount") ?? "",
            captureOptions: captureOptions,
            onLog: { [weak self] message, level in
                Task { @MainActor [weak self] in
                    self?.logEntries.append(LogEntry(message, level: level))
                }
            }
        )
        monitoringActor = actor

        Task {
            await actor.start()
        }
    }

    func stopMonitoring() {
        guard isMonitoring else { return }
        Task {
            await monitoringActor?.stop()
            monitoringActor = nil
        }
        isMonitoring = false
    }

    func clearLog() {
        logEntries.removeAll()
    }
}
