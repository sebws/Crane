import CoreBluetooth
import SwiftData
import SwiftUI

let WEIGHT_OFFSET = 12
let STABLE_OFFSET = 16

extension UUID: @retroactive RawRepresentable {
    public var rawValue: String {
        uuidString
    }

    public typealias RawValue = String

    public init?(rawValue: RawValue) {
        self.init(uuidString: rawValue)
    }
}

@Observable
class ScaleDataViewModel: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var isBluetoothEnabled = false
    var discoveredPeripherals = [CBPeripheral]()
    var connectedPeripheralUUID: UUID?
    
    private let dataManager = DataManager.model

    static let model = ScaleDataViewModel()

    private var stop = false
    private var centralManager: CBCentralManager!

    override private init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .poweredOn:
                isBluetoothEnabled = true
                startScanning()
            case .poweredOff:
                isBluetoothEnabled = false
            // Alert user to turn on Bluetooth
            case .resetting: break
            // Wait for next state update and consider logging interruption of Bluetooth service
            case .unauthorized: break
            // Alert user to enable Bluetooth permission in app Settings
            case .unsupported: break
            // Alert user their device does not support Bluetooth and app will not work as expected
            case .unknown: break
            // Wait for next state update
            default: break
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if connectedPeripheralUUID == nil, peripheral.identifier != connectedPeripheralUUID, !discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            DispatchQueue.main.async {
                self.discoveredPeripherals.append(peripheral)
            }
        }

        if peripheral.identifier == connectedPeripheralUUID, let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
            let bytes = [UInt8](manufacturerData)

            let weightHigh = Int16(bytes[WEIGHT_OFFSET]) << 8
            let weightLow = Int16(bytes[WEIGHT_OFFSET + 1])
            let weight = Double(weightHigh | weightLow)
            let val = (weight / 100)
            dataManager.addDataPoint(val)
        }
    }

    func startScanning() {
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : NSNumber(value: true)])
    }

    func stopScanning() {
        centralManager.stopScan()
    }

    func connect(to peripheral: CBPeripheral) {
        connectedPeripheralUUID = peripheral.identifier
    }
}
