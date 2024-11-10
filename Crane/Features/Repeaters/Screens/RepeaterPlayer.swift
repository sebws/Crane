import SwiftData
import SwiftUI

struct RepeaterPlayer: View {
    let repeater: Repeater
    @Environment(\.dataManager) private var dataManager
    @Bindable var stateMachine: RepeaterPlayerStateMachine
    private let allRanges: [TargetRange]

    init(repeater: Repeater) {
        self.repeater = repeater
        self.stateMachine = RepeaterPlayerStateMachine(repeater: repeater)

        // Calculate all target ranges
        var ranges: [TargetRange] = []
        var currentTime: TimeInterval = AppConstants.Defaults.countdownDuration

        for action in repeater.actions {
            for _ in 0..<action.repetitions {
                // Add action range
                ranges.append(
                    TargetRange(
                        weight: action.weight,
                        startTime: currentTime,
                        endTime: currentTime + action.duration
                    ))
                currentTime += action.duration

                // Add rest period (if not last rep of last action)
                if !(action === repeater.actions.last
                    && ranges.count == action.repetitions)
                {
                    currentTime += repeater.rest.totalSeconds
                }
            }
            currentTime += repeater.rest.totalSeconds
        }
        self.allRanges = ranges
    }

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Text(
                    String(
                        format: "%.2f kg", dataManager.currentVal?.value ?? 0)
                )
                .font(.system(size: 48))
                .bold()

            }
            .frame(height: 60)

            ZStack {
                switch stateMachine.state {
                case .idle:
                    Text("Ready to start")
                        .font(.title)

                case .countdown(let timeLeft):
                    VStack(spacing: 10) {
                        Text("Get Ready!")
                            .font(.title)
                        Text(String(format: "%.1f", timeLeft))
                            .font(.system(size: 48, weight: .bold))
                            .monospacedDigit()
                        ProgressView(
                            value: (AppConstants.Defaults.countdownDuration
                                - timeLeft),
                            total: AppConstants.Defaults.countdownDuration
                        )
                    }

                case .action(let actionIndex, let repsLeft, let timeLeft),
                    .rest(let timeLeft, let actionIndex, let repsLeft):
                    let action = repeater.actions[actionIndex]

                    VStack(spacing: 10) {
                        if case .action = stateMachine.state {
                            Text(action.name)
                                .font(.title)
                        } else {
                            Text("Rest")
                                .font(.title)
                            if repsLeft == 0,
                                actionIndex + 1 < repeater.actions.count
                            {
                                Text(
                                    "Next: \(repeater.actions[actionIndex + 1].name)"
                                )
                                .foregroundStyle(.secondary)
                            }
                        }

                        VStack(spacing: 8) {
                            let progressValue =
                                if case .action = stateMachine.state {
                                    Double(action.repetitions - repsLeft)
                                        + (1 - timeLeft / action.duration)
                                } else {
                                    Double(action.repetitions - repsLeft)
                                }

                            ProgressView(
                                value: progressValue,
                                total: Double(action.repetitions)
                            ) {
                                Text(
                                    "\(action.repetitions - repsLeft)/\(action.repetitions)"
                                )
                                .monospacedDigit()
                                    + Text(" repetitions")
                            }
                            .progressViewStyle(.linear)

                            ProgressView(
                                value: Double(actionIndex),
                                total: Double(repeater.actions.count)
                            ) {
                                Text("\(actionIndex)/\(repeater.actions.count)")
                                    .monospacedDigit()
                                    + Text(" actions")
                            }
                            .progressViewStyle(.linear)
                            .animation(.easeInOut, value: actionIndex)
                        }

                        Text("\(String(format: "%.1f", timeLeft))s")
                            .font(.system(size: 48, weight: .bold))
                            .monospacedDigit()
                    }

                case .completed:
                    Text("Workout Complete!")
                        .font(.title)
                }
            }
            .frame(height: 200)

            TargetRangeChart(
                allRanges: allRanges,
                elapsedTime: stateMachine.elapsedTime
            )
            .frame(height: 200)

            Spacer()

            HStack {
                switch stateMachine.state {
                case .idle:
                    Button("Start") { stateMachine.start() }
                        .buttonStyle(.borderedProminent)

                case .countdown, .action, .rest:
                    Button("Stop") { stateMachine.stop() }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    Button(action: { stateMachine.toggle() }) {
                        Image(
                            systemName: stateMachine.isPaused
                                ? "play.fill" : "pause.fill")
                    }
                    .buttonStyle(.bordered)

                case .completed:
                    Button("Restart") {
                        stateMachine.stop()
                        stateMachine.start()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .frame(height: 44)
            .padding()
        }
        .padding()
        .navigationTitle("Playing Repeater")
        .navigationBarTitleDisplayMode(.inline)
    }
}
