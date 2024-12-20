import CoreBluetooth
import SwiftUI

struct ConnectScreen: View {
    let deviceType: DeviceType
    @Environment(\.deviceManager) private var deviceManager
    @State private var connectingPeripheral: CBPeripheral?

    var body: some View {
        List {
            Section {
                ForEach(
                    deviceManager.selectedDevice?.discoveredDeviceOptions ?? [],
                    id: \.identifier
                ) { peripheral in
                    Button {
                        connectingPeripheral = peripheral
                        deviceManager.selectedDevice?.connect(to: peripheral)
                    } label: {
                        HStack {
                            Text(peripheral.name ?? "Unknown Device")
                            Spacer()
                            if (deviceManager.selectedDevice?.selectedPeripheral?
                                .identifier == peripheral.identifier) {
                                switch (deviceManager.selectedDevice?.state) {
                                case .connected:
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                case .disconnecting, .disconnected:
                                    EmptyView()
                                default:
                                    ProgressView()
                                }
                            }
                        }
                    }
                    .disabled(
                        deviceManager.selectedDevice?.selectedPeripheral?.identifier
                            == peripheral.identifier)
                }
            } header: {
                Text("Available Devices")
            }
        }
        .navigationTitle(
            "Connect \(deviceType == .progressor ? "Progressor" : "WH-C06")"
        )
        .onAppear {
            deviceManager.selectDevice(deviceType)
        }
        .onDisappear {
            // Only stop scanning if we haven't connected to a device
            if deviceManager.selectedDevice?.state != .connected {
                deviceManager.selectedDevice?.stopScanning()
            }
        }
    }
}

#Preview {
    let services = ServiceContainer()

    NavigationStack {
        ConnectScreen(deviceType: .progressor)
            .environment(\.deviceManager, services.deviceManager)
    }
}
