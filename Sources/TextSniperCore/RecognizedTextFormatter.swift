import CoreGraphics
import Foundation

public struct RecognizedTextLine: Sendable, Equatable {
    public let text: String
    public let boundingBox: CGRect

    public init(text: String, boundingBox: CGRect) {
        self.text = text
        self.boundingBox = boundingBox
    }
}

public struct RecognizedTextFormatter: Sendable {
    private let sameLineThreshold: CGFloat

    public init(sameLineThreshold: CGFloat = 0.025) {
        self.sameLineThreshold = sameLineThreshold
    }

    public func format(_ lines: [RecognizedTextLine]) -> String {
        let trimmedLines = lines
            .map { RecognizedTextLine(text: $0.text.trimmingCharacters(in: .whitespacesAndNewlines), boundingBox: $0.boundingBox) }
            .filter { !$0.text.isEmpty }

        let sorted = trimmedLines.sorted { lhs, rhs in
            let verticalDistance = abs(lhs.boundingBox.midY - rhs.boundingBox.midY)

            if verticalDistance <= sameLineThreshold {
                return lhs.boundingBox.minX < rhs.boundingBox.minX
            }

            return lhs.boundingBox.midY > rhs.boundingBox.midY
        }

        return sorted
            .map(\.text)
            .joined(separator: "\n")
    }
}
