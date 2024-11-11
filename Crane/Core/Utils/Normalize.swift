import Foundation

extension Double {
    /// Normalizes a value from one range to another
    /// - Parameters:
    ///   - sourceRange: The range to normalize from (min, max)
    ///   - targetRange: The range to normalize to (min, max)
    /// - Returns: The normalized value in the target range
    func normalized(from sourceRange: ClosedRange<Double>, to targetRange: ClosedRange<Double>) -> Double {
        let oldRange = sourceRange.upperBound - sourceRange.lowerBound
        let newRange = targetRange.upperBound - targetRange.lowerBound
        return (((self - sourceRange.lowerBound) * newRange) / oldRange) + targetRange.lowerBound
    }
}
