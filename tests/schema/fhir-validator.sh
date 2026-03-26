#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "Usage: $0 -j <validator_jar> -e <examples_dir> [-o <output_dir>] [-v <fhir_version>]"
  echo ""
  echo "  -j  Path to the FHIR validator CLI JAR file"
  echo "  -i  Directory containing resource files to validate"
  echo "  -o  (Optional) Directory to write validation results to."
  echo "      Defaults to <input_dir>/validation-results/<timestamp>"
  echo "  -v  (Optional) FHIR version to validate against. Defaults to 4.0"
  echo ""
  echo "  The following outputs are written to the output directory:"
  echo "    results.json   Bundle of OperationOutcomes as JSON  (-output)"
  echo "    results.html   Human-readable HTML report           (-html-output)"
  exit 1
}

VALIDATOR_LOCATION=""
TO_VALIDATE=""
OUTPUT_DIR=""
FHIR_VERSION="4.0"

while getopts ":j:i:o:v:" opt; do
  case $opt in
    j) VALIDATOR_LOCATION="$(realpath "$OPTARG")" ;;
    i) TO_VALIDATE="$(realpath "$OPTARG")" ;;
    o) OUTPUT_DIR="$OPTARG" ;;
    v) FHIR_VERSION="$OPTARG" ;;
    :) echo "Error: Flag -$OPTARG requires an argument." >&2; usage ;;
    \?) echo "Error: Unknown flag -$OPTARG." >&2; usage ;;
  esac
done

if [ -z "$VALIDATOR_LOCATION" ] || [ -z "$TO_VALIDATE" ]; then
  echo "Error: Flags -j and -e are required." >&2
  usage
fi

if [ -z "$OUTPUT_DIR" ]; then
  OUTPUT_DIR="$TO_VALIDATE/validation-results/$(date +%Y%m%dT%H%M%S)"
fi

if [ ! -f "$VALIDATOR_LOCATION" ]; then
  echo "Error: Validator JAR not found: $VALIDATOR_LOCATION" >&2
  exit 1
fi

if [ ! -d "$TO_VALIDATE" ]; then
  echo "Error: Input directory not found: $TO_VALIDATE" >&2
  exit 1
fi

if ! command -v java &>/dev/null; then
  echo "Error: 'java' is not installed or not on PATH." >&2
  exit 1
fi

echo "Validator: $VALIDATOR_LOCATION"
echo "Examples:  $TO_VALIDATE"
echo "Version:   $FHIR_VERSION"
echo "Results:   $OUTPUT_DIR"
echo ""

mkdir -p "$OUTPUT_DIR"

echo "Validating all resources in $TO_VALIDATE..."
if ! java -jar "$VALIDATOR_LOCATION" "$TO_VALIDATE" \
      -version "$FHIR_VERSION" \
      -output "$OUTPUT_DIR/results.json" \
      -html-output "$OUTPUT_DIR/results.html"; then
  echo "Error: Validation failed." >&2
  exit 1
fi

echo ""
echo "Validation complete."
echo "Results written to: $OUTPUT_DIR"

