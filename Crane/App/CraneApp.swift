import CoreBluetoothMock
import SwiftData
import SwiftUI

@main
struct CraneApp: App {
    let services = ServiceContainer()

    init() {
        // Setup mock Bluetooth devices for development
        CBMCentralManagerMock.simulatePeripherals([progressorMock, WHC06Mock])
        CBMCentralManagerMock.simulateInitialState(.poweredOn)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.deviceManager, services.deviceManager)
                .environment(\.dataManager, services.dataManager)
        }
        .modelContainer(
            for: [Repeater.self, Action.self],
            isAutosaveEnabled: true,
            isUndoEnabled: true)
    }
}
