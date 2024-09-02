import SwiftUI

enum ConnectionState {
    case disconnected
    case connecting
    case connected
    case discoveringServices
    case disconnecting
}

protocol Device: AnyObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var dataManager: DataManager { get }
    var discoveredDeviceOptions: [CBPeripheral] { get }
    var selectedPeripheral: CBPeripheral? { get }
    var state: ConnectionState { get }
    var type: DeviceType { get }

    func connect(to: CBPeripheral)
    func disconnect()

    init(dataManager: DataManager)
}
