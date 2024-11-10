enum DeviceType: CaseIterable {
    case progressor
    case whc06

    var name: String {
        switch self {
        case .progressor:
            return "Progressor"
        case .whc06:
            return "WHC-06"
        }
    }

    var icon: String {
        switch self {
        case .progressor:
            return "dumbbell.fill"
        case .whc06:
            return "sensor.fill"
        }
    }
}
