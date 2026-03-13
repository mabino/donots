import SwiftUI
import ServiceManagement

struct GeneralSettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("menuBarEnabled") private var menuBarEnabled = false

    @State private var showingResetConfirmation = false

    var body: some View {
        Form {
            Section("Startup") {
                Toggle("Launch Donots at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        setLaunchAtLogin(newValue)
                    }
            }

            Section("Menu Bar") {
                Toggle("Show menu bar icon", isOn: $menuBarEnabled)
                Text("When enabled, a Donots icon appears in the menu bar for quick access.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Reset") {
                Button("Reset All Settings to Defaults", role: .destructive) {
                    showingResetConfirmation = true
                }
                .alert("Reset All Settings?", isPresented: $showingResetConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Reset", role: .destructive) {
                        resetToDefaults()
                    }
                } message: {
                    Text("This will reset all settings to their default values. This action cannot be undone.")
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 500)
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            // Revert toggle if registration fails
            launchAtLogin = !enabled
        }
    }

    private func resetToDefaults() {
        let domain = Bundle.main.bundleIdentifier ?? "com.donots.app"
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()

        // Reset local state to match
        launchAtLogin = false
        menuBarEnabled = false

        // Unregister from login items
        try? SMAppService.mainApp.unregister()
    }
}
