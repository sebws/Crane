import CoreBluetoothMock
import Foundation

private let WEIGHT_OFFSET = 12
private let STABLE_OFFSET = 16

@Observable class WHC06: NSObject, Device {
    let type: DeviceType = .whc06
    private(set) var state: ConnectionState = .disconnected
    private(set) var name: String?
    private(set) var selectedPeripheral: CBPeripheral?
    private(set) var discoveredDeviceOptions: [CBPeripheral] = []

    private let dataManager: DataManaging
    private var centralManager: CBCentralManager?

    required init(dataManager: DataManaging) {
        self.dataManager = dataManager
        super.init()
        self.centralManager = CBCentralManagerFactory.instance(
            delegate: self, queue: .main, forceMock: false)
    }

    func startScanning() {
        if centralManager?.state == .poweredOn {
            centralManager?.scanForPeripherals(
                withServices: nil,
                options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
            )
        }
    }

    func stopScanning() {
        centralManager?.stopScan()
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

extension WHC06: CBCentralManagerDelegate {
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
        // Check if this is our selected peripheral
        if let selectedPeripheral = selectedPeripheral,
            peripheral.identifier == selectedPeripheral.identifier,
            let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey]
                as? Data
        {
            guard manufacturerData.count >= WEIGHT_OFFSET + 2 else { return }

            if state == .connecting {
                state = .connected
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
        // Otherwise, check if this is a discoverable device
        else if selectedPeripheral == nil,
            !discoveredDeviceOptions.contains(where: { $0.identifier == peripheral.identifier }),
            peripheral.name == "IF_B7"
        {
            discoveredDeviceOptions.append(peripheral)
        }
    }
}
