import Foundation

protocol DeviceManaging {
    var selectedDevice: (any Device)? { get }

    func selectDevice(_ deviceType: DeviceType) -> Void
}
