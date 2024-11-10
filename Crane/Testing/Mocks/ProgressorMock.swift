import CoreBluetoothMock
import Foundation

let progressorMock = CBMPeripheralSpec.simulatePeripheral()
    .advertising(
        advertisementData: [
            CBMAdvertisementDataLocalNameKey: "Progressor",
            CBMAdvertisementDataServiceUUIDsKey: [CBUUID.progressor.controlService],
            CBMAdvertisementDataIsConnectable: true as NSNumber,
        ],
        withInterval: 0.250,
        alsoWhenConnected: false
    )
    .connectable(
        name: "Progressor",
        services: [.progressorService],
        delegate: ProgressorCBMPeripheralSpecDelegate(),
        connectionInterval: 1
    )
    .build()

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
        guard characteristic.uuid == .progressor.dataCharacteristic else {
            print("Mock received notify request for incorrect characteristic \(characteristic.uuid)")
            return .failure(NSError())
        }

        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] _ in
                if self.measuring {
                    peripheral.simulateValueUpdate(
                        Data([0x01, 0x08] + Float32.random(in: 0...30).bytes + self.t.bytes),
                        for: characteristic
                    )
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
        guard characteristic.uuid == .progressor.controlCharacteristic else {
            print("Received write command for wrong characteristic \(characteristic.uuid)")
            return
        }

        switch data[0] {
        case 0x65:
            measuring = true
            t = 0
        case 0x66:
            measuring = false
            t = 0
        default:
            break
        }
    }
}

// Helper extensions
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
