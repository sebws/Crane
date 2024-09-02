import SwiftData
import CoreBluetoothMock
import SwiftUI

@main
struct CraneApp: App {
    @State private var deviceManager = DeviceManager.model
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Repeater.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        CBMCentralManagerMock.simulatePeripherals([progressorMock, WHC06Mock])
        CBMCentralManagerMock.simulateInitialState(.poweredOn)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
