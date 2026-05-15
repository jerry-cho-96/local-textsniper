import AppKit
import Carbon

@MainActor
final class ShortcutPreferencesWindowController: NSWindowController {
    private let recorderView = ShortcutRecorderView()
    private let currentShortcutField = NSTextField(labelWithString: "")
    private let onShortcutChange: @MainActor (HotKeyShortcut) -> Bool

    init(
        currentShortcut: HotKeyShortcut,
        onShortcutChange: @escaping @MainActor (HotKeyShortcut) -> Bool
    ) {
        self.onShortcutChange = onShortcutChange

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 188),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "단축키 설정"
        window.isReleasedWhenClosed = false
        window.center()

        super.init(window: window)

        buildContent(currentShortcut: currentShortcut)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(currentShortcut: HotKeyShortcut) {
        updateCurrentShortcut(currentShortcut)
        showWindow(nil)
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        recorderView.beginRecording()

        if #available(macOS 14, *) {
            NSApp.activate()
        } else {
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func buildContent(currentShortcut: HotKeyShortcut) {
        guard let window else {
            return
        }

        let contentView = NSView(frame: window.contentView?.bounds ?? .zero)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        window.contentView = contentView

        let titleField = NSTextField(labelWithString: "캡처 단축키")
        titleField.font = .systemFont(ofSize: 18, weight: .semibold)

        let descriptionField = NSTextField(labelWithString: "아래 입력 영역을 클릭한 뒤 새 단축키를 누르세요.")
        descriptionField.font = .systemFont(ofSize: 13)
        descriptionField.textColor = .secondaryLabelColor

        currentShortcutField.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        currentShortcutField.textColor = .secondaryLabelColor

        recorderView.onShortcutCaptured = { [weak self] shortcut in
            guard let self else {
                return false
            }

            let didApply = self.onShortcutChange(shortcut)
            if didApply {
                self.updateCurrentShortcut(shortcut)
            }

            return didApply
        }

        let resetButton = NSButton(title: "기본값", target: self, action: #selector(resetShortcut))
        resetButton.bezelStyle = .rounded

        let stackView = NSStackView(views: [
            titleField,
            descriptionField,
            recorderView,
            currentShortcutField,
            resetButton
        ])
        stackView.orientation = .vertical
        stackView.alignment = .leading
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22),
            recorderView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            recorderView.heightAnchor.constraint(equalToConstant: 44)
        ])

        updateCurrentShortcut(currentShortcut)
    }

    private func updateCurrentShortcut(_ shortcut: HotKeyShortcut) {
        recorderView.shortcut = shortcut
        currentShortcutField.stringValue = "현재 단축키: \(shortcut.displayString)"
    }

    @objc private func resetShortcut() {
        let defaultShortcut = HotKeyShortcut.defaultCapture

        guard onShortcutChange(defaultShortcut) else {
            return
        }

        updateCurrentShortcut(defaultShortcut)
    }
}

@MainActor
private final class ShortcutRecorderView: NSView {
    var shortcut: HotKeyShortcut = .defaultCapture {
        didSet {
            needsDisplay = true
        }
    }

    var onShortcutCaptured: ((HotKeyShortcut) -> Bool)?

    private var isRecording = false {
        didSet {
            needsDisplay = true
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var acceptsFirstResponder: Bool {
        true
    }

    func beginRecording() {
        isRecording = true
        window?.makeFirstResponder(self)
    }

    override func mouseDown(with event: NSEvent) {
        beginRecording()
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == UInt16(kVK_Escape) {
            isRecording = false
            return
        }

        guard let shortcut = HotKeyShortcut(event: event) else {
            NSSound.beep()
            return
        }

        guard onShortcutCaptured?(shortcut) == true else {
            NSSound.beep()
            return
        }

        self.shortcut = shortcut
        isRecording = false
    }

    override func draw(_ dirtyRect: NSRect) {
        let rect = bounds.insetBy(dx: 0.5, dy: 0.5)
        let path = NSBezierPath(roundedRect: rect, xRadius: 8, yRadius: 8)

        NSColor.textBackgroundColor.setFill()
        path.fill()

        (isRecording ? NSColor.controlAccentColor : NSColor.separatorColor).setStroke()
        path.lineWidth = isRecording ? 2 : 1
        path.stroke()

        let text = isRecording ? "새 단축키 입력..." : shortcut.displayString
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 16, weight: .semibold),
            .foregroundColor: NSColor.labelColor
        ]
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedText.size()
        let textRect = CGRect(
            x: bounds.midX - textSize.width / 2,
            y: bounds.midY - textSize.height / 2,
            width: textSize.width,
            height: textSize.height
        )

        attributedText.draw(in: textRect)
    }
}
