import CoreGraphics
import Testing
@testable import TextSniperCore

struct RecognizedTextFormatterTests {
    @Test
    func sortsLinesFromTopToBottomAndLeftToRight() {
        let formatter = RecognizedTextFormatter()
        let lines = [
            RecognizedTextLine(text: "world", boundingBox: CGRect(x: 0.4, y: 0.7, width: 0.2, height: 0.1)),
            RecognizedTextLine(text: "second", boundingBox: CGRect(x: 0.1, y: 0.4, width: 0.3, height: 0.1)),
            RecognizedTextLine(text: "hello", boundingBox: CGRect(x: 0.1, y: 0.7, width: 0.2, height: 0.1))
        ]

        #expect(formatter.format(lines) == "hello\nworld\nsecond")
    }

    @Test
    func trimsEmptyRecognizedLines() {
        let formatter = RecognizedTextFormatter()
        let lines = [
            RecognizedTextLine(text: "  ", boundingBox: CGRect(x: 0, y: 0.8, width: 0.2, height: 0.1)),
            RecognizedTextLine(text: " value ", boundingBox: CGRect(x: 0, y: 0.4, width: 0.2, height: 0.1))
        ]

        #expect(formatter.format(lines) == "value")
    }
}
