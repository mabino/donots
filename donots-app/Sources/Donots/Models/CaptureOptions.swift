import Foundation

enum ImageFormat: String, Sendable, CaseIterable {
    case png = "png"
    case jpeg = "jpg"

    var displayName: String {
        switch self {
        case .png: "PNG"
        case .jpeg: "JPEG"
        }
    }

    var fileExtension: String { rawValue }
}

struct CaptureOptions: Sendable {
    let imageFormat: ImageFormat
    let jpegQuality: Double
    let scaleDownFactor: Double

    init(imageFormat: ImageFormat = .png, jpegQuality: Double = 0.8, scaleDownFactor: Double = 1.0) {
        self.imageFormat = imageFormat
        self.jpegQuality = max(0.0, min(1.0, jpegQuality))
        self.scaleDownFactor = max(0.1, min(1.0, scaleDownFactor))
    }

    static func fromDefaults() -> CaptureOptions {
        let defaults = UserDefaults.standard
        let formatRaw = defaults.string(forKey: "imageFormat") ?? "png"
        let format = ImageFormat(rawValue: formatRaw) ?? .png
        let quality = defaults.double(forKey: "jpegQuality")
        let scale = defaults.double(forKey: "scaleDownFactor")
        return CaptureOptions(
            imageFormat: format,
            jpegQuality: quality > 0 ? quality : 0.8,
            scaleDownFactor: scale > 0 ? scale : 1.0
        )
    }
}
