import CoreBluetoothMock
import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var deviceManager = DeviceManager.model

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        NavigationLink(destination: DeviceList()) {
                            Text("Connect Scale")
                        }
                    }

                    Section {
                        NavigationLink(destination: LiveScreen()) {
                            Text("Live Data")
                        }

                        NavigationLink(destination: RepeaterMenuScreen()) {
                            Text("Repeaters")
                        }
                    }
                }
            }.navigationTitle("Crane")
        }
    }
}

#Preview {
    ContentView()
}
