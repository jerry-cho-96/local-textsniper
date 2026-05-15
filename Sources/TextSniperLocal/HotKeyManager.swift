import Carbon
import Foundation

final class HotKeyManager {
    private let handler: () -> Void
    private var eventHotKey: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private var currentShortcut: HotKeyShortcut?

    init(shortcut: HotKeyShortcut, handler: @escaping () -> Void) {
        self.handler = handler
        installEventHandler()

        do {
            try register(shortcut)
            currentShortcut = shortcut
        } catch {
            NSLog("Failed to register global hotkey: \(error.localizedDescription)")
        }
    }

    deinit {
        if let eventHotKey {
            UnregisterEventHotKey(eventHotKey)
        }

        if let eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }

    func update(shortcut: HotKeyShortcut) throws {
        let previousShortcut = currentShortcut
        unregisterCurrentHotKey()

        do {
            try register(shortcut)
            currentShortcut = shortcut
        } catch {
            if let previousShortcut {
                try? register(previousShortcut)
                currentShortcut = previousShortcut
            }

            throw error
        }
    }

    private func installEventHandler() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, userData in
                guard let event, let userData else {
                    return noErr
                }

                var hotKeyID = EventHotKeyID()
                GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )

                let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
                manager.handleHotKey(hotKeyID)
                return noErr
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandler
        )
    }

    private func register(_ shortcut: HotKeyShortcut) throws {
        let hotKeyID = EventHotKeyID(signature: Self.signature, id: 1)
        var registeredHotKey: EventHotKeyRef?

        let status = RegisterEventHotKey(
            shortcut.keyCode,
            shortcut.carbonModifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &registeredHotKey
        )

        guard status == noErr, let registeredHotKey else {
            throw HotKeyRegistrationError.registrationFailed(shortcut: shortcut, status: status)
        }

        eventHotKey = registeredHotKey
    }

    private func unregisterCurrentHotKey() {
        if let eventHotKey {
            UnregisterEventHotKey(eventHotKey)
            self.eventHotKey = nil
        }
    }

    private func handleHotKey(_ hotKeyID: EventHotKeyID) {
        guard hotKeyID.signature == Self.signature, hotKeyID.id == 1 else {
            return
        }

        handler()
    }

    private static let signature: OSType = {
        "TSNP".utf8.reduce(OSType(0)) { partialResult, byte in
            (partialResult << 8) + OSType(byte)
        }
    }()
}

private enum HotKeyRegistrationError: LocalizedError {
    case registrationFailed(shortcut: HotKeyShortcut, status: OSStatus)

    var errorDescription: String? {
        switch self {
        case let .registrationFailed(shortcut, status):
            "단축키 \(shortcut.displayString)을 등록하지 못했습니다. OSStatus: \(status)"
        }
    }

    var recoverySuggestion: String? {
        "이미 다른 앱이나 시스템 기능에서 사용 중인 단축키일 수 있습니다. 다른 조합을 선택하세요."
    }
}
