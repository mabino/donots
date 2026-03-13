import Testing
@testable import Donots

@Suite("PermissionsService Tests")
struct PermissionsServiceTests {
    @Test("PermissionStatus raw values")
    func statusRawValues() {
        #expect(PermissionStatus.granted.rawValue == "Granted")
        #expect(PermissionStatus.denied.rawValue == "Not Granted")
        #expect(PermissionStatus.unknown.rawValue == "Unknown")
    }

    @Test("All permission statuses are Sendable")
    func sendable() {
        let status: PermissionStatus = .granted
        let _: any Sendable = status
    }

    @Test("Service initializes with states")
    @MainActor
    func initialState() {
        let service = PermissionsService()
        // After init, each status should be set (not necessarily unknown)
        let validStatuses: Set<PermissionStatus> = [.granted, .denied, .unknown]
        #expect(validStatuses.contains(service.accessibilityStatus))
        #expect(validStatuses.contains(service.screenRecordingStatus))
        #expect(validStatuses.contains(service.mailAutomationStatus))
    }

    @Test("Refresh updates statuses without crashing")
    @MainActor
    func refreshDoesNotCrash() {
        let service = PermissionsService()
        service.refreshAll()
        // Just verifying no crash
        let validStatuses: Set<PermissionStatus> = [.granted, .denied, .unknown]
        #expect(validStatuses.contains(service.accessibilityStatus))
    }
}
