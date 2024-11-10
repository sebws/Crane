import Charts
import SwiftUI

struct TargetRange: Equatable, Identifiable {
    let id = UUID()
    let weight: Double
    let startTime: TimeInterval
    let endTime: TimeInterval
}

struct TargetRangeChart: View {
    @Environment(\.dataManager) private var dataManager
    let allRanges: [TargetRange]
    let elapsedTime: TimeInterval
    let tolerance: Double = 2.0
    let visibleDuration: TimeInterval = 20.0

    private var visibleRanges: [TargetRange] {
        allRanges.filter { range in
            range.endTime > elapsedTime
                && range.startTime < elapsedTime + visibleDuration
        }
    }

    func normalize(value: TimeInterval, min: TimeInterval, max: TimeInterval, newMin: TimeInterval, newMax: TimeInterval) -> Double {
        let oldRange = max - min
        let newRange = newMax - newMin
        return (((value - min) * newRange) / oldRange) + newMin
    }

    var body: some View {
        Chart {
            // Target ranges - shift them to start from right edge
            ForEach(visibleRanges) { target in
                let xStart =
                    (target.startTime - elapsedTime) / visibleDuration + 0.5
                let xEnd =
                    (target.endTime - elapsedTime) / visibleDuration + 0.5

                RectangleMark(
                    xStart: .value("Start", xStart),
                    xEnd: .value("End", xEnd),
                    yStart: .value("Lower", target.weight - tolerance),
                    yEnd: .value("Upper", target.weight + tolerance)
                )
                .foregroundStyle(.green.opacity(0.2))

                RuleMark(
                    xStart: .value("Start", xStart),
                    xEnd: .value("End", xEnd),
                    y: .value("Target", target.weight)
                )
                .foregroundStyle(.green)
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
            }

            // Live data - normalize to 0-0.5 using current time window
            ForEach(Array(dataManager.interpolatedDataPoints.enumerated()), id: \.0) { _, point in
                let now = Date.timeIntervalSinceReferenceDate
                let oldMin = now - visibleDuration * 0.5
                let oldMax = now
                let newMax = 0.5
                let newMin = 0.0
                let x = normalize(value: point.timestamp, min: oldMin, max: oldMax, newMin: newMin, newMax: newMax)
                LineMark(
                    x: .value("Time", x),
                    y: .value("Weight", point.value)
                )
            }
            .foregroundStyle(.blue)
        }
        .chartXScale(domain: 0...1)
    }
}
