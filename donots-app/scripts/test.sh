#!/bin/zsh
# Run tests: native macOS tests + Docker-based pure-logic tests
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
PROJECT_DIR="${SCRIPT_DIR}/.."

echo "=== Running native macOS tests ==="
cd "$PROJECT_DIR"
swift test

echo ""
echo "=== Running Docker-based tests ==="
cd "$PROJECT_DIR"
docker-compose run --rm test

echo ""
echo "All tests passed."
