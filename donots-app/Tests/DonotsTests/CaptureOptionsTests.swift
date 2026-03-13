import Testing
@testable import Donots

@Suite("CaptureOptions Tests")
struct CaptureOptionsTests {
    @Test("Default values are correct")
    func defaultValues() {
        let options = CaptureOptions()
        #expect(options.imageFormat == .png)
        #expect(options.jpegQuality == 0.8)
        #expect(options.scaleDownFactor == 1.0)
    }

    @Test("Custom values are stored")
    func customValues() {
        let options = CaptureOptions(imageFormat: .jpeg, jpegQuality: 0.5, scaleDownFactor: 0.75)
        #expect(options.imageFormat == .jpeg)
        #expect(options.jpegQuality == 0.5)
        #expect(options.scaleDownFactor == 0.75)
    }

    @Test("JPEG quality is clamped to valid range")
    func jpegQualityClamping() {
        let low = CaptureOptions(jpegQuality: -0.5)
        #expect(low.jpegQuality == 0.0)

        let high = CaptureOptions(jpegQuality: 1.5)
        #expect(high.jpegQuality == 1.0)

        let valid = CaptureOptions(jpegQuality: 0.5)
        #expect(valid.jpegQuality == 0.5)
    }

    @Test("Scale down factor is clamped to valid range")
    func scaleDownClamping() {
        let low = CaptureOptions(scaleDownFactor: 0.01)
        #expect(low.scaleDownFactor == 0.1)

        let high = CaptureOptions(scaleDownFactor: 2.0)
        #expect(high.scaleDownFactor == 1.0)

        let valid = CaptureOptions(scaleDownFactor: 0.5)
        #expect(valid.scaleDownFactor == 0.5)
    }

    @Test("ImageFormat raw values match screencapture -t flags")
    func imageFormatRawValues() {
        #expect(ImageFormat.png.rawValue == "png")
        #expect(ImageFormat.jpeg.rawValue == "jpg")
    }

    @Test("ImageFormat file extensions are correct")
    func imageFormatExtensions() {
        #expect(ImageFormat.png.fileExtension == "png")
        #expect(ImageFormat.jpeg.fileExtension == "jpg")
    }

    @Test("ImageFormat display names are human-readable")
    func imageFormatDisplayNames() {
        #expect(ImageFormat.png.displayName == "PNG")
        #expect(ImageFormat.jpeg.displayName == "JPEG")
    }

    @Test("All ImageFormat cases are iterable")
    func allCases() {
        #expect(ImageFormat.allCases.count == 2)
        #expect(ImageFormat.allCases.contains(.png))
        #expect(ImageFormat.allCases.contains(.jpeg))
    }
}
