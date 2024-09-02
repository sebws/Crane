import Foundation
import SwiftData

private let controlCharacteristicUUID = "7e4e1703-1ea6-40c9-9dcc-13d34ffead57"
private let dataCharacteristicUUID = "7e4e1702-1ea6-40c9-9dcc-13d34ffead57"
private let characteristicIds: [CBUUID] = [
    controlCharacteristicUUID, dataCharacteristicUUID,
].map { CBUUID(string: $0) }

private let controlServiceUUID = "7e4e1701-1ea6-40c9-9dcc-13d34ffead57"
private let serviceIds: [CBUUID] = [
    CBUUID(string: controlServiceUUID)
]

private enum ResponseCode: UInt8 {
    case BatteryVoltage = 0x00
    case Measurement = 0x01
    case LowPower = 0x04

    func valueLength() -> Int {
        switch self {
        case .LowPower: return 0
        case .BatteryVoltage: return 4
        case .Measurement: return 8
        }
    }
}

private enum Command: UInt8 {
    case Tare = 0x64
    case Start = 0x65
    case Stop = 0x66
    case Shutdown = 0x6E
    case Battery = 0x6F
}

@Observable
class Progressor: Device {
    let dataManager: DataManager
    let type: DeviceType = .progressor

    private(set) var discoveredDeviceOptions: [CBPeripheral] = []

    private(set) var state: ConnectionState = .disconnected
    private(set) var name: String?
    private(set) var selectedPeripheral: CBPeripheral?

    private var controlCharacteristic: CBCharacteristic? = nil
    private var dataCharacteristic: CBCharacteristic? = nil
    private var discoveriesInProgress = 0

    private var centralManager: CBCentralManager?

    required init(dataManager: DataManager) {
        self.dataManager = dataManager
        self.centralManager = CBCentralManagerFactory.instance(
            delegate: self, queue: .main, forceMock: false)
    }

    deinit {
        disconnect()
    }
}

// MARK: Central Manager
extension Progressor: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(
        _ central: CBCentralManager
    ) {
        if central.state == .poweredOn {
            startScanning()
        } else {
            disconnect()
        }
    }

    func centralManager(
        _ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any], rssi RSSI: NSNumber
    ) {
        guard
            self.discoveredDeviceOptions.first(where: {
                $0.identifier == peripheral.identifier
            }) == nil
        else {
            return
        }

        self.discoveredDeviceOptions.append(peripheral)
    }

    func centralManager(
        _ central: CBCentralManager, didConnect peripheral: CBPeripheral
    ) {
        name = peripheral.name
        state = .discoveringServices
        peripheral.delegate = self
        peripheral.discoverServices(serviceIds)
        discoveriesInProgress += serviceIds.count
    }

    func startScanning() {
        centralManager?.scanForPeripherals(
            withServices: serviceIds)
    }

    func connect(to peripheral: CBPeripheral) {
        state = .connecting
        self.selectedPeripheral = peripheral
        centralManager?.connect(peripheral)
    }

    func disconnect() {
        guard let peripheral = selectedPeripheral else { return }
        state = .disconnecting
        centralManager?.cancelPeripheralConnection(peripheral)
        self.selectedPeripheral = nil
    }

}

// MARK: Peripheral
extension Progressor: CBPeripheralDelegate {
    func peripheral(
        _ peripheral: CBPeripheral, didDiscoverServices error: Error?
    ) {
        if let error = error {
            print("Failed to discover services: \(error.localizedDescription)")
            return
        }

        discoveriesInProgress -= 1
        guard let services = peripheral.services else {
            print("Failed to discover services, without an error")
            checkComplete()
            return
        }

        discoveriesInProgress += characteristicIds.count
        for service in services {
            peripheral.discoverCharacteristics(characteristicIds, for: service)
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService, error: Error?
    ) {
        if let error = error {
            print(
                "Failed to discover characteristics: \(error.localizedDescription)"
            )
            return
        }

        guard let characteristics = service.characteristics else {
            print("Failed to discover list of characteristics without an error")
            return
        }

        guard
            let controlCharacteristic = characteristics.first(where: {
                $0.uuid.uuidString.caseInsensitiveCompare(
                    controlCharacteristicUUID) == .orderedSame
            })
        else {
            print("Failed to find control characteristic")
            return
        }

        guard
            let dataCharacteristic = characteristics.first(where: {
                $0.uuid.uuidString.caseInsensitiveCompare(
                    dataCharacteristicUUID) == .orderedSame
            })
        else {
            print("Failed to find data characteristic")
            return
        }

        self.controlCharacteristic = controlCharacteristic
        self.dataCharacteristic = dataCharacteristic
        discoveriesInProgress -= 2

        discoveriesInProgress += 1
        peripheral.setNotifyValue(true, for: self.dataCharacteristic!)
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: (any Error)?
    ) {
        guard error == nil else {
            print(
                "Error receiving update to characteristic value: \(error!.localizedDescription)"
            )
            return
        }

        guard let data = characteristic.value else {
            print("No data received")
            return
        }

        guard let data = DataPoint(data) else {
            print("Failed to serialise data into datapoint")
            return
        }

        if case .measurement(let weight, _) = data {
            dataManager.addDataPoint(Double(weight))
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateNotificationStateFor characteristic: CBCharacteristic,
        error: (any Error)?
    ) {
        if let error = error {
            print(
                "Failed to be notified for characteristic: \(characteristic.debugDescription), with error: \(error.localizedDescription)"
            )
        }
        discoveriesInProgress -= 1

        if let control = controlCharacteristic {
            peripheral.writeValue(
                Data([0x065, 0x00]), for: control, type: .withoutResponse)
        }

        checkComplete()
    }
}

// MARK: Helpers

extension Progressor {
    private func checkComplete() {
        if discoveriesInProgress == 0 {
            state = .connected
        }
    }
}

// MARK: DataPoint
private enum DataPoint {
    case measurement(weight: Float32, at: UInt32)
    case voltage(UInt32)
    case lowPower

    init?(_ data: Data) {
        guard data.count >= 2 else {
            print("Found insufficient byte count when serialising data point")
            return nil
        }

        guard let type = ResponseCode(rawValue: data[0]) else {
            print(
                "Couldn't recognise response code when serialising data point")
            return nil
        }

        let length = data[1]
        guard length == type.valueLength() else {
            print("Data point length was of incorrect value for op code")
            return nil
        }

        switch type {
        case .Measurement:
            let weight = data.subdata(in: 2..<6).withUnsafeBytes {
                $0.load(as: Float32.self)
            }

            let timestamp = data.subdata(in: 6..<10).withUnsafeBytes {
                $0.load(as: UInt32.self)
            }

            self = .measurement(weight: weight, at: timestamp)
        case .LowPower:
            self = .lowPower
        case .BatteryVoltage:
            let voltage = data.withUnsafeBytes {
                return $0.load(fromByteOffset: 2, as: UInt32.self)
            }
            self = .voltage(voltage)
        }
    }
}
