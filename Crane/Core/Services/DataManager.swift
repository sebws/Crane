import SwiftUI

@Observable class DataManager: DataManaging {
    private(set) var currentVal: DataPoint?
    private(set) var maxVal: DataPoint?
    private(set) var rawDataPoints: [DataPoint] = []
    private(set) var interpolatedDataPoints: [DataPoint] = []

    private var displayLink: DisplayLink?

    init() {
        resetDataPoints()
        setupDisplayLink()
    }

    func addDataPoint(_ val: Double) {
        let newDataPoint = DataPoint(val)
        currentVal = newDataPoint
        maxVal = max(maxVal ?? DataPoint(0), newDataPoint)

        rawDataPoints.append(newDataPoint)
        if rawDataPoints.count > AppConstants.UI.chartDataPoints {
            rawDataPoints.removeFirst()
        }
    }

    private func updateInterpolatedPoints() {
        let lastPoint = rawDataPoints.last

        interpolatedDataPoints.append(DataPoint(lastPoint?.value ?? 0))
        if interpolatedDataPoints.count > AppConstants.UI.chartDataPoints {
            interpolatedDataPoints.removeFirst()
        }
    }

    func clearData() {
        currentVal = nil
        clearMaxVal()
        rawDataPoints.removeAll()
        resetDataPoints()
    }

    func clearMaxVal() {
        maxVal = nil
    }

    private func setupDisplayLink() {
        displayLink = DisplayLink { [weak self] in
            self?.updateInterpolatedPoints()
        }
    }

    private func resetDataPoints() {
        interpolatedDataPoints = (0..<AppConstants.UI.chartDataPoints).map { _ in DataPoint(0) }
    }
}

// MARK: - DisplayLink Helper
private class DisplayLink {
    private var displayLink: CADisplayLink?
    private let callback: () -> Void

    init(callback: @escaping () -> Void) {
        self.callback = callback
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func update() {
        callback()
    }

    deinit {
        displayLink?.invalidate()
    }
}
