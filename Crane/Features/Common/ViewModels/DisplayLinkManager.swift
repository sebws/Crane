import SwiftUI

@Observable
class DisplayLinkManager {
    var needsUpdate = false
    private var displayLink: CADisplayLink?

    private init() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.preferredFramesPerSecond = 60
        displayLink?.add(to: .main, forMode: .default)
    }

    static let model = DisplayLinkManager()

    deinit {
        displayLink?.invalidate()
    }

    @objc private func update() {
        DataManager.model.interpolateDataPoints()
        needsUpdate = true
    }
}
