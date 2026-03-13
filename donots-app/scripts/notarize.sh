#!/bin/zsh
# Codesign and notarize Donots.app
# Requires: Apple Developer ID, TEAM_ID, APPLE_ID, APP_PASSWORD environment variables
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
PROJECT_DIR="${SCRIPT_DIR}/.."
APP_PATH="${PROJECT_DIR}/.build/release/Donots.app"
ENTITLEMENTS="${PROJECT_DIR}/Resources/Donots.entitlements"

: "${DEVELOPER_ID:?Set DEVELOPER_ID to your Developer ID Application certificate name}"
: "${TEAM_ID:?Set TEAM_ID to your Apple Developer Team ID}"
: "${APPLE_ID:?Set APPLE_ID to your Apple ID email}"
: "${APP_PASSWORD:?Set APP_PASSWORD to your app-specific password}"

if [[ ! -d "$APP_PATH" ]]; then
    echo "App not found. Run build.sh first."
    exit 1
fi

echo "Codesigning..."
codesign --force --options runtime \
    --entitlements "$ENTITLEMENTS" \
    --sign "Developer ID Application: ${DEVELOPER_ID}" \
    --timestamp \
    "$APP_PATH"

echo "Verifying signature..."
codesign --verify --deep --strict "$APP_PATH"

echo "Creating ZIP for notarization..."
ZIP_PATH="${PROJECT_DIR}/.build/Donots.zip"
ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

echo "Submitting for notarization..."
xcrun notarytool submit "$ZIP_PATH" \
    --apple-id "$APPLE_ID" \
    --password "$APP_PASSWORD" \
    --team-id "$TEAM_ID" \
    --wait

echo "Stapling ticket..."
xcrun stapler staple "$APP_PATH"

echo "Notarization complete: $APP_PATH"
