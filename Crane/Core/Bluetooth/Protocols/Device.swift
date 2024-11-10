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
}

enum ConnectionState {
    case disconnected
    case connecting
    case connected
    case disconnecting
    case discoveringServices
}
