import CoreGraphics
import TextSniperCore
import Vision

struct TextRecognitionService {
    private let formatter = RecognizedTextFormatter()

    func recognizeText(in image: CGImage) async throws -> String {
        try await Task.detached(priority: .userInitiated) {
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.automaticallyDetectsLanguage = true
            request.recognitionLanguages = ["ko-KR", "en-US"]

            let handler = VNImageRequestHandler(cgImage: image, orientation: .up, options: [:])
            try handler.perform([request])

            let lines = request.results?.compactMap { observation -> RecognizedTextLine? in
                guard let candidate = observation.topCandidates(1).first else {
                    return nil
                }

                return RecognizedTextLine(text: candidate.string, boundingBox: observation.boundingBox)
            } ?? []

            return formatter.format(lines)
        }.value
    }
}
