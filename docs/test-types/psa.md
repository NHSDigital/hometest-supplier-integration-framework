# PSA (Prostate-Specific Antigen) — Supplier Guidance

> **Status: Work in progress.** This document provides a structural skeleton. Sections marked **[TBD]** require further clinical and operational input before supplier onboarding for PSA tests.

## Overview

| | |
|---|---|
| **Test name** | Measurement of prostate-specific antigen |
| **SNOMED CT code** | `63476009` — Measurement of prostate specific antigen |
| **Order path** | Clinician-initiated (acute/EPR via HomeTest acute consumer API) |
| **Clinical management** | Requesting clinician's responsibility — **not the supplier** |

---

## Key difference from consumer-initiated tests

PSA orders originate from a clinician in an acute or primary care setting via their EPR system. The requesting clinician retains full clinical management responsibility, including result interpretation, patient notification, and onward referral.

**Suppliers do not contact the patient.** Suppliers dispatch the kit, process the sample, and submit results. All clinical interaction is handled outside of the supplier's scope.

---

## Mandatory fields (beyond base spec)

### `contained[Patient].telecom`

**Not required.** Suppliers must not attempt to contact the patient directly for PSA orders. `telecom` will be absent from these orders. Supplier implementations must tolerate a `FHIRServiceRequest` where `telecom` is not present on the contained `Patient`.

### `contained[Patient].gender`

`gender` will be present on PSA orders (sourced from the EPR). Suppliers should use this where relevant to test processing or result interpretation. **[TBD: confirm whether gender is required for PSA processing or informational only]**

### `ServiceRequest.extension` — SpecimenCollectionMethod

The `Extension-UKCore-SpecimenCollectionMethod` extension will be present on PSA orders and must be used to determine the kit variant to dispatch.

**[TBD: confirm supported collection method SNOMED codes for PSA]**

| SNOMED code | Display | Kit variant |
|---|---|---|
| `122554006` | Capillary blood specimen | Finger-prick blood spot card |
| **[TBD]** | **[TBD]** | **[TBD]** |

---

## Supplier responsibilities

| Responsibility | Supplier | HomeTest platform | Requesting clinician |
|---|---|---|---|
| Kit dispatch | ✅ | | |
| Sample receipt and processing | ✅ | | |
| Result submission (`/results`) | ✅ | | |
| Patient notification of result | | | ✅ |
| Clinical advice and onward referral | | | ✅ |
| Eligibility / quota checking | **[TBD]** | | |

---

## Order flow

**[TBD: confirm end-to-end flow for clinician-initiated PSA orders, including any differences in status update expectations]**

1. HomeTest platform receives order from EPR, validates, schedules dispatch, then sends `POST /order` to supplier
2. Supplier dispatches kit to address in `contained[Patient].address`
3. Supplier posts status updates via the task endpoint as the order progresses
4. On result availability, supplier submits an `Observation` via `POST /results`
5. HomeTest platform routes result back to the requesting clinician's EPR — **supplier does not contact the patient**

---

## Result requirements

PSA is a **quantitative** test — the result is a numeric concentration value, not a coded qualitative finding. Suppliers must use `valueQuantity`, not `valueCodeableConcept`.

Results must be submitted as a `FHIRObservation` and must include:

- `basedOn` referencing the originating `ServiceRequest`
- `status: "final"` for confirmed results
- `code` using SNOMED CT (`63476009` — Measurement of prostate specific antigen)
- `valueQuantity` with the measured PSA concentration in ng/mL (see below)
- `referenceRange` (see below)
- `interpretation` indicating whether the value is within or outside the normal range

### `valueQuantity`

```json
"valueQuantity": {
  "value": 4.2,
  "unit": "ng/mL",
  "system": "http://unitsofmeasure.org",
  "code": "ng/mL"
}
```

- `system` must be `http://unitsofmeasure.org` (UCUM)
- `code` must be `ng/mL`

### `referenceRange`

PSA reference ranges are age-dependent. Suppliers must provide at least one `referenceRange` entry. Where age-adjusted ranges are applied, each band should be a separate entry with the applicable age described in the `text` field.

```json
"referenceRange": [
  {
    "low":  { "value": 0,   "unit": "ng/mL", "system": "http://unitsofmeasure.org", "code": "ng/mL" },
    "high": { "value": 4.0, "unit": "ng/mL", "system": "http://unitsofmeasure.org", "code": "ng/mL" },
    "type": {
      "coding": [{ "system": "http://terminology.hl7.org/CodeSystem/referencerange-meaning", "code": "normal", "display": "Normal Range" }]
    },
    "text": "Normal range for adult males (age-adjusted ranges may apply)"
  }
]
```

**[TBD: confirm whether a standard NHS age-adjusted PSA reference range table should be mandated, or whether suppliers use their own laboratory reference ranges.]**

### `interpretation`

Use codes from `http://terminology.hl7.org/CodeSystem/v3-ObservationInterpretation`:

| Code | Display | Meaning |
|---|---|---|
| `N` | Normal | Value within reference range |
| `H` | High | Value above upper reference range |
| `HH` | Critical high | Value significantly above upper reference range — urgent clinical review required |

---

## Business rule errors (409 responses)

**[TBD: confirm which 409 business rule conditions apply to clinician-initiated PSA orders. Individual quota and local quota rules may not apply in the same way as consumer-initiated tests.]**

See [supplier-api-spec-v2.yaml](../../schemas/supplier-api-spec-v2.yaml) for the full `409` response schema and examples.
