#!/usr/bin/env bash
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Navigate to project root (two levels up from tests/scripts/)
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Validate all OpenAPI yaml files in the schemas directory
spectral lint "$PROJECT_ROOT/schemas"/*.yaml --fail-severity info -r "$SCRIPT_DIR/.spectral.yaml" --verbose
