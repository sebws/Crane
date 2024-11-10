import Foundation

struct DataPoint: Comparable, Equatable, Identifiable {
    let id = UUID()
    let value: Double
    let timestamp: TimeInterval

    init(_ value: Double) {
        self.value = value
        self.timestamp = Date().timeIntervalSinceReferenceDate
    }

    static func < (lhs: DataPoint, rhs: DataPoint) -> Bool {
        lhs.value < rhs.value
    }

    static func == (lhs: DataPoint, rhs: DataPoint) -> Bool {
        lhs.value == rhs.value && lhs.timestamp == rhs.timestamp
    }
}

protocol DataManaging {
    var rawDataPoints: [DataPoint] { get }
    var interpolatedDataPoints: [DataPoint] { get }
    var maxVal: DataPoint? { get }
    var currentVal: DataPoint? { get }

    func addDataPoint(_ dataPoint: Double)
    func clearData()
    func clearMaxVal()
}
