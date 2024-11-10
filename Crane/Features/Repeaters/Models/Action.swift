import SwiftData
import Foundation

@Model
final class Action {
    var name: String
    var repetitions: Int
    var weight: Double
    var duration: TimeInterval
    var listOrder: Int
    @Relationship(inverse: \Repeater.actions) private(set) var repeater: Repeater?

    init(
        name: String, repetitions: Int, weight: Double, duration: TimeInterval, repeater: Repeater
    ) {
        self.name = name
        self.repetitions = repetitions
        self.weight = weight
        self.duration = duration
        self.repeater = repeater
        self.listOrder = repeater.actions.count
    }
}
