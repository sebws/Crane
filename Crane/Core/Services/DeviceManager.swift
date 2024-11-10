import Foundation
import SwiftUI

@Observable class DeviceManager: DeviceManaging {
    private let dataManager: DataManaging

    var selectedDevice: (any Device)?

    init(dataManager: DataManaging) {
        self.dataManager = dataManager
    }

    func selectDevice(_ deviceType: DeviceType) -> Void {
        if let selectedDevice = selectedDevice,
           selectedDevice.type == deviceType {
            return
        }

        let device: any Device = switch deviceType {
        case .progressor:
            Progressor(dataManager: dataManager)
        case .whc06:
            WHC06(dataManager: dataManager)
        }
        
        self.selectedDevice?.disconnect()
        self.selectedDevice = device
    }
}
