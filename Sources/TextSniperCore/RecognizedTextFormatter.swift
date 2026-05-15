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

        return groupedRows(from: sorted)
            .map { row in
                row
                    .sorted { $0.boundingBox.minX < $1.boundingBox.minX }
                    .map(\.text)
                    .joined(separator: " ")
            }
            .joined(separator: "\n")
    }

    private func groupedRows(from sortedLines: [RecognizedTextLine]) -> [[RecognizedTextLine]] {
        var rows: [[RecognizedTextLine]] = []

        for line in sortedLines {
            guard let lastRow = rows.last else {
                rows.append([line])
                continue
            }

            let rowMidY = lastRow.map(\.boundingBox.midY).reduce(0, +) / CGFloat(lastRow.count)
            let rowHeight = lastRow.map(\.boundingBox.height).reduce(0, +) / CGFloat(lastRow.count)
            let allowedDistance = max(sameLineThreshold, max(rowHeight, line.boundingBox.height) * 0.4)

            if abs(rowMidY - line.boundingBox.midY) <= allowedDistance {
                rows[rows.count - 1].append(line)
            } else {
                rows.append([line])
            }
        }

        return rows
    }
}
