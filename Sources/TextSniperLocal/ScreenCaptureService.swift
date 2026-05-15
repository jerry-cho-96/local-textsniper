import AppKit
import CoreGraphics

struct ScreenCaptureService {
    func capture(rect appKitRect: CGRect) throws -> CGImage {
        let normalizedRect = appKitRect.standardized.integral

        guard normalizedRect.width >= 1, normalizedRect.height >= 1 else {
            throw ScreenCaptureError.emptySelection
        }

        if !CGPreflightScreenCaptureAccess() {
            _ = CGRequestScreenCaptureAccess()
        }

        guard let image = CGWindowListCreateImage(
            CoordinateConverter.cgWindowRect(from: normalizedRect),
            .optionOnScreenOnly,
            kCGNullWindowID,
            [.bestResolution]
        ) else {
            throw ScreenCaptureError.imageUnavailable
        }

        return image
    }
}

enum ScreenCaptureError: LocalizedError {
    case emptySelection
    case imageUnavailable

    var errorDescription: String? {
        switch self {
        case .emptySelection:
            "선택 영역이 너무 작습니다."
        case .imageUnavailable:
            "화면 이미지를 가져오지 못했습니다."
        }
    }

    var recoverySuggestion: String? {
        "시스템 설정 > 개인정보 보호 및 보안 > 화면 기록에서 TextSniper Local 권한을 허용한 뒤 앱을 다시 실행하세요."
    }
}

private enum CoordinateConverter {
    static func cgWindowRect(from appKitRect: CGRect) -> CGRect {
        let desktopBounds = NSScreen.screens
            .map(\.frame)
            .reduce(CGRect.null) { partialResult, frame in
                partialResult.union(frame)
            }

        return CGRect(
            x: appKitRect.minX,
            y: desktopBounds.maxY - appKitRect.maxY,
            width: appKitRect.width,
            height: appKitRect.height
        )
    }
}
