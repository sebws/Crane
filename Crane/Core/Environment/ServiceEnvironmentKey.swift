import SwiftUI

private struct DeviceManagerKey: EnvironmentKey {
    static let defaultValue: DeviceManaging = DeviceManager(dataManager: DataManager())
}

private struct DataManagerKey: EnvironmentKey {
    static let defaultValue: DataManaging = DataManager()
}

extension EnvironmentValues {
    var deviceManager: DeviceManaging {
        get { self[DeviceManagerKey.self] }
        set { self[DeviceManagerKey.self] = newValue }
    }

    var dataManager: DataManaging {
        get { self[DataManagerKey.self] }
        set { self[DataManagerKey.self] = newValue }
    }
} 
