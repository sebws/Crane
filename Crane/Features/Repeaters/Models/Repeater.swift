import Foundation
import SwiftData

@Model
final class Repeater {
    @Attribute(.unique) var id: UUID
    var name: String
    var timestamp: Date
    var actions: [Action]

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.timestamp = Date()
        self.actions = []
    }
}
