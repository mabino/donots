import AppKit

enum RegionSelectorCoordinator {
    /// Opens a full-screen crosshair overlay and calls `completion` with the selected
    /// screen region in screencapture-compatible coordinates (top-left origin).
    @MainActor
    static func selectRegion(completion: @escaping (CGRect) -> Void) {
        guard let screen = NSScreen.main else { return }

        let window = RegionSelectorWindow(screen: screen)
        let selectorView = RegionSelectorNSView(frame: screen.frame)
        window.contentView = selectorView

        let close = { [weak window] in
            window?.orderOut(nil)
            NSCursor.arrow.set()
        }

        selectorView.onSelectionComplete = { nsRect in
            let screenRect = convertToScreenCapture(nsRect: nsRect, screen: screen)
            close()
            completion(screenRect)
        }

        selectorView.onCancel = {
            close()
        }

        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(selectorView)
        NSCursor.crosshair.push()
    }

    /// Convert NSView rect (bottom-left origin) to screencapture coordinates (top-left origin).
    static func convertToScreenCapture(nsRect: NSRect, screen: NSScreen) -> CGRect {
        let screenHeight = screen.frame.height
        // NSView y=0 is at bottom; screencapture y=0 is at top
        let topLeftY = screenHeight - nsRect.maxY
        return CGRect(
            x: round(nsRect.minX),
            y: round(topLeftY),
            width: round(nsRect.width),
            height: round(nsRect.height)
        )
    }
}
