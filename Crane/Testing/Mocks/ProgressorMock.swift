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
        guard characteristic.uuid == CBUUID.progressor.dataCharacteristic else {
            print("Mock received notify request for incorrect characteristic \(characteristic.uuid)")
            return .failure(NSError())
        }
        print("Mock received notify request for data point characteristic")

        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] _ in
                if self.measuring {
                    // Generate weight between 0 and 3000 (0 to 30kg in 0.01kg units)
                    let weightInGrams = Int16(Float.random(in: 0...3000))

                    // Convert to little-endian byte array
                    let weightBytes = withUnsafeBytes(of: weightInGrams.littleEndian) { Array($0) }
                    let timestampBytes = withUnsafeBytes(of: t.littleEndian) { Array($0) }

                    let packet = Data([0x01, 0x08] + weightBytes + timestampBytes)

                    print("Sending weight: \(Double(weightInGrams)/100.0) kg")

                    peripheral.simulateValueUpdate(
                        packet,
                        for: characteristic
                    )
                    self.t += 1
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
        print("Mock received write command for characteristic: \(characteristic.uuid)")
        print("Expected characteristic: \(CBUUID.progressor.controlCharacteristic)")

        guard characteristic.uuid == CBUUID.progressor.controlCharacteristic else {
            print("Received write command for wrong characteristic \(characteristic.uuid)")
            return
        }

        print("Received control point command: \(data.map { String(format: "%02x", $0) }.joined())")

        switch data[0] {
        case 0x65:
            measuring = true
            t = 0
            print("Starting measurement")
        case 0x66:
            measuring = false
            t = 0
            print("Stopping measurement")
        default:
            print("Unknown command: \(data[0])")
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
