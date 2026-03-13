#!/bin/zsh
# Build Donots.app for Release
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
PROJECT_DIR="${SCRIPT_DIR}/.."
BUILD_DIR="${PROJECT_DIR}/.build/release"

echo "Building Donots (Release)..."
cd "$PROJECT_DIR"

# Build with SwiftPM
swift build -c release

# Create .app bundle
APP_DIR="${BUILD_DIR}/Donots.app/Contents"
mkdir -p "${APP_DIR}/MacOS"
mkdir -p "${APP_DIR}/Resources"

# Copy binary
cp "${BUILD_DIR}/Donots" "${APP_DIR}/MacOS/Donots"

# Copy Info.plist
cp "${PROJECT_DIR}/Resources/Info.plist" "${APP_DIR}/Info.plist"

# Copy entitlements (for codesigning reference)
cp "${PROJECT_DIR}/Resources/Donots.entitlements" "${APP_DIR}/Resources/Donots.entitlements"

echo "Build complete: ${BUILD_DIR}/Donots.app"
