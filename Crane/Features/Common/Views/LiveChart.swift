import Charts
import SwiftUI

struct LiveChart: View {
    let dataManager = DataManager.model

    var body: some View {
        Chart {
            ForEach(
                Array(dataManager.interpolatedDataPoints.enumerated()), id: \.0
            ) { index, magnitude in
                LineMark(
                    x: .value("Time", index),
                    y: .value("Kg", magnitude)
                ).interpolationMethod(.linear)
            }

            RuleMark(y: .value("Max", dataManager.maxVal)).foregroundStyle(
                .gray
            ).lineStyle(StrokeStyle(dash: [5]))
        }
        .chartXScale(domain: [0,420])
        .chartXAxis(.hidden)
        .chartYAxisLabel {
            Text("kg")
        }.task {
            for await _ in CADisplayLink.timestamps() {
                dataManager.interpolateDataPoints()
            }
        }
    }
}

#Preview {
    LiveChart()
}
