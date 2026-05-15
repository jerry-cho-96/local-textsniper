import AppKit

@MainActor
final class SelectionOverlayController {
    private var windows: [SelectionOverlayWindow] = []
    private var completion: ((CGRect?) -> Void)?

    func begin(completion: @escaping (CGRect?) -> Void) {
        self.completion = completion

        for screen in NSScreen.screens {
            let window = SelectionOverlayWindow(
                contentRect: screen.frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )

            let overlayView = SelectionOverlayView(screenFrame: screen.frame)
            overlayView.onFinish = { [weak self] rect in
                self?.finish(with: rect)
            }
            overlayView.onCancel = { [weak self] in
                self?.finish(with: nil)
            }

            window.contentView = overlayView
            window.backgroundColor = .clear
            window.isOpaque = false
            window.hasShadow = false
            window.level = .screenSaver
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
            window.acceptsMouseMovedEvents = true
            window.makeKeyAndOrderFront(nil)
            window.makeFirstResponder(overlayView)

            windows.append(window)
        }

        if #available(macOS 14, *) {
            NSApp.activate()
        } else {
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func finish(with rect: CGRect?) {
        let completion = completion
        self.completion = nil

        for window in windows {
            window.orderOut(nil)
        }
        windows.removeAll()

        completion?(rect)
    }
}

final class SelectionOverlayWindow: NSWindow {
    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        true
    }
}
