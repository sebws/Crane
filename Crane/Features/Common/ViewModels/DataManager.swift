import SwiftUI

@Observable
class DataManager {
    var realDataPoints: [Double] = []
    var interpolatedDataPoints: [Double] = Array(repeating: 0, count: 420)
    var maxVal: Double = 0
    var currentVal: Double?

    private init() {}

    static let model = DataManager()

    func addDataPoint(_ dataPoint: Double) {
        maxVal = max(maxVal, dataPoint)
        realDataPoints.append(dataPoint)
        currentVal = dataPoint
        interpolateDataPoints()
    }

    func interpolateDataPoints() {
        guard let currentVal else { return }
        let recentDataPoint = interpolatedDataPoints.last ?? currentVal
        let smoothVal = 0.5 * currentVal + (1 - 0.5) * recentDataPoint
        interpolatedDataPoints.append(smoothVal)
        if interpolatedDataPoints.count > 7 * 60 {
            interpolatedDataPoints.removeFirst()
        }
    }

    func clearData() {
        currentVal = nil
        maxVal = 0
        realDataPoints = []
        interpolatedDataPoints = []
    }
}
