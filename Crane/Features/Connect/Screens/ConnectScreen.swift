import SwiftUI

struct ConnectScreen: View {
    var deviceType: DeviceType

    @State var device: Device?

    var body: some View {
        VStack {
            List {
                if let device = device {
                    Section(header: Text("Found devices")) {
                        ForEach(
                            device.discoveredDeviceOptions,
                            id: \.identifier
                        ) {
                            peripheral in
                            HStack {
                                Text(peripheral.name ?? "Unknown")
                                Spacer()
                                if peripheral.identifier
                                    == device.selectedPeripheral?.identifier
                                {
                                    switch device.state {
                                    case .connected:
                                        Image(systemName: "checkmark")
                                    case .connecting, .discoveringServices:
                                        ProgressView()
                                    case .disconnected:
                                        Button(
                                            "Connect",
                                            action: {
                                                DeviceManager.model
                                                    .selectedDevice?
                                                    .connect(
                                                        to: peripheral)
                                            })
                                    case .disconnecting:
                                        Image(systemName: "escape")
                                    @unknown default:
                                        Image(
                                            systemName:
                                                "questionmark.app.dashed")
                                    }
                                } else {
                                    Button(
                                        "Connect",
                                        action: {
                                            DeviceManager.model.selectedDevice?
                                                .connect(
                                                    to: peripheral)
                                        })
                                }

                            }
                        }
                    }
                }
            }
        }.navigationTitle("Connect \(deviceType.rawValue)")
            .onAppear {
                self.device = DeviceManager.model.selectDevice(deviceType)
            }
    }
}

#Preview {
    NavigationStack {
        ConnectScreen(deviceType: .progressor)
    }
}
