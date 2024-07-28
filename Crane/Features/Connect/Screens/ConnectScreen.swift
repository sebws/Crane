import SwiftUI

struct ConnectScreen: View {
    var model = ScaleDataViewModel.model

    var body: some View {
        VStack {
            List {
                Section(header: Text("Connected")) {
                    ForEach(model.discoveredPeripherals.filter { $0.identifier == model.connectedPeripheralUUID }, id: \.identifier) { peripheral in
                        HStack {
                            Text(peripheral.name ?? "Unknown")
                        }
                    }
                }
                Section {
                    ForEach(model.discoveredPeripherals, id: \.identifier) { peripheral in
                        HStack {
                            Text(peripheral.name ?? "Unknown")
                            Spacer()
                            Button("Connect", action: {
                                model.connect(to: peripheral)
                            })
                        }
                    }
                }
            }
        }.navigationTitle("Connect Scale")
    }
}

#Preview {
    NavigationStack {
        ConnectScreen()
    }
}
