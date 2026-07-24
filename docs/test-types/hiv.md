# HIV Antigen Test — Supplier Guidance

## Overview

| | |
|---|---|
| **Test name** | HIV antigen test |
| **SNOMED CT code** | `31676001` — HIV antigen test |
| **Order path** | Consumer-initiated (patient self-order via HomeTest platform) |
| **Clinical management** | Supplier responsibility |

---

## Mandatory fields (beyond base spec)

The following fields are **optional** in the base supplier spec but are **mandatory** for HIV orders.

### `contained[Patient].telecom`

Suppliers are responsible for all clinical management of HIV test orders. This includes contacting the patient to deliver results, providing appropriate clinical advice, and referring where required. Patient contact details are therefore essential.

**Requirements:**

- `telecom` **must** be present with a minimum of one entry
- One entry **must** have `system: "phone"` with a valid UK phone number
- One entry **may** have `system: "email"` with a valid email address (optional)

```json
"telecom": [
  {
    "system": "phone",
    "value": "+447700900123",
    "use": "mobile"
  }
]
```

---

## Specimen collection method

The `Extension-UKCore-SpecimenCollectionMethod` extension on the `ServiceRequest` specifies how the sample is to be collected. Suppliers must use this value to determine which kit variant to dispatch.

### Supported values

| SNOMED code | Display | Kit variant |
|---|---|---|
| `122554006` | Capillary blood specimen | Finger-prick blood spot card |

> **Note:** Additional collection methods (oral swab, transdermal) may be added in future. Suppliers should handle unknown `SpecimenCollectionMethod` values gracefully and contact the HomeTest team before rejecting an order on this basis.

If the extension is absent, assume capillary blood (current default).

---

## Supplier responsibilities

| Responsibility | Supplier | HomeTest platform | Requesting clinician |
|---|---|---|---|
| Eligibility / quota checking | ✅ (via 409 response) | | |
| Kit dispatch | ✅ | | |
| Sample receipt and processing | ✅ | | |
| Patient notification of result | ✅ | | |
| Clinical advice and onward referral | ✅ | | |
| Result submission (`/results`) | ✅ | | |

---

## Order flow

1. HomeTest platform sends a pre-submission eligibility check with a `draft` `FHIRServiceRequest`; supplier validates eligibility and quota rules and returns `409` with an appropriate `OperationOutcome` if the order cannot proceed
2. HomeTest platform sends `POST /order` with an `active` `FHIRServiceRequest` containing patient demographics (including `telecom`); if a pre-submission check was performed and the order matches, the supplier must accept it — `400`/`409` responses are not expected at this stage unless no pre-submission check was performed or a technical error occurs
3. On acceptance, supplier dispatches the kit to the address in `contained[Patient].address`
4. Supplier posts status updates via the task endpoint as the order progresses
5. Supplier contacts the patient directly to deliver results and provide clinical support
6. After notifying the patient, supplier submits an `Observation` via `POST /results` to make results available to HomeTest

---

## Result requirements

Results must be submitted as a FHIR `Bundle` containing a `DiagnosticReport` and an `Observation`. The `Observation` must include:

- `basedOn` referencing the originating `ServiceRequest`
- `status: "final"` for confirmed results
- `code` using SNOMED CT (`31676001` — HIV antigen test)
- `valueCodeableConcept` with one of the following result values:

| SNOMED code | Display | Meaning |
|---|---|---|
| `260415000` | Not detected | Negative result |
| `260373001` | Detected | Positive result — clinical follow-up required |
| `419984006` | Inconclusive | Indeterminate — retest may be required |

- `interpretation` using `http://terminology.hl7.org/CodeSystem/v3-ObservationInterpretation`:
  - `N` (Normal) for negative
  - `POS` (Positive) for detected
  - `IND` (Indeterminate) for inconclusive

---

## Business rule errors (409 responses)

Suppliers must return a `409 Conflict` with a `FHIROperationOutcome` for the following conditions:

| `details.text` | Condition |
|---|---|
| `individual_quota_used` | Patient has already used their test allocation for this period |
| `local_quota_exceeded` | Local authority quota has been exhausted |
| `out_of_stock` | Kit variant required is not currently available |
| `not_eligible` | Patient does not meet local eligibility criteria |
| `test_not_available` | Test type not available from this supplier |
| `suspected_fraud` | Order flagged for manual review |

See [supplier-api-spec-v2.yaml](../../schemas/supplier-api-spec-v2.yaml) for the full `409` response schema and examples.
