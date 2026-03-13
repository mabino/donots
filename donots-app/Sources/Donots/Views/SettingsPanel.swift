import SwiftUI

struct SettingsPanel: View {
    let isMonitoring: Bool

    // Screenshot region (absolute screen coordinates for screencapture -R x,y,w,h)
    @AppStorage("captureX") private var captureX = 0
    @AppStorage("captureY") private var captureY = 30
    @AppStorage("screenshotWidth") private var screenshotWidth = 400
    @AppStorage("screenshotHeight") private var screenshotHeight = 100

    // Email settings
    @AppStorage("emailRecipient") private var emailRecipient = ""
    @AppStorage("recipientName") private var recipientName = ""
    @AppStorage("emailSubject") private var emailSubject = "New Notification"
    @AppStorage("emailContent") private var emailContent = "new notification"
    @AppStorage("sendingAccount") private var sendingAccount = ""

    var body: some View {
        Form {
            Section("Email") {
                HStack {
                    TextField("Recipient Email", text: $emailRecipient)
                    ContactPickerButton { email, name in
                        emailRecipient = email
                        if let name, !name.isEmpty {
                            recipientName = name
                        }
                    }
                }
                TextField("Recipient Name", text: $recipientName)
                TextField("Subject", text: $emailSubject)
                TextField("Body", text: $emailContent)
                TextField("Sending Account (CC)", text: $sendingAccount)
            }

            Section("Screenshot Region") {
                LabeledContent("X") {
                    TextField("", value: $captureX, format: .number)
                        .frame(width: 80)
                        .multilineTextAlignment(.trailing)
                }
                LabeledContent("Y") {
                    TextField("", value: $captureY, format: .number)
                        .frame(width: 80)
                        .multilineTextAlignment(.trailing)
                }
                LabeledContent("Width") {
                    TextField("", value: $screenshotWidth, format: .number)
                        .frame(width: 80)
                        .multilineTextAlignment(.trailing)
                }
                LabeledContent("Height") {
                    TextField("", value: $screenshotHeight, format: .number)
                        .frame(width: 80)
                        .multilineTextAlignment(.trailing)
                }

                Button {
                    RegionSelectorCoordinator.selectRegion { rect in
                        captureX = Int(rect.minX)
                        captureY = Int(rect.minY)
                        screenshotWidth = Int(rect.width)
                        screenshotHeight = Int(rect.height)
                    }
                } label: {
                    Label("Select Region", systemImage: "crosshair")
                }
                .controlSize(.small)
            }
        }
        .formStyle(.grouped)
        .disabled(isMonitoring)
        .opacity(isMonitoring ? 0.6 : 1.0)
    }
}
