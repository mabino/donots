FROM swift:5.9 AS builder

WORKDIR /app

# Copy package manifest first for layer caching
COPY Package.swift .

# Copy source and test files
COPY Sources/ Sources/
COPY Tests/ Tests/
COPY Resources/ Resources/

# Build and test (pure-logic tests only - no macOS frameworks)
RUN swift build --build-tests 2>&1 || true
CMD ["swift", "test", "--filter", "LogEntryTests|DateFormattingTests|ScreenshotServiceTests|CaptureOptionsTests|RegionSelectorTests"]
