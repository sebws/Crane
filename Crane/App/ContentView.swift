import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.deviceManager) private var deviceManager
    @Environment(\.dataManager) private var dataManager

    var body: some View {
        TabView {
            NavigationStack {
                LiveScreen()
            }
            .tabItem {
                Label("Live", systemImage: "chart.xyaxis.line")
            }

            NavigationStack {
                DeviceList()
                    .navigationDestination(for: DeviceType.self) { deviceType in
                        ConnectScreen(deviceType: deviceType)
                    }
            }
            .tabItem {
                Label(
                    "Connect",
                    systemImage: "antenna.radiowaves.left.and.right")
            }

            NavigationStack {
                RepeaterList()
            }
            .tabItem {
                Label("Repeaters", systemImage: "repeat")
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Repeater.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let services = ServiceContainer()

    ContentView()
        .modelContainer(container)
        .environment(\.deviceManager, services.deviceManager)
        .environment(\.dataManager, services.dataManager)
}
