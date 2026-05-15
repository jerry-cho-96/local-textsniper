import AppKit

@MainActor
final class StatusBarController: NSObject {
    private let statusItem: NSStatusItem
    private let statusMenuItem: NSMenuItem
    private let captureItem: NSMenuItem
    private let launchAtLoginItem: NSMenuItem

    init(
        captureShortcut: HotKeyShortcut,
        launchAtLoginStatus: LoginItemStatus,
        onCapture: @escaping @MainActor () -> Void,
        onOpenShortcutSettings: @escaping @MainActor () -> Void,
        onToggleLaunchAtLogin: @escaping @MainActor () -> Void,
        onRefreshLaunchAtLoginStatus: @escaping @MainActor () -> LoginItemStatus,
        onOpenScreenRecordingSettings: @escaping @MainActor () -> Void,
        onQuit: @escaping @MainActor () -> Void
    ) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusMenuItem = NSMenuItem(title: "대기 중", action: nil, keyEquivalent: "")
        captureItem = NSMenuItem(title: "텍스트 캡처", action: #selector(capture), keyEquivalent: "")
        launchAtLoginItem = NSMenuItem(title: "로그인 시 실행", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        self.onCapture = onCapture
        self.onOpenShortcutSettings = onOpenShortcutSettings
        self.onToggleLaunchAtLogin = onToggleLaunchAtLogin
        self.onRefreshLaunchAtLoginStatus = onRefreshLaunchAtLoginStatus
        self.onOpenScreenRecordingSettings = onOpenScreenRecordingSettings
        self.onQuit = onQuit

        super.init()

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "text.viewfinder", accessibilityDescription: "Text Capture")
            button.image?.isTemplate = true
            button.toolTip = "TextSniper Local"
        }

        let menu = NSMenu()
        menu.delegate = self

        updateCaptureShortcut(captureShortcut)
        captureItem.target = self
        menu.addItem(captureItem)

        menu.addItem(.separator())
        menu.addItem(statusMenuItem)
        menu.addItem(.separator())

        let shortcutSettingsItem = NSMenuItem(title: "단축키 설정...", action: #selector(openShortcutSettings), keyEquivalent: ",")
        shortcutSettingsItem.keyEquivalentModifierMask = [.command]
        shortcutSettingsItem.target = self
        menu.addItem(shortcutSettingsItem)

        updateLaunchAtLoginStatus(launchAtLoginStatus)
        launchAtLoginItem.target = self
        menu.addItem(launchAtLoginItem)

        let settingsItem = NSMenuItem(title: "화면 기록 권한 열기", action: #selector(openScreenRecordingSettings), keyEquivalent: "")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "종료", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private let onCapture: @MainActor () -> Void
    private let onOpenShortcutSettings: @MainActor () -> Void
    private let onToggleLaunchAtLogin: @MainActor () -> Void
    private let onRefreshLaunchAtLoginStatus: @MainActor () -> LoginItemStatus
    private let onOpenScreenRecordingSettings: @MainActor () -> Void
    private let onQuit: @MainActor () -> Void

    func updateCaptureShortcut(_ shortcut: HotKeyShortcut) {
        captureItem.title = "텍스트 캡처"
        captureItem.keyEquivalent = shortcut.menuKeyEquivalent
        captureItem.keyEquivalentModifierMask = shortcut.menuModifierFlags
    }

    func updateLaunchAtLoginStatus(_ status: LoginItemStatus) {
        launchAtLoginItem.title = status.menuTitle
        launchAtLoginItem.state = status.menuState
        launchAtLoginItem.isEnabled = status != .unavailable
    }

    func showIdle() {
        statusMenuItem.title = "대기 중"
    }

    func showWorking() {
        statusMenuItem.title = "인식 중..."
    }

    func showSuccess(lineCount: Int) {
        statusMenuItem.title = "\(lineCount)줄 복사됨"
    }

    func showFailure(_ message: String) {
        statusMenuItem.title = message
    }

    @objc private func capture() {
        onCapture()
    }

    @objc private func openShortcutSettings() {
        onOpenShortcutSettings()
    }

    @objc private func toggleLaunchAtLogin() {
        onToggleLaunchAtLogin()
    }

    @objc private func openScreenRecordingSettings() {
        onOpenScreenRecordingSettings()
    }

    @objc private func quit() {
        onQuit()
    }
}

extension StatusBarController: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        updateLaunchAtLoginStatus(onRefreshLaunchAtLoginStatus())
    }
}
