import CoreBluetoothMock
import SwiftUI

protocol Device: AnyObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var type: DeviceType { get }
    var state: ConnectionState { get }
    var name: String? { get }
    var selectedPeripheral: CBPeripheral? { get }
    var discoveredDeviceOptions: [CBPeripheral] { get }

    func startScanning()
    func stopScanning()
    func connect(to peripheral: CBPeripheral)
    func disconnect()
    func startMeasurement()
    func stopMeasurement()

    // View lifecycle events
    func onLiveDataAppearing()
    func onLiveDataDisappearing()

    @ViewBuilder
    func controlsView() -> AnyView
}

enum ConnectionState: String {
    case disconnected = "Disconnected"
    case connecting = "Connecting"
    case connected = "Connected"
    case disconnecting = "Disconnecting"
    case discoveringServices = "Discovering services"
}

// Default implementation
extension Device {
    func onLiveDataAppearing() {}
    func onLiveDataDisappearing() {}
    func startMeasurement() {}
    func stopMeasurement() {}
    var name: String? {
        get { return selectedPeripheral?.name }
    }

    @ViewBuilder
    func controlsView() -> AnyView {
        AnyView(EmptyView())
    }
}
