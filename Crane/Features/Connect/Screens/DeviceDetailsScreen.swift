import SwiftUI

struct DeviceDetailsScreen: View {
    @Environment(\.deviceManager) private var deviceManager

    var body: some View {
        List {
            Section("Device Info") {
                LabeledContent("Name", value: deviceManager.selectedDevice?.name ?? "Unknown")
                LabeledContent("Type", value: deviceManager.selectedDevice?.type.name ?? "")
                LabeledContent(
                    "Status", value: deviceManager.selectedDevice?.state.rawValue ?? "")
            }

            if let device = deviceManager.selectedDevice {
                device.controlsView()
            }

            Section {
                Button(role: .destructive) {
                    deviceManager.selectedDevice?.disconnect()
                } label: {
                    Text("Disconnect")
                }
            }
        }
        .navigationTitle("Connected Device")
    }
}
