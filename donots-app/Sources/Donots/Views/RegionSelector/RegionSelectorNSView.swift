import AppKit

final class RegionSelectorNSView: NSView {
    var onSelectionComplete: ((NSRect) -> Void)?
    var onCancel: (() -> Void)?

    private var dragOrigin: NSPoint?
    private var currentRect: NSRect?

    override var acceptsFirstResponder: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        // Semi-transparent overlay
        NSColor.black.withAlphaComponent(0.3).setFill()
        dirtyRect.fill()

        guard let rect = currentRect else { return }

        // Clear the selection rectangle
        NSColor.clear.setFill()
        rect.fill(using: .copy)

        // Draw selection border
        NSColor.white.setStroke()
        let borderPath = NSBezierPath(rect: rect)
        borderPath.lineWidth = 2
        borderPath.stroke()

        // Draw dashed inner border
        NSColor.systemBlue.setStroke()
        let dashPath = NSBezierPath(rect: rect.insetBy(dx: 1, dy: 1))
        dashPath.lineWidth = 1
        dashPath.setLineDash([4, 4], count: 2, phase: 0)
        dashPath.stroke()

        // Dimension label
        let w = Int(rect.width)
        let h = Int(rect.height)
        let label = "\(w) x \(h)"
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .medium),
            .foregroundColor: NSColor.white,
            .backgroundColor: NSColor.black.withAlphaComponent(0.7)
        ]
        let labelSize = (label as NSString).size(withAttributes: attrs)
        let labelOrigin = NSPoint(
            x: rect.midX - labelSize.width / 2,
            y: rect.maxY + 4
        )
        (label as NSString).draw(at: labelOrigin, withAttributes: attrs)
    }

    override func mouseDown(with event: NSEvent) {
        dragOrigin = convert(event.locationInWindow, from: nil)
        currentRect = nil
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        guard let origin = dragOrigin else { return }
        let current = convert(event.locationInWindow, from: nil)
        let x = min(origin.x, current.x)
        let y = min(origin.y, current.y)
        let w = abs(current.x - origin.x)
        let h = abs(current.y - origin.y)
        currentRect = NSRect(x: x, y: y, width: w, height: h)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        guard let rect = currentRect, rect.width > 5, rect.height > 5 else {
            // Too small — treat as cancel
            onCancel?()
            return
        }
        onSelectionComplete?(rect)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Escape
            onCancel?()
        }
    }
}
