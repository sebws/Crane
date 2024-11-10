import CoreBluetoothMock
import Foundation

@Observable class Progressor: NSObject, Device {
    let type: DeviceType = .progressor
    private(set) var state: ConnectionState = .disconnected
    private(set) var name: String?
    private(set) var selectedPeripheral: CBPeripheral?
    private(set) var discoveredDeviceOptions: [CBPeripheral] = []

    private let dataManager: DataManaging
    private var centralManager: CBCentralManager?
    private var controlCharacteristic: CBCharacteristic?
    private var dataCharacteristic: CBCharacteristic?

    required init(dataManager: DataManaging) {
        self.dataManager = dataManager
        super.init()
        self.centralManager = CBCentralManagerFactory.instance(
            delegate: self, queue: .main, forceMock: false)
    }

    func startScanning() {
        print("Scanning for Progressor")
        guard centralManager?.state == .poweredOn else {
            print(
                "Cannot start scanning: Bluetooth is not powered on", centralManager,
                centralManager?.state)
            return
        }

        centralManager?.scanForPeripherals(withServices: [.progressor.controlService])
    }

    func stopScanning() {
        centralManager?.stopScan()
    }

    func connect(to peripheral: CBPeripheral) {
        self.state = .connecting
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

// MARK: - CBCentralManagerDelegate
extension Progressor: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        } else {
            disconnect()
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        if !discoveredDeviceOptions.contains(where: { $0.identifier == peripheral.identifier }) {
            print("Progressor adding discovered device: \(peripheral.name ?? "unnamed")")
            discoveredDeviceOptions.append(peripheral)
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        state = .discoveringServices
        peripheral.delegate = self
        peripheral.discoverServices([.progressor.controlService])
    }

    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        state = .disconnected
        selectedPeripheral = nil
    }
}

// MARK: - CBPeripheralDelegate
extension Progressor: CBPeripheralDelegate {
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error?
    ) {
        guard let services = peripheral.services else { return }

        for service in services {
            peripheral.discoverCharacteristics(
                [.progressor.controlCharacteristic, .progressor.dataCharacteristic],
                for: service
            )
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            switch characteristic.uuid {
            case .progressor.controlCharacteristic:
                controlCharacteristic = characteristic
            case .progressor.dataCharacteristic:
                dataCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            default:
                break
            }
        }

        if controlCharacteristic != nil && dataCharacteristic != nil {
            state = .connected
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        guard characteristic.uuid == .progressor.dataCharacteristic,
            let data = characteristic.value,
            data.count >= 2
        else {
            return
        }

        let weight = data.withUnsafeBytes { buffer in
            buffer.load(as: Int16.self)
        }

        let val = Double(weight) / 100.0
        dataManager.addDataPoint(val)
    }
}
