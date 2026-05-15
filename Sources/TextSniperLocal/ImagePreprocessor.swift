import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins

struct ImagePreprocessor {
    private let context = CIContext(options: [
        .cacheIntermediates: false
    ])

    func preprocess(_ image: CGImage) throws -> CGImage {
        var output = CIImage(cgImage: image)
        let scaleFactor = Self.scaleFactor(for: image)

        if scaleFactor > 1 {
            let scaleFilter = CIFilter.lanczosScaleTransform()
            scaleFilter.inputImage = output
            scaleFilter.scale = Float(scaleFactor)
            scaleFilter.aspectRatio = 1
            output = scaleFilter.outputImage ?? output.transformed(by: CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
        }

        let colorFilter = CIFilter.colorControls()
        colorFilter.inputImage = output
        colorFilter.saturation = 0
        colorFilter.brightness = 0.02
        colorFilter.contrast = 1.28
        output = colorFilter.outputImage ?? output

        let sharpenFilter = CIFilter.sharpenLuminance()
        sharpenFilter.inputImage = output
        sharpenFilter.sharpness = 0.45
        output = sharpenFilter.outputImage ?? output

        guard let processedImage = context.createCGImage(output, from: output.extent.integral) else {
            throw ImagePreprocessingError.outputUnavailable
        }

        return processedImage
    }

    private static func scaleFactor(for image: CGImage) -> CGFloat {
        let width = CGFloat(image.width)
        let height = CGFloat(image.height)
        let shortestSide = min(width, height)
        let longestSide = max(width, height)
        let targetScale: CGFloat

        if shortestSide < 500 {
            targetScale = 3
        } else if shortestSide < 1_000 {
            targetScale = 2
        } else {
            targetScale = 1
        }

        let maxScale = max(1, 3_000 / longestSide)
        return min(targetScale, maxScale)
    }
}

enum ImagePreprocessingError: LocalizedError {
    case outputUnavailable

    var errorDescription: String? {
        "OCR 전처리 이미지를 생성하지 못했습니다."
    }
}
