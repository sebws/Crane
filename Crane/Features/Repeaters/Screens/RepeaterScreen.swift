import SwiftData
import SwiftUI

struct RepeaterScreen: View {
    let repeater: Repeater

    var body: some View {
        VStack {
            Text("ID: \(repeater.id)")
            Text("ID: \(repeater.name)")
        }
    }
}

#Preview {
    let repeater = Repeater(name: "Example")

    return RepeaterScreen(repeater: repeater).modelContainer(for: Repeater.self, inMemory: true)
}
