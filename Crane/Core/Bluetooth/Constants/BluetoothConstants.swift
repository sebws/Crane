import CoreBluetoothMock
import Foundation

// MARK: - Progressor Constants
struct ProgressorConstants {
  static let controlService = CBUUID(string: "7e4e1701-1ea6-40c9-9dcc-13d34ffead57")
  static let controlCharacteristic = CBUUID(string: "7e4e1703-1ea6-40c9-9dcc-13d34ffead57")
  static let dataCharacteristic = CBUUID(string: "7e4e1702-1ea6-40c9-9dcc-13d34ffead57")
}

// MARK: - Device Constants
extension CBUUID {
  struct Progressor {
    let controlService = CBUUID(string: "7e4e1701-1ea6-40c9-9dcc-13d34ffead57")
    let controlCharacteristic = CBUUID(string: "7e4e1703-1ea6-40c9-9dcc-13d34ffead57")
    let dataCharacteristic = CBUUID(string: "7e4e1702-1ea6-40c9-9dcc-13d34ffead57")
  }

  struct WHC06 {
    let service = CBUUID(string: "FFE0")
    let characteristic = CBUUID(string: "FFE1")
  }

  static let progressor = Progressor()
  static let whc06 = WHC06()
}

// MARK: - Mock Configurations
extension CBMCharacteristicMock {
  static let progressorControlCharacteristic = CBMCharacteristicMock(
    type: .progressor.controlCharacteristic,
    properties: [.write],
    descriptors: CBMClientCharacteristicConfigurationDescriptorMock()
  )

  static let progressorDataCharacteristic = CBMCharacteristicMock(
    type: .progressor.dataCharacteristic,
    properties: [.notify],
    descriptors: CBMClientCharacteristicConfigurationDescriptorMock()
  )
}

extension CBMServiceMock {
  static let progressorService = CBMServiceMock(
    type: .progressor.controlService,
    primary: true,
    characteristics: .progressorDataCharacteristic, .progressorControlCharacteristic
  )
}
