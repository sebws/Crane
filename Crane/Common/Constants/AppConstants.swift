import SwiftUI

enum AppConstants {
    static let appName = "Crane"

    enum Bluetooth {
        static let scanTimeout: TimeInterval = 10
        static let connectionTimeout: TimeInterval = 5
    }

    enum UI {
        static let animationDuration: Double = 0.3
        static let cornerRadius: CGFloat = 8
        static let chartDataPoints: Int = 420
    }

    enum Defaults {
        static let restDuration: TimeInterval = 60
        static let actionDuration: TimeInterval = 7
        static let countdownDuration: TimeInterval = 5
    }
}
