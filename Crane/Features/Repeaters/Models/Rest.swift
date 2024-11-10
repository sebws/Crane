import Foundation
import SwiftData

struct Rest: Codable {
    var minutes: Int
    var seconds: Int

    var totalSeconds: TimeInterval {
        TimeInterval(minutes * 60 + seconds)
    }

    init(minutes: Int = 1, seconds: Int = 0) {
        self.minutes = minutes
        self.seconds = seconds
    }
} 
