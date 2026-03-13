import SwiftUI

struct StatusIndicatorView: View {
    let isMonitoring: Bool
    let onStart: () -> Void
    let onStop: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isMonitoring ? "circle.fill" : "circle")
                .foregroundStyle(isMonitoring ? .green : .secondary)
                .imageScale(.small)

            Text(isMonitoring ? "Monitoring" : "Stopped")
                .font(.headline)

            Spacer()

            Button(isMonitoring ? "Stop" : "Start") {
                if isMonitoring { onStop() } else { onStart() }
            }
            .controlSize(.large)
            .buttonStyle(.bordered)
            .tint(isMonitoring ? .red : .accentColor)
        }
        .padding()
    }
}
