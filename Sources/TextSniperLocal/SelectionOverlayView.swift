import AppKit

@MainActor
final class SelectionOverlayView: NSView {
    var onFinish: ((CGRect) -> Void)?
    var onCancel: (() -> Void)?

    private let screenFrame: CGRect
    private var startPoint: CGPoint?
    private var currentPoint: CGPoint?

    init(screenFrame: CGRect) {
        self.screenFrame = screenFrame
        super.init(frame: CGRect(origin: .zero, size: screenFrame.size))
        wantsLayer = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var acceptsFirstResponder: Bool {
        true
    }

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .crosshair)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        NSColor.black.withAlphaComponent(0.28).setFill()
        bounds.fill()

        drawInstruction()

        guard let selectionRect else {
            return
        }

        NSGraphicsContext.saveGraphicsState()
        NSColor.clear.setFill()
        selectionRect.fill(using: .clear)
        NSGraphicsContext.restoreGraphicsState()

        NSColor.controlAccentColor.setStroke()
        let border = NSBezierPath(rect: selectionRect)
        border.lineWidth = 2
        border.stroke()

        NSColor.controlAccentColor.withAlphaComponent(0.18).setFill()
        selectionRect.fill()
    }

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        startPoint = point
        currentPoint = point
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        currentPoint = convert(event.locationInWindow, from: nil)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        currentPoint = convert(event.locationInWindow, from: nil)

        guard let rect = selectionRect, rect.width >= 6, rect.height >= 6 else {
            onCancel?()
            return
        }

        onFinish?(globalRect(from: rect))
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 {
            onCancel?()
            return
        }

        super.keyDown(with: event)
    }

    private var selectionRect: CGRect? {
        guard let startPoint, let currentPoint else {
            return nil
        }

        return CGRect(
            x: min(startPoint.x, currentPoint.x),
            y: min(startPoint.y, currentPoint.y),
            width: abs(startPoint.x - currentPoint.x),
            height: abs(startPoint.y - currentPoint.y)
        )
    }

    private func globalRect(from localRect: CGRect) -> CGRect {
        CGRect(
            x: screenFrame.minX + localRect.minX,
            y: screenFrame.minY + localRect.minY,
            width: localRect.width,
            height: localRect.height
        )
    }

    private func drawInstruction() {
        let text = "드래그하여 텍스트 영역 선택  |  Esc 취소"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: NSColor.white.withAlphaComponent(0.92),
            .backgroundColor: NSColor.black.withAlphaComponent(0.35)
        ]

        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let size = attributedText.size()
        let rect = CGRect(
            x: max(20, bounds.midX - size.width / 2),
            y: bounds.maxY - size.height - 28,
            width: size.width,
            height: size.height
        )

        attributedText.draw(in: rect)
    }
}
