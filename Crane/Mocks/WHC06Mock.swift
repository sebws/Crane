import CoreBluetoothMock
import Foundation

extension CBMServiceMock {
    static let WHC06Service = CBMServiceMock(
        type: .controlService, primary: true)
}

private class WHC06CBMPeripheralSpecDelegate: CBMPeripheralSpecDelegate {
    private var timer: Timer?

    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) {
            timer in
            let config: CBMAdvertisementConfig = CBMAdvertisementConfig(
                data: [
                    CBMAdvertisementDataLocalNameKey: "WH-C06",
                    CBMAdvertisementDataServiceUUIDsKey: [],
                    CBMAdvertisementDataIsConnectable: true as NSNumber,
                    CBMAdvertisementDataManufacturerDataKey: Data([
                        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                        0x00, 0x00, 0x00, 0x01, UInt8.random(in: 0...255),
                    ]),
                ], interval: 0.25, isAdvertisingWhenConnected: true)

            WHC06Mock.simulateAdvertisementChange([config])
        }
    }
}

let WHC06Mock = CBMPeripheralSpec.simulatePeripheral().advertising(
    advertisementData: [
        CBMAdvertisementDataLocalNameKey: "WH-C06",
        CBMAdvertisementDataServiceUUIDsKey: [],
        CBMAdvertisementDataIsConnectable: true as NSNumber,
        CBMAdvertisementDataManufacturerDataKey: Data([
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x01, 0x0f,
        ]),
    ],
    withInterval: 0.1,
    alsoWhenConnected: true
).connectable(
    name: "WH-C06", services: [],
    delegate: WHC06CBMPeripheralSpecDelegate(),
    connectionInterval: 1
).build()
