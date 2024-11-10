import Foundation
import QuartzCore

enum RepeaterPlayerState: Equatable {
    case idle
    case countdown(timeLeft: Double)
    case action(actionIndex: Int, repetitionsLeft: Int, timeLeft: Double)
    case rest(timeLeft: Double, actionIndex: Int, repsLeft: Int)
    case completed

    func next(timeElapsed: Double, repeater: Repeater) -> RepeaterPlayerState {
        switch self {
        case .idle:
            return self

        case .countdown(let timeLeft):
            let newTime = timeLeft - timeElapsed
            return newTime > 0
                ? .countdown(timeLeft: newTime)
                : .action(
                    actionIndex: 0,
                    repetitionsLeft: repeater.actions[0].repetitions,
                    timeLeft: repeater.actions[0].duration)

        case .action(let actionIndex, let repsLeft, let timeLeft):
            let newTime = timeLeft - timeElapsed
            if newTime > 0 {
                return .action(
                    actionIndex: actionIndex, repetitionsLeft: repsLeft,
                    timeLeft: newTime)
            }
            if repsLeft > 1 {
                return .rest(
                    timeLeft: repeater.rest.totalSeconds,
                    actionIndex: actionIndex,
                    repsLeft: repsLeft - 1)
            }
            let nextIndex = actionIndex + 1
            if nextIndex < repeater.actions.count {
                return .rest(
                    timeLeft: repeater.rest.totalSeconds,
                    actionIndex: nextIndex,
                    repsLeft: repeater.actions[nextIndex].repetitions)
            }
            return .completed

        case .rest(let timeLeft, let actionIndex, let repsLeft):
            let newTime = timeLeft - timeElapsed
            if newTime > 0 {
                return .rest(
                    timeLeft: newTime, actionIndex: actionIndex,
                    repsLeft: repsLeft)
            }
            if repsLeft > 0 {
                let action = repeater.actions[actionIndex]
                return .action(
                    actionIndex: actionIndex, repetitionsLeft: repsLeft,
                    timeLeft: action.duration)
            }
            let nextIndex = actionIndex + 1
            guard nextIndex < repeater.actions.count else { return .completed }
            let nextAction = repeater.actions[nextIndex]
            return .action(
                actionIndex: nextIndex,
                repetitionsLeft: nextAction.repetitions,
                timeLeft: nextAction.duration)

        case .completed:
            return self
        }
    }
}

@Observable class RepeaterPlayerStateMachine {
    var state: RepeaterPlayerState = .idle
    private(set) var elapsedTime: TimeInterval = 0
    var isPaused: Bool = false
    private let repeater: Repeater
    private var displayLink: CADisplayLink?
    private var lastUpdateTime: TimeInterval = 0

    init(repeater: Repeater) {
        self.repeater = repeater
    }

    func start() {
        guard case .idle = state else { return }
        state = .countdown(timeLeft: AppConstants.Defaults.countdownDuration)
        lastUpdateTime = CACurrentMediaTime()
        startDisplayLink()
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        state = .idle
        isPaused = false
        elapsedTime = 0
    }

    func toggle() {
        isPaused.toggle()
        if isPaused {
            displayLink?.isPaused = true
        } else {
            lastUpdateTime = CACurrentMediaTime()
            displayLink?.isPaused = false
        }
    }

    private func startDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .current, forMode: .common)
    }

    @objc private func tick() {
        guard !isPaused else { return }

        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        elapsedTime += deltaTime
        state = state.next(timeElapsed: deltaTime, repeater: repeater)

        if case .completed = state {
            displayLink?.invalidate()
            displayLink = nil
        }
    }
}
