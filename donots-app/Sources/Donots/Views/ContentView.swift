import SwiftUI

struct ContentView: View {
    @Environment(MonitorViewModel.self) private var viewModel

    var body: some View {
        VStack(spacing: 0) {
            StatusIndicatorView(
                isMonitoring: viewModel.isMonitoring,
                onStart: { viewModel.startMonitoring() },
                onStop: { viewModel.stopMonitoring() }
            )

            Divider()

            SettingsPanel(isMonitoring: viewModel.isMonitoring)
        }
    }
}
