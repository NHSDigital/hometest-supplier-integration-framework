# Test-Type Guidance

The [supplier API spec](../../schemas/supplier-api-spec-v2.yaml) defines the base integration contract. Not every field is meaningful for every test type, and some fields that are optional in the spec are **mandatory in practice** for specific test types.

This directory contains per-test-type guidance that suppliers **must read alongside the spec** before implementing.

## How to use these documents

Each file covers one test type and specifies:

- The applicable SNOMED CT code(s)
- Which optional spec fields become mandatory for that test type
- Supplier responsibilities (clinical management, patient contact, dispatch)
- Relevant `Extension-UKCore-SpecimenCollectionMethod` values
- Result and observation requirements

## Test types

| File | Test | Order path |
|---|---|---|
| [hiv.md](hiv.md) | HIV antigen test | Consumer-initiated (patient self-order) |
| [psa.md](psa.md) | PSA (Prostate-Specific Antigen) | Clinician-initiated (acute/EPR) |

## Key conventions

- **`telecom`** is optional in the base spec. Whether it is required depends on who carries clinical management responsibility for the test type. See each test-type file for the specific rule.
- **`Extension-UKCore-SpecimenCollectionMethod`** will be present on orders where the collection method must be specified. Suppliers must use this value to determine which kit variant to dispatch.
- **`gender`** will be present on clinician-initiated orders (sourced from the EPR). It may be absent on consumer-initiated orders.
- Fields not listed in a test-type file follow the base spec rules (optional unless spec marks them required).
