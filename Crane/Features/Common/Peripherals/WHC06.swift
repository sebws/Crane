import Foundation

let WEIGHT_OFFSET = 12
let STABLE_OFFSET = 16

@Observable class WHC06: Device {
    let dataManager: DataManager
    let type: DeviceType = .whc06

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
extension WHC06: CBCentralManagerDelegate {
    func centralManager(
        _ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any], rssi RSSI: NSNumber
    ) {
        guard peripheral.identifier == self.selectedPeripheral?.identifier,
            let manufacturerData = advertisementData[
                CBAdvertisementDataManufacturerDataKey] as? Data
        else {
            if self.selectedPeripheral == nil,
                !self.discoveredDeviceOptions.contains(where: {
                    $0.identifier == peripheral.identifier
                }), peripheral.name == "IF_B7"
            {
                self.discoveredDeviceOptions.append(peripheral)
            }
            return
        }

        guard manufacturerData.count >= WEIGHT_OFFSET + 2 else {
            return
        }

        if self.state == .connecting {
            self.state = .connected
        }

        let weightRange = WEIGHT_OFFSET..<WEIGHT_OFFSET + 2
        let weightBytes = manufacturerData.subdata(in: weightRange)

        let weight = weightBytes.withUnsafeBytes { buffer in
            let value = buffer.load(as: Int16.self)
            return Double(Int16(bigEndian: value))
        }

        let val = (weight / 100)
        self.dataManager.addDataPoint(val)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        } else {
            disconnect()
        }
    }

    func startScanning() {
        centralManager?.scanForPeripherals(
            withServices: nil,
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }

    func connect(to peripheral: CBPeripheral) {
        self.state = .connecting
        self.selectedPeripheral = peripheral
    }

    func disconnect() {
        guard selectedPeripheral != nil else { return }

        state = .disconnecting

        self.selectedPeripheral = nil
    }
}
