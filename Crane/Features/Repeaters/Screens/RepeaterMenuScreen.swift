import SwiftData
import SwiftUI

struct RepeaterMenuScreen: View {
    @Query(sort: \Repeater.timestamp) var repeaters: [Repeater]

    var body: some View {
        List(repeaters)
            { NavigationLink($0.name, value: $0) }
            .navigationDestination(for: Repeater.self) {
                RepeaterScreen(repeater: $0)
            }.navigationTitle(Text("Repeaters")).toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: RepeaterAdderScreen()) { Image(systemName: "plus") }
                }
            }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Repeater.self, configurations: config)

    let sampleRepeaters = [
        Repeater(name: "A"),
        Repeater(name: "B"),
        Repeater(name: "C")
    ]

    sampleRepeaters.forEach { container.mainContext.insert($0) }

    return NavigationStack { RepeaterMenuScreen().modelContainer(container) }
}
