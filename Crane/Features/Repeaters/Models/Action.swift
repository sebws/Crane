import Foundation
import SwiftData

@Model
class Action: Hashable {
    var repetitions: Int
    var name: String
    var weight: Double

    init(repetitions: Int, name: String, weight: Double) {
        self.repetitions = repetitions
        self.name = name
        self.weight = weight
    }
}
