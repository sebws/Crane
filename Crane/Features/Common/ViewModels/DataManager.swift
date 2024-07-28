import SwiftUI

@Observable
class DataManager {
    var realDataPoints: [Double] = []
    var interpolatedDataPoints: [Double] = []
    var maxVal: Double = 0
    private var lastRealDataPoint: Double?
    
    private init() {}
    
    static let model = DataManager()
    
    func addDataPoint(_ dataPoint: Double) {
        maxVal = max(maxVal, dataPoint)
        realDataPoints.append(dataPoint)
        lastRealDataPoint = dataPoint
        interpolateDataPoints()
    }

    func interpolateDataPoints() {
        guard let lastRealDataPoint else { return }
        interpolatedDataPoints.append(lastRealDataPoint)
        if interpolatedDataPoints.count > 7 * 60 {
            interpolatedDataPoints.removeFirst()
        }
    }
    
    func clearData() {
        lastRealDataPoint = nil
        maxVal = 0
        realDataPoints = []
        interpolatedDataPoints = []
    }
}
