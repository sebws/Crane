import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        NavigationLink(destination: ConnectScreen()) {
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
