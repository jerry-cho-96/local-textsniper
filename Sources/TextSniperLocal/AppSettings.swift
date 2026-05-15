import Foundation

final class AppSettings {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var captureShortcut: HotKeyShortcut {
        get {
            guard
                defaults.object(forKey: Keys.captureShortcutKeyCode) != nil,
                defaults.object(forKey: Keys.captureShortcutModifiers) != nil
            else {
                return .defaultCapture
            }

            let keyCode = UInt32(defaults.integer(forKey: Keys.captureShortcutKeyCode))
            let modifiers = UInt32(defaults.integer(forKey: Keys.captureShortcutModifiers))

            guard modifiers != 0 else {
                return .defaultCapture
            }

            return HotKeyShortcut(keyCode: keyCode, carbonModifiers: modifiers)
        }
        set {
            defaults.set(Int(newValue.keyCode), forKey: Keys.captureShortcutKeyCode)
            defaults.set(Int(newValue.carbonModifiers), forKey: Keys.captureShortcutModifiers)
        }
    }

    func resetCaptureShortcut() {
        captureShortcut = .defaultCapture
    }
}

private enum Keys {
    static let captureShortcutKeyCode = "captureShortcut.keyCode"
    static let captureShortcutModifiers = "captureShortcut.modifiers"
}
