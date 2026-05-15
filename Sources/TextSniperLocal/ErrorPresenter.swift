import AppKit

@MainActor
enum ErrorPresenter {
    static func show(_ error: Error) {
        let alert = NSAlert(error: error)
        alert.messageText = "작업을 완료하지 못했습니다."

        if let localizedError = error as? LocalizedError {
            alert.informativeText = [
                localizedError.errorDescription,
                localizedError.recoverySuggestion
            ]
            .compactMap { $0 }
            .joined(separator: "\n\n")
        }

        alert.addButton(withTitle: "확인")
        alert.addButton(withTitle: "권한 설정 열기")

        if alert.runModal() == .alertSecondButtonReturn {
            SystemSettings.openScreenRecording()
        }
    }
}
