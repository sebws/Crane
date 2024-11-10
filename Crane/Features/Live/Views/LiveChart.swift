import Charts
import SwiftUI

struct LiveChart: View {
    @Environment(\.dataManager) private var dataManager

    var body: some View {
        Chart {
            // Max value line
            if let maxVal = dataManager.maxVal?.value, maxVal > 0 {
                RuleMark(y: .value("Max", maxVal))
                    .foregroundStyle(.red)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
            }

            // Live data line
            ForEach(
                Array(dataManager.interpolatedDataPoints.enumerated()), id: \.0
            ) { index, point in
                LineMark(
                    x: .value("Time", index),
                    y: .value("Weight", point.value)
                )
            }
        }
        .overlay(alignment: .topTrailing) {
            if let maxVal = dataManager.maxVal?.value, maxVal > 0 {
                Button {
                    dataManager.clearMaxVal()
                } label: {
                    Text(String(format: "Max: %.2f kg", maxVal))
                        .font(.caption)
                        .padding(6)
                        .background(.red.opacity(0.1))
                        .cornerRadius(6)
                }
                .padding(8)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxisLabel {
            Text("kg")
        }
    }
}

#Preview {
    let services = ServiceContainer()

    LiveChart()
        .environment(\.dataManager, services.dataManager)
}
