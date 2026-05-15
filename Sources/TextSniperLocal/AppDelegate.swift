import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController?
    private var hotKeyManager: HotKeyManager?
    private var selectionOverlayController: SelectionOverlayController?
    private var shortcutPreferencesWindowController: ShortcutPreferencesWindowController?

    private let settings = AppSettings()
    private let loginItemService = LoginItemService()
    private let screenCaptureService = ScreenCaptureService()
    private let textRecognitionService = TextRecognitionService()
    private let clipboardService = ClipboardService()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let captureShortcut = settings.captureShortcut

        statusBarController = StatusBarController(
            captureShortcut: captureShortcut,
            launchAtLoginStatus: loginItemService.status,
            onCapture: { [weak self] in
                self?.beginCapture()
            },
            onOpenShortcutSettings: { [weak self] in
                self?.openShortcutSettings()
            },
            onToggleLaunchAtLogin: { [weak self] in
                self?.toggleLaunchAtLogin()
            },
            onRefreshLaunchAtLoginStatus: { [weak self] in
                self?.loginItemService.status ?? .unavailable
            },
            onOpenScreenRecordingSettings: {
                SystemSettings.openScreenRecording()
            },
            onQuit: {
                NSApp.terminate(nil)
            }
        )

        hotKeyManager = HotKeyManager(shortcut: captureShortcut) { [weak self] in
            Task { @MainActor in
                self?.beginCapture()
            }
        }
    }

    private func toggleLaunchAtLogin() {
        let currentStatus = loginItemService.status
        let shouldEnable = currentStatus != .enabled

        do {
            try loginItemService.setEnabled(shouldEnable)
            statusBarController?.updateLaunchAtLoginStatus(loginItemService.status)
        } catch {
            statusBarController?.updateLaunchAtLoginStatus(loginItemService.status)
            ErrorPresenter.show(error)
        }
    }

    private func openShortcutSettings() {
        let controller = shortcutPreferencesWindowController ?? ShortcutPreferencesWindowController(
            currentShortcut: settings.captureShortcut,
            onShortcutChange: { [weak self] shortcut in
                self?.applyCaptureShortcut(shortcut) ?? false
            }
        )

        shortcutPreferencesWindowController = controller
        controller.show(currentShortcut: settings.captureShortcut)
    }

    private func applyCaptureShortcut(_ shortcut: HotKeyShortcut) -> Bool {
        do {
            try hotKeyManager?.update(shortcut: shortcut)
            settings.captureShortcut = shortcut
            statusBarController?.updateCaptureShortcut(shortcut)
            statusBarController?.showIdle()
            return true
        } catch {
            ErrorPresenter.show(error)
            return false
        }
    }

    private func beginCapture() {
        guard selectionOverlayController == nil else {
            return
        }

        let controller = SelectionOverlayController()
        selectionOverlayController = controller

        controller.begin { [weak self] selectedRect in
            guard let self else {
                return
            }

            self.selectionOverlayController = nil

            guard let selectedRect else {
                self.statusBarController?.showIdle()
                return
            }

            Task {
                await self.captureAndRecognize(in: selectedRect)
            }
        }
    }

    private func captureAndRecognize(in selectedRect: CGRect) async {
        statusBarController?.showWorking()

        do {
            try await Task.sleep(for: .milliseconds(140))

            let image = try screenCaptureService.capture(rect: selectedRect)
            let recognizedText = try await textRecognitionService.recognizeText(in: image)

            guard !recognizedText.isEmpty else {
                statusBarController?.showFailure("텍스트 없음")
                return
            }

            clipboardService.copy(recognizedText)
            statusBarController?.showSuccess(lineCount: recognizedText.lineCount)
            NSSound(named: "Tink")?.play()
        } catch {
            statusBarController?.showFailure("캡처 실패")
            ErrorPresenter.show(error)
        }
    }
}

private extension String {
    var lineCount: Int {
        split(whereSeparator: \.isNewline).count
    }
}
