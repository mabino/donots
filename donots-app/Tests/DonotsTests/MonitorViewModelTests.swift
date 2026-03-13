import Testing
@testable import Donots

@Suite("MonitorViewModel Tests")
struct MonitorViewModelTests {
    @Test("Initial state")
    @MainActor
    func initialState() {
        let vm = MonitorViewModel()
        #expect(!vm.isMonitoring)
        #expect(vm.logEntries.isEmpty)
    }

    @Test("Start monitoring sets state")
    @MainActor
    func startSetsState() {
        let vm = MonitorViewModel()
        vm.startMonitoring()
        #expect(vm.isMonitoring)
        #expect(!vm.logEntries.isEmpty)
        vm.stopMonitoring()
    }

    @Test("Stop monitoring clears state")
    @MainActor
    func stopClearsState() {
        let vm = MonitorViewModel()
        vm.startMonitoring()
        vm.stopMonitoring()
        #expect(!vm.isMonitoring)
    }

    @Test("Double start is no-op")
    @MainActor
    func doubleStart() {
        let vm = MonitorViewModel()
        vm.startMonitoring()
        let countAfterFirst = vm.logEntries.count
        vm.startMonitoring()
        #expect(vm.logEntries.count == countAfterFirst)
        vm.stopMonitoring()
    }

    @Test("Clear log removes all entries")
    @MainActor
    func clearLog() {
        let vm = MonitorViewModel()
        vm.startMonitoring()
        #expect(!vm.logEntries.isEmpty)
        vm.clearLog()
        #expect(vm.logEntries.isEmpty)
        vm.stopMonitoring()
    }

    @Test("Int.nonZero extension")
    func nonZeroExtension() {
        #expect(0.nonZero == nil)
        #expect(1.nonZero == 1)
        #expect((-1).nonZero == -1)
        #expect(100.nonZero == 100)
    }
}
