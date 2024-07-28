import Charts
import SwiftUI

struct LiveChart: View {
    var model = ScaleDataViewModel.model
    let dataManager = DataManager.model
    let displayLinkManager = DisplayLinkManager.model

    var body: some View {
        Chart {
            ForEach(Array(dataManager.interpolatedDataPoints.enumerated()), id: \.0) { index, magnitude in
                LineMark(
                    x: .value("Time", index),
                    y: .value("Kg", magnitude)
                ).interpolationMethod(.catmullRom)
            }

            RuleMark(y: .value("Max", model.maxVal)).foregroundStyle(.gray).lineStyle(StrokeStyle(dash: [5]))
        }
        .chartXAxis(.hidden)
        .chartYAxisLabel {
            Text("kg")
        }.onChange(of: displayLinkManager.needsUpdate) {
            displayLinkManager.needsUpdate = false
        }
    }
}

#Preview {
    LiveChart()
}
