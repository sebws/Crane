import CoreBluetoothMock
import Foundation

extension CBMServiceMock {
    static let WHC06Service = CBMServiceMock(
        type: .whc06.service, primary: true)
}

private class WHC06CBMPeripheralSpecDelegate: CBMPeripheralSpecDelegate {
    private var timer: Timer?

    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { timer in
            let config = CBMAdvertisementConfig(
                data: [
                    CBMAdvertisementDataLocalNameKey: "IF_B7",
                    CBMAdvertisementDataServiceUUIDsKey: [],
                    CBMAdvertisementDataIsConnectable: true as NSNumber,
                    CBMAdvertisementDataManufacturerDataKey: Data(
                        [
                            0x00, 0x01, 0x02, 0x03, 0x11, 0x2a, 0xc0, 0x19,
                            0x11, 0x23, 0xe1, 0x01,
                        ] +
                        withUnsafeBytes(
                            of: Int16(Double.random(in: 0...20) * 100).bigEndian
                        ) { Array($0) } +
                        [0x01, 0xf4, 0x01, 0xd4, 0xcb]
                    ),
                ],
                interval: 0.25,
                isAdvertisingWhenConnected: true
            )

            WHC06Mock.simulateAdvertisementChange([config])
        }
    }
}

let WHC06Mock = CBMPeripheralSpec.simulatePeripheral()
    .advertising(
        advertisementData: [
            CBMAdvertisementDataLocalNameKey: "IF_B7",
            CBMAdvertisementDataServiceUUIDsKey: [],
            CBMAdvertisementDataIsConnectable: true as NSNumber,
            CBMAdvertisementDataManufacturerDataKey: Data([
                0x00, 0x01, 0x02, 0x03, 0x11, 0x2a, 0xc0, 0x19,
                0x11, 0x23, 0xe1, 0x01,
                0x00, 0x00,  // Initial weight bytes
                0x01, 0xf4, 0x01, 0xd4, 0xcb,
            ]),
        ],
        withInterval: 0.1,
        alsoWhenConnected: true
    )
    .connectable(
        name: "IF_B7",
        services: [],
        delegate: WHC06CBMPeripheralSpecDelegate(),
        connectionInterval: 1
    )
    .build()
