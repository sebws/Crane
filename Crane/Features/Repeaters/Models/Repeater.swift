import Foundation
import SwiftData

@Model
final class Repeater {
    var name: String
    var rest: Rest
    @Relationship(deleteRule: .cascade) var actions: [Action]
    var listOrder: Int

    init(name: String = "") {
        self.name = name
        self.rest = Rest()
        self.actions = []
        self.listOrder = Date.timeIntervalSinceReferenceDate.hashValue
    }

    func clear() {
        name = ""
        rest = Rest()
        actions.removeAll()
        listOrder = Date.timeIntervalSinceReferenceDate.hashValue
    }

    func addAction(
        name: String = "", repetitions: Int = 1, weight: Double = 0, duration: TimeInterval = 5
    ) -> Action {
        let action = Action(
            name: name, repetitions: repetitions, weight: weight, duration: duration, repeater: self
        )
        actions.append(action)
        return action
    }
}
