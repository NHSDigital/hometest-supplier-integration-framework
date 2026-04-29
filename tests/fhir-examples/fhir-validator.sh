#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "Usage: $0 -j <validator_jar> -e <examples_dir> [-o <output_dir>] [-v <fhir_version>]"
  echo ""
  echo "  -j  Path to the FHIR validator CLI JAR file"
  echo "  -i  Directory containing resource files to validate"
  echo "  -o  (Optional) Directory to write validation results to."
  echo "      Defaults to <input_dir>/validation-results/<timestamp>"
  echo "  -v  (Optional) FHIR version to validate against. Defaults to 4.0.1"
  echo "  -c  (Optional) Cache for the validator tool"
  echo ""
  echo "  The following outputs are written to the output directory:"
  echo "    results.json   Bundle of OperationOutcomes as JSON  (-output)"
  echo "    results.html   Human-readable HTML report           (-html-output)"
  exit 1
  return
}

VALIDATOR_LOCATION=""
TO_VALIDATE=""
OUTPUT_DIR=""
FHIR_VERSION="4.0.1"
VALIDATOR_CACHE="$HOME"

while getopts ":j:i:o:v:c:" opt; do
  case $opt in
    j) VALIDATOR_LOCATION="$(realpath "$OPTARG")" ;;
    i) TO_VALIDATE="$(realpath "$OPTARG")" ;;
    o) OUTPUT_DIR="$OPTARG" ;;
    v) FHIR_VERSION="$OPTARG" ;;
    c) VALIDATOR_CACHE="$OPTARG" ;;
    :) echo "Error: Flag -$OPTARG requires an argument." >&2; usage ;;
    \?) echo "Error: Unknown flag -$OPTARG." >&2; usage ;;
    *) echo "Error: Unexpected option -$opt." >&2; usage ;;
  esac
done

if [[ -z "$VALIDATOR_LOCATION" || -z "$TO_VALIDATE" ]]; then
  echo "Error: Flags -j and -e are required." >&2
  usage
fi

if [[ -z "$OUTPUT_DIR" ]]; then
  OUTPUT_DIR="$TO_VALIDATE/validation-results/$(date +%Y%m%dT%H%M%S)"
fi

if [[ ! -f "$VALIDATOR_LOCATION" ]]; then
  echo "Error: Validator JAR not found: $VALIDATOR_LOCATION" >&2
  exit 1
fi

if [[ ! -d "$TO_VALIDATE" ]]; then
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
echo "Cache:     $VALIDATOR_CACHE"
echo ""

mkdir -p "$OUTPUT_DIR"
mkdir -p "$VALIDATOR_CACHE"

echo "Validating all resources in $TO_VALIDATE..."
if ! java -Duser.home="$VALIDATOR_CACHE" -jar "$VALIDATOR_LOCATION" "$TO_VALIDATE" \
      -version "$FHIR_VERSION" \
      -output "$OUTPUT_DIR/results.json" \
      -html-output "$OUTPUT_DIR/results.html" \
      -txCache "$VALIDATOR_CACHE/tx"
      then
  echo "Error: Validation failed." >&2
  exit 1
fi

echo ""
echo "Validation complete."
echo "Results written to: $OUTPUT_DIR"

