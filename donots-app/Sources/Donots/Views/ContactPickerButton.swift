import SwiftUI
import Contacts
import ContactsUI

struct ContactPickerButton: View {
    let onSelect: (_ email: String, _ name: String?) -> Void

    @State private var showPicker = false

    var body: some View {
        Button {
            showPicker = true
        } label: {
            Image(systemName: "person.crop.circle.badge.plus")
        }
        .buttonStyle(.borderless)
        .help("Pick from Contacts")
        .sheet(isPresented: $showPicker) {
            ContactPickerRepresentable(onSelect: onSelect)
                .frame(width: 400, height: 500)
        }
    }
}

private struct ContactPickerRepresentable: NSViewControllerRepresentable {
    let onSelect: (_ email: String, _ name: String?) -> Void

    func makeNSViewController(context: Context) -> ContactPickerViewController {
        ContactPickerViewController(onSelect: onSelect)
    }

    func updateNSViewController(_ nsViewController: ContactPickerViewController, context: Context) {}
}

final class ContactPickerViewController: NSViewController, CNContactPickerDelegate {
    private let onSelect: (_ email: String, _ name: String?) -> Void

    init(onSelect: @escaping (_ email: String, _ name: String?) -> Void) {
        self.onSelect = onSelect
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 500))
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        let picker = CNContactPicker()
        picker.delegate = self
        picker.showRelative(to: view.bounds, of: view, preferredEdge: .minY)
    }

    func contactPicker(_ picker: CNContactPicker, didSelect contact: CNContact) {
        guard let email = contact.emailAddresses.first?.value as String? else { return }
        let name: String?
        let fullName = [contact.givenName, contact.familyName]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        name = fullName.isEmpty ? nil : fullName
        onSelect(email, name)
        dismiss(nil)
    }

    func contactPickerDidClose(_ picker: CNContactPicker) {
        dismiss(nil)
    }
}
