import Foundation

class ServiceContainer {
    let dataManager: DataManaging
    let deviceManager: DeviceManaging

    init() {
        let dataManager = DataManager()
        self.dataManager = dataManager
        self.deviceManager = DeviceManager(dataManager: dataManager)
    }
} 
