import SwiftUI

@main
struct DonotsApp: App {
    @State private var viewModel = MonitorViewModel()
    @AppStorage("menuBarEnabled") private var menuBarEnabled = false

    var body: some Scene {
        Window("Donots", id: "main") {
            ContentView()
                .environment(viewModel)
        }
        .defaultSize(width: 400, height: 700)

        Window("Activity Log", id: "activity-log") {
            ActivityLogView()
                .environment(viewModel)
        }
        .defaultSize(width: 600, height: 400)

        Settings {
            TabView {
                GeneralSettingsView()
                    .tabItem {
                        Label("General", systemImage: "gear")
                    }

                CaptureSettingsView()
                    .tabItem {
                        Label("Capture", systemImage: "camera")
                    }

                PermissionsSettingsView()
                    .tabItem {
                        Label("Permissions", systemImage: "lock.shield")
                    }
            }
            .frame(minWidth: 500, minHeight: 450)
        }

        MenuBarExtra(isInserted: $menuBarEnabled) {
            MenuBarContentView()
                .environment(viewModel)
        } label: {
            Image(systemName: viewModel.isMonitoring ? "bell.badge.fill" : "bell.slash")
        }
    }
}

private struct MenuBarContentView: View {
    @Environment(MonitorViewModel.self) private var viewModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        if viewModel.isMonitoring {
            Button("Stop Monitoring") {
                viewModel.stopMonitoring()
            }
        } else {
            Button("Start Monitoring") {
                viewModel.startMonitoring()
            }
        }

        Divider()

        Button("Open Donots") {
            openWindow(id: "main")
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
        .keyboardShortcut("o")

        Button("Activity Log") {
            openWindow(id: "activity-log")
            NSApplication.shared.activate(ignoringOtherApps: true)
        }

        Divider()

        Button("Quit Donots") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
