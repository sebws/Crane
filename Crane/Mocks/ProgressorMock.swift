import CoreBluetoothMock
import Foundation

private let controlServiceUUID = "7e4e1701-1ea6-40c9-9dcc-13d34ffead57"
private let controlCharacteristicUUID = "7e4e1703-1ea6-40c9-9dcc-13d34ffead57"
private let dataCharacteristicUUID = "7e4e1702-1ea6-40c9-9dcc-13d34ffead57"

extension CBMUUID {
    static let controlService = CBMUUID(string: controlServiceUUID)
    static let controlCharacteristic = CBMUUID(
        string: controlCharacteristicUUID)
    static let dataCharacteristic = CBMUUID(string: dataCharacteristicUUID)
}

extension CBMCharacteristicMock {
    static let controlCharacteristic = CBMCharacteristicMock(
        type: .controlCharacteristic, properties: [.write],
        descriptors: CBMClientCharacteristicConfigurationDescriptorMock())

    static let dataCharacteristic = CBMCharacteristicMock(
        type: .dataCharacteristic, properties: [.notify],
        descriptors: CBMClientCharacteristicConfigurationDescriptorMock())
}

extension CBMServiceMock {
    static let progressorService = CBMServiceMock(
        type: .controlService, primary: true,
        characteristics: .dataCharacteristic, .controlCharacteristic)
}

extension Float32 {
    var bytes: [UInt8] {
        withUnsafeBytes(of: self, Array.init)
    }
}

extension UInt32 {
    var bytes: [UInt8] {
        withUnsafeBytes(of: self, Array.init)
    }
}

private class ProgressorCBMPeripheralSpecDelegate: CBMPeripheralSpecDelegate {
    var t: UInt32 = 0
    var measuring = false
    var notifying = false
    private var timer: Timer?

    func peripheral(
        _ peripheral: CBMPeripheralSpec,
        didReceiveSetNotifyRequest enabled: Bool,
        for characteristic: CBMCharacteristicMock
    ) -> Result<Void, any Error> {
        guard
            characteristic.uuid.uuidString.caseInsensitiveCompare(
                dataCharacteristicUUID) == .orderedSame
        else {
            print(
                "Mock received notify request for incorrect characteristic \(characteristic.uuid)"
            )
            return .failure(NSError())
        }
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {
                [self] _ in
                if self.measuring {
                    peripheral.simulateValueUpdate(
                        Data(
                            [0x01, 0x08] + Float32.random(in: 0...30).bytes
                                + self.t.bytes),
                        for: characteristic)
                }
            }
        }
        notifying = enabled

        return .success(())
    }

    func peripheral(
        _ peripheral: CBMPeripheralSpec,
        didReceiveWriteCommandFor characteristic: CBMCharacteristic,
        data: Data
    ) {
        guard
            characteristic.uuid.uuidString.caseInsensitiveCompare(
                controlCharacteristicUUID) == .orderedSame
        else {
            print(
                "Received write command for wrong characteristic \(characteristic.uuid.uuidString)"
            )
            return
        }
        switch data[0] {
        case 0x65:
            measuring = true
            t = 0
            break

        case 0x66:
            measuring = false
            t = 0
            break

        default: break
        }
    }
}

let progressorMock = CBMPeripheralSpec.simulatePeripheral().advertising(
    advertisementData: [
        CBMAdvertisementDataLocalNameKey: "Progressor",
        CBMAdvertisementDataServiceUUIDsKey: [CBMUUID.controlService],
        CBMAdvertisementDataIsConnectable: true as NSNumber,
    ],
    withInterval: 0.250,
    alsoWhenConnected: false
).connectable(
    name: "Progressor", services: [.progressorService],
    delegate: ProgressorCBMPeripheralSpecDelegate(),
    connectionInterval: 1
).build()
