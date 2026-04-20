# Guide to HomeTest Results

## Introduction

Results for home test kits are deliberately kept seperate from less sensitive order updates, with its own endpoint.

To align with wider UK Pathology standards, particularly the [Pathology FHIR Implementation Guide](https://simplifier.net/guide/pathology-fhir-implementation-guide/Home?version=0.1). HomeTest expects results as a FHIR 'Bundle' type, containing a DiagnosticReport resource along with the related Observation resource.

In addition, we also want to record whether patient contact has been made through the use of a 'Communication' resource, also included within the bundle.
The use of Communication in this way is not within the scope of the Pathology FHIR Implementation guide, and is specific to HomeTest.

## SNOMED-CT Codes for HomeTest kits

### Observable Entity code for HIV Testing

For the Beta stage of HomeTest, only HIV HomeTest Kits are used.
Therefore the only expected 'observable entity' expected is `31676001 | Human immunodeficiency virus antigen test (procedure)`, which is the SNOMED-CT code for the HIV testing we're doing. This appears in the 'code' field of the Observation.

### Test result (value) codes for HIV testing

There are two competing representations of the 'value' of a UK Pathology test. Older UK pathology standards before FHIR recorded results using text only, and this is still the standardised way to record tests within the published Pathology implementation guidance to allow interoperatiblity with older, non-FHIR systems.
However, we expect this guidance to change in the near future to recommend the use of SNOMED-CT 'finding' codes, also known as 'Reportables'.

To anticipate this change of guidance, HomeTest expects suppliers to use a SNOMED-CT code in the 'valueCodeableConcept' field of the Observation. The code used is is specific to the findings of HIV testing.

For reactive (including low-reactive) results, the code `165816005 | Human immunodeficiency virus detected (finding)` should be used.

For non-reactive (including 'not detected' and 'negative) results, the code `165815009 | Human immunodeficiency virus not detected (finding)` should be used.

Some tests also rarely lead to results such as 'borderline','equivocal', and 'unconfirmed'. These should use the result code `419984006 | Inconclusive`

These possible results are summarised below, together with the matching known internal supplier codes.

| Test Supplier code (internal) | SNOMED-CT Code    | SNOMED-CT Description          |
|---------------|---------------|----------------------------------------------------|
| Reactive      | `165816005`   | Human immunodeficiency virus detected (finding)    |
| Low Reactive  | `165816005`   | Human immunodeficiency virus detected (finding)    |
| Non Reactive  | `165815009`   | Human immunodeficiency virus not detected (finding)|
| Not Detected  | `165815009`   | Human immunodeficiency virus not detected (finding)|
| Negative      | `165815009`   | Human immunodeficiency virus not detected (finding)|
| Borderline    | `419984006`   | Inconclusive                                       |
| Equivocal     | `419984006`   | Inconclusive                                       |
| Unconfirmed   | `419984006`   | Inconclusive                                       |
| Borderline    | `419984006`   | Inconclusive                                       |

### Tests with absent results due to error

There is finally a set of error results, including both laboratory errors (such as 'invalid', 'heamolysed', or 'out-of-validation') and user errors (particularly 'insufficient sample').

These all result in no value for the test, and so the value field should be left empty in the Observation resource. Instead the 'dataAbsentReason' field should be populated.

| Test Supplier code (internal) | dataAbsentReason |
|-------------------------------|------------------|
| Insufficient                  | `insufficient`   |
| Haemolysed                    | `invalid`        |
| Invalid sample                | `invalid`        |
| Out of Validation             | `invalid`        |
| Lab Error                     | `invalid`        |
| Not Processed                 | `invalid`        |
| Unknown                       | `invalid`        |


## Other fields within DiagnosticReport

 The `DiagnosticReport` resource is a base FHIR type that represents the findings and interpretation of diagnostic tests performed on patients, specimens, or other entities. Most of this guidance is based on the Pathology FHIR Implementation Guide (https://simplifier.net/guide/pathology-fhir-implementation-guide/Home/FHIRAssets/AllAssets/AllProfiles/UKCore-DiagnosticReport-Lab?version=0.2.0), which should be treated as the authoritative source.

### BasedOn
This field should be a reference to the ServiceRequest (order) that initiated the test.

### Status
HomeTest only expects to receive Diagnostic Reports where the status is `final`

### Category

The following should be used:

* DiagnosticReport.category.coding.system = http://terminology.hl7.org/CodeSystem/v2-0074
* DiagnosticReport.category.coding.code = LAB
* DiagnosticReport.category.coding.display = Laboratory

It is possible to extend this field with additional information, but this is not necessary for HomeTest suppliers.

### Code
Within the DiganosticReport this SHALL be populated with the following fixed value:

* DiagnosticReport.code.coding.system = http://snomed.info/sct
* DiagnosticReport.code.coding.code = 721981007
* DiagnosticReport.code.coding.display = Diagnostic studies report

Note: The clinical code and name of a test result or a test group is defined in the code element of the relevant Observation resource.

### Subject
Home Test does not pass full patient details to suppliers, and instead an pseudo-anonymous patient-id is sent, along with their name and contact details. Results returned to HomeTest should reference this patient-id only.

### Performer
This should be referenced using the HomeTest-agreed supplier organisation ID. This may change in the future to include an organisation's ODS id, but currently not all suppliers have this identifier.

### Specimen
HomeTest does not expect to receive references to the specimen used for the result, and this field should not be populated.

### Result
References to `Observation` resources containing the actual test results and measurements.

### Conclusion
HomeTest does not expect this field to be populated

## Other fields within Observation

### Code
Within the Observation resource, this should be populated with the matching HIV SNOMED-CT 'observable entity' code. For the current HIV home-tests, this is `31676001 | Human immunodeficiency virus antigen test (procedure)`

### Subject
As for the DiagnsoticReport, this should reference the HomeTest-specific patient-id.

### Status
HomeTest only expects to receive Observations where the status is `final`. Whether clinical contact has been made is modelled with the 'Communication' resource (see [FHIR Communication Resource for HIV Test Results](./clinical-contact-communication.md)  ).
