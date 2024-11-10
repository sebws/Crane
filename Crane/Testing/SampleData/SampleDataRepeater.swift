import SwiftData

extension Repeater {
    static let basic = Repeater(name: "Basic")
    static let complex = Repeater(name: "Complex")

    static func insertSampleData(modelContext: ModelContext) {
        modelContext.insert(basic)
        modelContext.insert(complex)

        // Complex repeater actions
        complex.addAction(name: "Zero 0", repetitions: 0, weight: 0, duration: 10)
        complex.addAction(name: "Zero 10", repetitions: 0, weight: 10, duration: 10)
        complex.addAction(name: "Zero 20", repetitions: 0, weight: 20, duration: 10)

        // Basic repeater actions
        basic.addAction(name: "Single 10", repetitions: 1, weight: 10, duration: 10)
        basic.addAction(name: "Double 20", repetitions: 2, weight: 20, duration: 10)
        basic.addAction(name: "Triple 10", repetitions: 3, weight: 10, duration: 10)
    }

    static func reloadSampleData(modelContext: ModelContext) {
        do {
            try modelContext.delete(model: Repeater.self)
            insertSampleData(modelContext: modelContext)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
