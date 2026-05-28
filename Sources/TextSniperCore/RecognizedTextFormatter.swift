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
    private let minimumSameLineOverlapRatio: CGFloat

    public init(sameLineThreshold: CGFloat = 0.012, minimumSameLineOverlapRatio: CGFloat = 0.35) {
        self.sameLineThreshold = sameLineThreshold
        self.minimumSameLineOverlapRatio = minimumSameLineOverlapRatio
    }

    public func format(_ lines: [RecognizedTextLine]) -> String {
        let trimmedLines = lines
            .map { RecognizedTextLine(text: $0.text.trimmingCharacters(in: .whitespacesAndNewlines), boundingBox: $0.boundingBox) }
            .filter { !$0.text.isEmpty }

        let sorted = trimmedLines.sorted { lhs, rhs in
            if isSameVisualRow(lhs.boundingBox, rhs.boundingBox) {
                if abs(lhs.boundingBox.minX - rhs.boundingBox.minX) <= 0.001 {
                    return lhs.boundingBox.midY > rhs.boundingBox.midY
                }

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
            let rowBox = CGRect(x: 0, y: rowMidY - rowHeight / 2, width: 1, height: rowHeight)

            if isSameVisualRow(rowBox, line.boundingBox) {
                rows[rows.count - 1].append(line)
            } else {
                rows.append([line])
            }
        }

        return rows
    }

    private func isSameVisualRow(_ lhs: CGRect, _ rhs: CGRect) -> Bool {
        guard lhs.height > 0, rhs.height > 0 else {
            return abs(lhs.midY - rhs.midY) <= sameLineThreshold
        }

        let overlap = max(0, min(lhs.maxY, rhs.maxY) - max(lhs.minY, rhs.minY))
        let minimumHeight = min(lhs.height, rhs.height)
        let overlapRatio = overlap / minimumHeight
        let centerDistance = abs(lhs.midY - rhs.midY)
        let centerLimit = max(sameLineThreshold, minimumHeight * 0.45)

        return overlapRatio >= minimumSameLineOverlapRatio && centerDistance <= centerLimit
    }
}
