import Combine
import Foundation

let frequency = 0.01

@Observable class LiveViewModel {
    var data: [Double] = []
    var maxVal = 0.0
    var currentVal = 0.0
    private var timer: AnyCancellable?

    func startMocking() {
        timer = Timer.publish(every: frequency, on: .main, in: .common).autoconnect().sink { _ in
            let newVal: Double = 5 + Double.random(in: -2 ... 2)
            self.maxVal = max(newVal, self.maxVal)
            self.currentVal = newVal
            self.data.append(newVal)
            if self.data.count >= 100 {
                self.data.removeFirst()
            }
        }
    }

    func stopMocking() {
        timer?.cancel()
    }

    func clearData() {
        data = []
        maxVal = 0.0
        currentVal = 0.0
    }

    deinit {
        timer?.cancel()
    }
}
