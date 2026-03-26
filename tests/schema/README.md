# FHIR Example Validation

This directory contains tooling to validate the FHIR example resources in [`examples/fhir/`](../../examples/fhir) against the FHIR specification using the [HL7 FHIR Validator CLI](https://confluence.hl7.org/display/FHIR/Using+the+FHIR+Validator).

Validation is also run automatically in CI on every push and pull request — see [`.github/workflows/validate-fhir-examples.yml`](../../.github/workflows/validate-fhir-examples.yml).

---

## Prerequisites

| Requirement        | Version | Notes                                                 |
|--------------------|---------|-------------------------------------------------------|
| Java               | 11+     | Must be on `PATH`. Check with `java -version`         |
| FHIR Validator JAR | latest  | See [Downloading the JAR](#downloading-the-jar) below |
| bash               | 3.2+    | Pre-installed on macOS and Linux                      |

---

## Downloading the JAR

The validator JAR is not committed to this repository. Download the latest release from the [hapifhir/org.hl7.fhir.core](https://github.com/hapifhir/org.hl7.fhir.core/releases/latest) repository.

Using the GitHub CLI:

```bash
gh release download --pattern '*.jar' --repo 'hapifhir/org.hl7.fhir.core' --dir tests/schema
```

Or download it manually from the [releases page](https://github.com/hapifhir/org.hl7.fhir.core/releases/latest) and place the JAR in this directory.

---

## Usage

```
./fhir-validator.sh -j <validator_jar> -i <input_dir> [-o <output_dir>] [-v <fhir_version>]
```

| Flag | Required | Default                                      | Description                                  |
|------|----------|----------------------------------------------|----------------------------------------------|
| `-j` | ✅        | —                                            | Path to the FHIR validator CLI JAR           |
| `-i` | ✅        | —                                            | Directory of FHIR resource files to validate |
| `-o` | ❌        | `<input_dir>/validation-results/<timestamp>` | Directory to write results to                |
| `-v` | ❌        | `4.0`                                        | FHIR version to validate against             |

### Examples

Validate the example resources using a default FHIR version (4.0):

```bash
./tests/schema/fhir-validator.sh \
  -j tests/schema/validator_cli.jar \
  -i examples/fhir
```

Validate against a specific FHIR version and write results to a known location:

```bash
./tests/schema/fhir-validator.sh \
  -j tests/schema/validator_cli.jar \
  -i examples/fhir \
  -o /tmp/fhir-results \
  -v 4.0.1
```

---

## Output

Two result files are written to the output directory for each run:

| File           | Description                                                              |
|----------------|--------------------------------------------------------------------------|
| `results.json` | A FHIR `Bundle` of `OperationOutcome` resources — one per validated file |
| `results.html` | A human-readable HTML report (open in any browser)                       |

### Understanding results

| Severity          | Meaning                                                    |
|-------------------|------------------------------------------------------------|
| `error` / `fatal` | The resource does not conform to the FHIR specification    |
| `warning`         | A best-practice recommendation — valid but worth reviewing |
| `information`     | Informational only, no action required                     |

