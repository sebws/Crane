import SwiftData

extension ModelContainer {
    static var sample: () throws -> ModelContainer = {
        let schema = Schema([Repeater.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: schema, configurations: [configuration])
        Task { @MainActor in
            Repeater.insertSampleData(modelContext: container.mainContext)
        }
        return container
    }
}
