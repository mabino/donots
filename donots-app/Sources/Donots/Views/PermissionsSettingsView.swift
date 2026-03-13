import SwiftUI

struct PermissionsSettingsView: View {
    @State private var permissions = PermissionsService()

    var body: some View {
        Form {
            Section {
                Text("Donots requires these permissions to monitor notifications, capture screenshots, and send emails via Apple Mail.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Section("Accessibility") {
                PermissionRow(
                    title: "Accessibility",
                    description: "Required to detect notifications in Notification Center.",
                    status: permissions.accessibilityStatus,
                    onRequest: { permissions.requestAccessibility() },
                    onOpenSettings: { permissions.openAccessibilitySettings() }
                )
            }

            Section("Screen Recording") {
                PermissionRow(
                    title: "Screen Recording",
                    description: "Required to capture screenshots of notifications.",
                    status: permissions.screenRecordingStatus,
                    onRequest: { permissions.requestScreenRecording() },
                    onOpenSettings: { permissions.openScreenRecordingSettings() }
                )
            }

            Section("Mail Automation") {
                PermissionRow(
                    title: "Apple Mail Automation",
                    description: "Required to send notification emails via Apple Mail.",
                    status: permissions.mailAutomationStatus,
                    onRequest: { permissions.requestMailAutomation() },
                    onOpenSettings: { permissions.openAutomationSettings() }
                )
            }

        }
        .formStyle(.grouped)
        .frame(width: 500)
        .task {
            while !Task.isCancelled {
                permissions.refreshAll()
                try? await Task.sleep(for: .seconds(3))
            }
        }
    }
}

private struct PermissionRow: View {
    let title: String
    let description: String
    let status: PermissionStatus
    let onRequest: () -> Void
    let onOpenSettings: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                statusIndicator
                Text(title)
                    .font(.headline)
                Spacer()
                Text(status.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(statusColor)
            }

            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                if status != .granted {
                    Button("Request Permission") {
                        onRequest()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }

                Button("Open System Settings") {
                    onOpenSettings()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var statusIndicator: some View {
        Circle()
            .fill(statusColor)
            .frame(width: 10, height: 10)
    }

    private var statusColor: Color {
        switch status {
        case .granted: .green
        case .denied: .red
        case .unknown: .orange
        }
    }
}
