import SwiftData

extension Repeater {
    static var preview: Repeater {
        let repeater = Repeater(name: "Sample Repeater")
        repeater.rest = Rest(minutes: 1, seconds: 30)
        repeater.addAction(
            name: "Dead Hangs",
            repetitions: 3,
            weight: 0,
            duration: 10
        )
        repeater.addAction(
            name: "Weighted Pulls",
            repetitions: 5,
            weight: 20,
            duration: 3
        )
        return repeater
    }
} 
