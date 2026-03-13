import AppKit

enum ScreenshotService {
    static func captureRegion(
        x: Int, y: Int, width: Int, height: Int,
        directory: String,
        index: Int,
        options: CaptureOptions = CaptureOptions()
    ) async throws -> String {
        let dir = (directory as NSString).expandingTildeInPath
        try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)

        let timestamp = DateFormatting.filenameTimestamp()
        let ext = options.imageFormat.fileExtension
        let filename = "notification_\(timestamp)_\(index).\(ext)"
        let path = (dir as NSString).appendingPathComponent(filename)

        // Use -t flag to specify format
        let regionResult = try await runScreencapture([
            "-R", "\(x),\(y),\(width),\(height)",
            "-t", options.imageFormat.rawValue,
            "-x", path
        ])

        let fileExists = FileManager.default.fileExists(atPath: path)
        let fileSize = (try? FileManager.default.attributesOfItem(atPath: path)[.size] as? Int) ?? 0

        if regionResult && fileExists && fileSize > 0 {
            try postProcess(path: path, options: options)
            return path
        }

        // Fallback to full-screen
        let fallbackFilename = "notification_full_\(timestamp)_\(index).\(ext)"
        let fallbackPath = (dir as NSString).appendingPathComponent(fallbackFilename)
        let fallbackResult = try await runScreencapture([
            "-t", options.imageFormat.rawValue,
            "-x", fallbackPath
        ])

        let fbExists = FileManager.default.fileExists(atPath: fallbackPath)
        let fbSize = (try? FileManager.default.attributesOfItem(atPath: fallbackPath)[.size] as? Int) ?? 0

        if fallbackResult && fbExists && fbSize > 0 {
            try postProcess(path: fallbackPath, options: options)
            return fallbackPath
        }

        throw ScreenshotError.captureFailed
    }

    static func screenshotPath(directory: String, timestamp: String, index: Int, format: ImageFormat = .png) -> String {
        let dir = (directory as NSString).expandingTildeInPath
        let filename = "notification_\(timestamp)_\(index).\(format.fileExtension)"
        return (dir as NSString).appendingPathComponent(filename)
    }

    private static func postProcess(path: String, options: CaptureOptions) throws {
        let needsQuality = options.imageFormat == .jpeg && options.jpegQuality < 1.0
        let needsScale = options.scaleDownFactor < 1.0

        guard needsQuality || needsScale else { return }

        guard let image = NSImage(contentsOfFile: path) else { return }
        var size = image.size

        if needsScale {
            size = NSSize(
                width: round(size.width * options.scaleDownFactor),
                height: round(size.height * options.scaleDownFactor)
            )
        }

        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else { return }

        let resized: NSBitmapImageRep
        if needsScale {
            resized = NSBitmapImageRep(
                bitmapDataPlanes: nil,
                pixelsWide: Int(size.width),
                pixelsHigh: Int(size.height),
                bitsPerSample: 8,
                samplesPerPixel: 4,
                hasAlpha: true,
                isPlanar: false,
                colorSpaceName: .deviceRGB,
                bytesPerRow: 0,
                bitsPerPixel: 0
            )!
            resized.size = size
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: resized)
            bitmap.draw(in: NSRect(origin: .zero, size: size))
            NSGraphicsContext.restoreGraphicsState()
        } else {
            resized = bitmap
        }

        let data: Data?
        switch options.imageFormat {
        case .jpeg:
            data = resized.representation(
                using: .jpeg,
                properties: [.compressionFactor: options.jpegQuality]
            )
        case .png:
            data = resized.representation(using: .png, properties: [:])
        }

        if let data {
            try data.write(to: URL(fileURLWithPath: path))
        }
    }

    private static func runScreencapture(_ arguments: [String]) async throws -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        process.arguments = arguments
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try process.run()
        process.waitUntilExit()
        return process.terminationStatus == 0
    }
}

enum ScreenshotError: Error, LocalizedError {
    case captureFailed

    var errorDescription: String? {
        "Screenshot capture failed (region and full-screen)"
    }
}
