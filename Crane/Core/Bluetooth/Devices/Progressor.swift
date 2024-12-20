import CoreBluetoothMock
import Foundation
import SwiftUI

@Observable class Progressor: NSObject, Device {
    let type: DeviceType = .progressor
    private(set) var state: ConnectionState = .disconnected
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
}

// MARK: - Device Lifecycle Events
extension Progressor {
    func onLiveDataAppearing() {
        startMeasurement()
    }

    func onLiveDataDisappearing() {
        stopMeasurement()
    }
}

// MARK: - Device Controls
extension Progressor {
    @ViewBuilder
    func controlsView() -> AnyView {
        AnyView(ProgressorControlsView(device: self))
    }

    private struct ProgressorControlsView: View {
        let device: Progressor

        var body: some View {
            Section("Controls") {
                Button {
                    device.startMeasurement()
                } label: {
                    Label("Start", systemImage: "play.circle.fill")
                }

                Button {
                    device.stopMeasurement()
                } label: {
                    Label("Stop", systemImage: "stop.circle.fill")
                }
            }
        }
    }
}

// MARK: - Private Methods
extension Progressor {
    internal func startMeasurement() {
        guard let characteristic = controlCharacteristic,
            let peripheral = selectedPeripheral
        else { return }
        let command: [UInt8] = [0x65,0x00]
        peripheral.writeValue(
            Data(command),
            for: characteristic,
            type: .withoutResponse
        )
    }

    internal func stopMeasurement() {
        guard let characteristic = controlCharacteristic,
            let peripheral = selectedPeripheral
        else { return }
        let command: [UInt8] = [0x66,0x00]
        peripheral.writeValue(
            Data(command),
            for: characteristic,
            type: .withoutResponse
        )
    }
}

// MARK: - Connection Management
extension Progressor {
    func startScanning() {
        guard centralManager?.state == .poweredOn else {
            print(
                "Cannot start scanning: Bluetooth is not powered on", centralManager,
                centralManager?.state)
            return
        }

        centralManager?.scanForPeripherals(withServices: nil)
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
            data.count >= 6
        else {
            return
        }

        // Skip type (1 byte) and length (1 byte)
        let weight = data.withUnsafeBytes { buffer in
            buffer.loadUnaligned(fromByteOffset: 2, as: Float32.self)
        }

        let val = Double(weight) / 100.0
        dataManager.addDataPoint(val)
    }
}
