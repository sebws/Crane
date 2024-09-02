import Foundation
import SwiftUI

@Observable
class DeviceManager {
    static let model = DeviceManager()
    
    var selectedDevice: Device?
    
    func selectDevice(_ deviceType: DeviceType) -> Device {
        if let selectedDevice = DeviceManager.model.selectedDevice,
            selectedDevice.type == deviceType
        {
            return selectedDevice
        }
        
        let device: Device =
            switch deviceType {
            case .progressor:
                Progressor(dataManager: DataManager.model)
            case .whc06:
                WHC06(dataManager: DataManager.model)
            }
        self.selectedDevice?.disconnect()
        self.selectedDevice = device
        return device
    }
}
