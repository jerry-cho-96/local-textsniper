import AppKit
import Carbon
import Foundation

struct HotKeyShortcut: Equatable, Sendable {
    let keyCode: UInt32
    let carbonModifiers: UInt32

    static let defaultCapture = HotKeyShortcut(
        keyCode: UInt32(kVK_ANSI_2),
        carbonModifiers: UInt32(cmdKey | shiftKey)
    )

    init(keyCode: UInt32, carbonModifiers: UInt32) {
        self.keyCode = keyCode
        self.carbonModifiers = carbonModifiers
    }

    init?(event: NSEvent) {
        let keyCode = UInt32(event.keyCode)
        let modifiers = Self.carbonModifiers(from: event.modifierFlags)

        guard modifiers != 0, !Self.isModifierOnlyKey(keyCode) else {
            return nil
        }

        self.keyCode = keyCode
        self.carbonModifiers = modifiers
    }

    var displayString: String {
        Self.modifierDisplay(carbonModifiers) + Self.keyDisplay(for: keyCode)
    }

    var menuKeyEquivalent: String {
        Self.menuKeyEquivalent(for: keyCode) ?? ""
    }

    var menuModifierFlags: NSEvent.ModifierFlags {
        var flags: NSEvent.ModifierFlags = []

        if carbonModifiers & UInt32(cmdKey) != 0 {
            flags.insert(.command)
        }

        if carbonModifiers & UInt32(shiftKey) != 0 {
            flags.insert(.shift)
        }

        if carbonModifiers & UInt32(optionKey) != 0 {
            flags.insert(.option)
        }

        if carbonModifiers & UInt32(controlKey) != 0 {
            flags.insert(.control)
        }

        return flags
    }

    private static func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
        let deviceIndependentFlags = flags.intersection(.deviceIndependentFlagsMask)
        var result: UInt32 = 0

        if deviceIndependentFlags.contains(.command) {
            result |= UInt32(cmdKey)
        }

        if deviceIndependentFlags.contains(.shift) {
            result |= UInt32(shiftKey)
        }

        if deviceIndependentFlags.contains(.option) {
            result |= UInt32(optionKey)
        }

        if deviceIndependentFlags.contains(.control) {
            result |= UInt32(controlKey)
        }

        return result
    }

    private static func modifierDisplay(_ modifiers: UInt32) -> String {
        var result = ""

        if modifiers & UInt32(controlKey) != 0 {
            result += "^"
        }

        if modifiers & UInt32(optionKey) != 0 {
            result += "Option+"
        }

        if modifiers & UInt32(shiftKey) != 0 {
            result += "Shift+"
        }

        if modifiers & UInt32(cmdKey) != 0 {
            result += "Cmd+"
        }

        return result
    }

    private static func keyDisplay(for keyCode: UInt32) -> String {
        keyNames[keyCode] ?? "Key \(keyCode)"
    }

    private static func menuKeyEquivalent(for keyCode: UInt32) -> String? {
        menuKeyEquivalents[keyCode]
    }

    private static func isModifierOnlyKey(_ keyCode: UInt32) -> Bool {
        modifierOnlyKeyCodes.contains(keyCode)
    }

    private static let modifierOnlyKeyCodes: Set<UInt32> = [
        UInt32(kVK_Command),
        UInt32(kVK_RightCommand),
        UInt32(kVK_Shift),
        UInt32(kVK_RightShift),
        UInt32(kVK_Option),
        UInt32(kVK_RightOption),
        UInt32(kVK_Control),
        UInt32(kVK_RightControl),
        UInt32(kVK_CapsLock),
        UInt32(kVK_Function)
    ]

    private static let keyNames: [UInt32: String] = [
        UInt32(kVK_ANSI_A): "A",
        UInt32(kVK_ANSI_B): "B",
        UInt32(kVK_ANSI_C): "C",
        UInt32(kVK_ANSI_D): "D",
        UInt32(kVK_ANSI_E): "E",
        UInt32(kVK_ANSI_F): "F",
        UInt32(kVK_ANSI_G): "G",
        UInt32(kVK_ANSI_H): "H",
        UInt32(kVK_ANSI_I): "I",
        UInt32(kVK_ANSI_J): "J",
        UInt32(kVK_ANSI_K): "K",
        UInt32(kVK_ANSI_L): "L",
        UInt32(kVK_ANSI_M): "M",
        UInt32(kVK_ANSI_N): "N",
        UInt32(kVK_ANSI_O): "O",
        UInt32(kVK_ANSI_P): "P",
        UInt32(kVK_ANSI_Q): "Q",
        UInt32(kVK_ANSI_R): "R",
        UInt32(kVK_ANSI_S): "S",
        UInt32(kVK_ANSI_T): "T",
        UInt32(kVK_ANSI_U): "U",
        UInt32(kVK_ANSI_V): "V",
        UInt32(kVK_ANSI_W): "W",
        UInt32(kVK_ANSI_X): "X",
        UInt32(kVK_ANSI_Y): "Y",
        UInt32(kVK_ANSI_Z): "Z",
        UInt32(kVK_ANSI_0): "0",
        UInt32(kVK_ANSI_1): "1",
        UInt32(kVK_ANSI_2): "2",
        UInt32(kVK_ANSI_3): "3",
        UInt32(kVK_ANSI_4): "4",
        UInt32(kVK_ANSI_5): "5",
        UInt32(kVK_ANSI_6): "6",
        UInt32(kVK_ANSI_7): "7",
        UInt32(kVK_ANSI_8): "8",
        UInt32(kVK_ANSI_9): "9",
        UInt32(kVK_Space): "Space",
        UInt32(kVK_Return): "Return",
        UInt32(kVK_Tab): "Tab",
        UInt32(kVK_Delete): "Delete",
        UInt32(kVK_Escape): "Esc",
        UInt32(kVK_F1): "F1",
        UInt32(kVK_F2): "F2",
        UInt32(kVK_F3): "F3",
        UInt32(kVK_F4): "F4",
        UInt32(kVK_F5): "F5",
        UInt32(kVK_F6): "F6",
        UInt32(kVK_F7): "F7",
        UInt32(kVK_F8): "F8",
        UInt32(kVK_F9): "F9",
        UInt32(kVK_F10): "F10",
        UInt32(kVK_F11): "F11",
        UInt32(kVK_F12): "F12"
    ]

    private static let menuKeyEquivalents: [UInt32: String] = [
        UInt32(kVK_ANSI_A): "a",
        UInt32(kVK_ANSI_B): "b",
        UInt32(kVK_ANSI_C): "c",
        UInt32(kVK_ANSI_D): "d",
        UInt32(kVK_ANSI_E): "e",
        UInt32(kVK_ANSI_F): "f",
        UInt32(kVK_ANSI_G): "g",
        UInt32(kVK_ANSI_H): "h",
        UInt32(kVK_ANSI_I): "i",
        UInt32(kVK_ANSI_J): "j",
        UInt32(kVK_ANSI_K): "k",
        UInt32(kVK_ANSI_L): "l",
        UInt32(kVK_ANSI_M): "m",
        UInt32(kVK_ANSI_N): "n",
        UInt32(kVK_ANSI_O): "o",
        UInt32(kVK_ANSI_P): "p",
        UInt32(kVK_ANSI_Q): "q",
        UInt32(kVK_ANSI_R): "r",
        UInt32(kVK_ANSI_S): "s",
        UInt32(kVK_ANSI_T): "t",
        UInt32(kVK_ANSI_U): "u",
        UInt32(kVK_ANSI_V): "v",
        UInt32(kVK_ANSI_W): "w",
        UInt32(kVK_ANSI_X): "x",
        UInt32(kVK_ANSI_Y): "y",
        UInt32(kVK_ANSI_Z): "z",
        UInt32(kVK_ANSI_0): "0",
        UInt32(kVK_ANSI_1): "1",
        UInt32(kVK_ANSI_2): "2",
        UInt32(kVK_ANSI_3): "3",
        UInt32(kVK_ANSI_4): "4",
        UInt32(kVK_ANSI_5): "5",
        UInt32(kVK_ANSI_6): "6",
        UInt32(kVK_ANSI_7): "7",
        UInt32(kVK_ANSI_8): "8",
        UInt32(kVK_ANSI_9): "9",
        UInt32(kVK_Space): " ",
        UInt32(kVK_Return): "\r",
        UInt32(kVK_Tab): "\t",
        UInt32(kVK_Delete): "\u{8}",
        UInt32(kVK_Escape): "\u{1b}"
    ]
}
