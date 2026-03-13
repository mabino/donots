import SwiftUI

struct ActivityLogView: View {
    @Environment(MonitorViewModel.self) private var viewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Activity Log")
                    .font(.headline)
                Spacer()
                Button {
                    viewModel.clearLog()
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.borderless)
                .help("Clear Log")
                .disabled(viewModel.logEntries.isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            ScrollViewReader { proxy in
                List(viewModel.logEntries) { entry in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(colorForLevel(entry.level))
                            .frame(width: 8, height: 8)
                            .padding(.top, 4)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(DateFormatting.logTimestamp(entry.timestamp))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(entry.message)
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                    .id(entry.id)
                }
                .listStyle(.plain)
                .onChange(of: viewModel.logEntries.count) {
                    if let last = viewModel.logEntries.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }

    private func colorForLevel(_ level: LogLevel) -> Color {
        switch level {
        case .info: .blue
        case .warning: .orange
        case .error: .red
        case .success: .green
        }
    }
}
