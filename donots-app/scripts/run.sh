#!/bin/zsh
# Run Donots.app
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
PROJECT_DIR="${SCRIPT_DIR}/.."
APP_PATH="${PROJECT_DIR}/.build/release/Donots.app"

if [[ ! -d "$APP_PATH" ]]; then
    echo "App not found. Building first..."
    "${SCRIPT_DIR}/build.sh"
fi

echo "Launching Donots..."
open "$APP_PATH"
