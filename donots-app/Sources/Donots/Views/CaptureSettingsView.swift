import SwiftUI

private let defaultScreenshotDirectory = "~/Library/Application Support/Donots/Screenshots"

struct CaptureSettingsView: View {
    // Capture behavior
    @AppStorage("numScreenshots") private var numScreenshots = 1
    @AppStorage("screenshotDelay") private var screenshotDelay = 0
    @AppStorage("initialDelay") private var initialDelay = 0

    // Compression
    @AppStorage("imageFormat") private var imageFormat = "png"
    @AppStorage("jpegQuality") private var jpegQuality = 0.8
    @AppStorage("scaleDownFactor") private var scaleDownFactor = 1.0

    // Storage
    @AppStorage("screenshotDirectory") private var screenshotDirectory = defaultScreenshotDirectory

    var body: some View {
        Form {
            Section("Capture Behavior") {
                Stepper(
                    "Screenshots per Notification: \(numScreenshots)",
                    value: $numScreenshots, in: 1...20
                )
                Stepper(
                    "Delay Between: \(screenshotDelay)s",
                    value: $screenshotDelay, in: 0...60
                )
                Stepper(
                    "Initial Delay: \(initialDelay)s",
                    value: $initialDelay, in: 0...60
                )
            }

            Section("Compression") {
                Picker("Image Format", selection: $imageFormat) {
                    ForEach(ImageFormat.allCases, id: \.rawValue) { format in
                        Text(format.displayName).tag(format.rawValue)
                    }
                }
                .pickerStyle(.segmented)

                if imageFormat == "jpg" {
                    LabeledContent("JPEG Quality") {
                        HStack(spacing: 8) {
                            Slider(value: $jpegQuality, in: 0.1...1.0, step: 0.05)
                            Text("\(Int(jpegQuality * 100))%")
                                .monospacedDigit()
                                .frame(width: 36, alignment: .trailing)
                        }
                    }
                }

                LabeledContent("Scale") {
                    HStack(spacing: 8) {
                        Slider(value: $scaleDownFactor, in: 0.25...1.0, step: 0.05)
                        Text("\(Int(scaleDownFactor * 100))%")
                            .monospacedDigit()
                            .frame(width: 36, alignment: .trailing)
                    }
                }
            }

            Section("Storage") {
                LabeledContent("Directory") {
                    Text(abbreviatePath(screenshotDirectory))
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .textSelection(.enabled)
                        .help((screenshotDirectory as NSString).expandingTildeInPath)
                }
                Button("Reveal in Finder") {
                    let path = (screenshotDirectory as NSString).expandingTildeInPath
                    try? FileManager.default.createDirectory(
                        atPath: path, withIntermediateDirectories: true
                    )
                    NSWorkspace.shared.open(URL(fileURLWithPath: path))
                }
                .controlSize(.small)
            }
        }
        .formStyle(.grouped)
        .frame(width: 500)
    }

    private func abbreviatePath(_ path: String) -> String {
        let expanded = (path as NSString).expandingTildeInPath
        let home = NSHomeDirectory()
        if expanded.hasPrefix(home) {
            return "~" + expanded.dropFirst(home.count)
        }
        return expanded
    }
}
